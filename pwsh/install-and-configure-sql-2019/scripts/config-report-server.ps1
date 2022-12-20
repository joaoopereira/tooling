$installed = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Contains "Microsoft SQL Server Reporting Services"
if(!$installed) {
	throw "Report Server not installed"
}
else {
	## CREDITS https://blog.aelterman.com/2018/01/03/complete-automated-configuration-of-sql-server-2017-reporting-services/
	function Get-ConfigSet()
	{
		return Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_SSRS\v15\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost
	}

	# Allow importing of sqlps module
	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

	# Retrieve the current configuration
	$configset = Get-ConfigSet

	# Get the ReportServer and ReportServerTempDB creation script
	[string]$dbscript = $configset.GenerateDatabaseCreationScript("ReportServer", 1033, $false).Script

	# Import the SQL Server PowerShell module
	Import-Module sqlps -DisableNameChecking | Out-Null

	# Establish a connection to the database server
	$smo = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$env:COMPUTERNAME\$env:SQL_INSTANCE"
	$smo.ConnectionContext.LoginSecure = $false
	$smo.ConnectionContext.Login="sa"
	$smo.ConnectionContext.Password="$env:SQL_SA_PWD"

	# Create the ReportServer and ReportServerTempDB databases
	$db = $smo.Databases["master"]
	$db.ExecuteNonQuery($dbscript)

	# Set permissions for the databases
	$dbscript = $configset.GenerateDatabaseRightsScript($configset.WindowsServiceIdentityConfigured, "ReportServer", $false, $true).Script
	$db.ExecuteNonQuery($dbscript)

	# Set the database connection info
	$configset.SetDatabaseConnection("$env:COMPUTERNAME\$env:SQL_INSTANCE", "ReportServer", 1, "sa", "$env:SQL_SA_PWD") | Out-Null

	$configset.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033) | Out-Null
	$configset.ReserveURL("ReportServerWebService", "http://+:80", 1033) | Out-Null

	# For SSRS 2016-2017 only, older versions have a different name
	$configset.SetVirtualDirectory("ReportServerWebApp", "Reports", 1033) | Out-Null
	$configset.ReserveURL("ReportServerWebApp", "http://+:80", 1033) | Out-Null

	$configset.InitializeReportServer($configset.InstallationID) | Out-Null

	# Add Basic Auth
	$rsreportserverConfigPath = "C:\Program Files\Microsoft SQL Server Reporting Services\SSRS\ReportServer\rsreportserver.config"
	$rsreportserverConfig = New-Object XML
	$rsreportserverConfig.Load($rsreportserverConfigPath)
	$rsreportserverConfig.Configuration.Authentication.AuthenticationTypes.AppendChild($rsreportserverConfig.CreateElement("RSWindowsBasic")) | Out-Null
	$rsreportserverConfig.Save($rsreportserverConfigPath)

	# Give full access to all users
	$db = $smo.Databases["ReportServer"]
	$dbScript =
@"
DECLARE @UserId NVARCHAR(MAX) = (SELECT UserId FROM dbo.Users WHERE UserName = 'Everyone')

DECLARE @Folder_PolicyId NVARCHAR(MAX) = (SELECT PolicyId FROM dbo.Policies WHERE PolicyFlag = 0)
DECLARE @Browser_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'Browser')
DECLARE @ReportBuilder_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'Report Builder')
DECLARE @Publisher_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'Publisher')
DECLARE @MyReports_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'My Reports')
DECLARE @ContentManager_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'Content Manager')

DECLARE @Site_PolicyId NVARCHAR(MAX) = (SELECT PolicyId FROM dbo.Policies WHERE PolicyFlag = 1)
DECLARE @SystemAdministrator_RoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'System Administrator')
DECLARE @SystemUserRoleId NVARCHAR(MAX) = (SELECT RoleId FROM dbo.Roles WHERE RoleName = 'System User')

-- Delete all existent policies to Everyone
DELETE FROM dbo.PolicyUserRole
WHERE UserID = @UserId

-- Insert Policy User Role to Everyone
INSERT INTO dbo.PolicyUserRole
([ID],		[RoleID],						[UserID],	[PolicyID])
VALUES
(NEWID(),	@Browser_RoleId,				@UserId,	@Folder_PolicyId),
(NEWID(),	@ReportBuilder_RoleId,			@UserId,	@Folder_PolicyId),
(NEWID(),	@Publisher_RoleId,				@UserId,	@Folder_PolicyId),
(NEWID(),	@MyReports_RoleId,				@UserId,	@Folder_PolicyId),
(NEWID(),	@ContentManager_RoleId,			@UserId,	@Folder_PolicyId),
(NEWID(),	@SystemAdministrator_RoleId,	@UserId,	@Site_PolicyId)

UPDATE dbo.SecData
SET [XmlDescription] = '<Policies><Policy><GroupUserName>BUILTIN\Administrators</GroupUserName><GroupUserId>AQIAAAAAAAUgAAAAIAIAAA==</GroupUserId><Roles><Role><Name>System Administrator</Name></Role></Roles></Policy><Policy><GroupUserName>everyone</GroupUserName><GroupUserId>AQEAAAAAAAEAAAAA</GroupUserId><Roles><Role><Name>System Administrator</Name><Description>View and modify system role assignments, system role definitions, system properties, and shared schedules.</Description></Role></Roles></Policy></Policies>'
WHERE PolicyId = @Site_PolicyId

UPDATE dbo.SecData
SET [XmlDescription] = '<Policies><Policy><GroupUserName>BUILTIN\Administrators</GroupUserName><GroupUserId>AQIAAAAAAAUgAAAAIAIAAA==</GroupUserId><Roles><Role><Name>Content Manager</Name></Role></Roles></Policy><Policy><GroupUserName>everyone</GroupUserName><GroupUserId>AQEAAAAAAAEAAAAA</GroupUserId><Roles><Role><Name>Browser</Name><Description>May view folders, reports and subscribe to reports.</Description></Role><Role><Name>Content Manager</Name><Description>May manage content in the Report Server.  This includes folders, reports and resources.</Description></Role><Role><Name>My Reports</Name><Description>May publish reports and linked reports; manage folders, reports and resources in a users My Reports folder.</Description></Role><Role><Name>Publisher</Name><Description>May publish reports and linked reports to the Report Server.</Description></Role><Role><Name>Report Builder</Name><Description>May view report definitions.</Description></Role></Roles></Policy></Policies>'
WHERE PolicyId = @Folder_PolicyId
"@

	$db.ExecuteNonQuery($dbscript)

	# Restart services
	$configset.SetServiceState($false, $false, $false) | Out-Null
	Restart-Service $configset.ServiceName
	$configset.SetServiceState($true, $true, $true) | Out-Null
}
