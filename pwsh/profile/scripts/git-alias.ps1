### git alias

## merge
function git-merge($branch) {
    git fetch --all
    git merge origin/$branch
}

function git-merge-main {
    git-merge main
}

function git-merge-development {
    git-merge development
}

## rebase
function git-rebase($branch) {
    git fetch --all;
    git rebase origin/$branch
}
function git-rebase-main {
    git-rebase main
}

function git-rebase-development {
    git-rebase development
}

## prune all origin gone branches
function git-prune-gone-branches {
    git checkout development
    git remote update origin --prune
    git branch -vv | Select-String -Pattern ": gone]" | ForEach-Object { $_.toString().Trim().Split(" ")[0] } | ForEach-Object { git branch -D $_ }
    git pull
}

## pull and push current branch
function git-sync {
    git pull
    git push
}

## branch
function git-new-branch($newBranch, $sourceBranch) {
    if(!($null -eq $sourceBranch))
    {
        git checkout $sourceBranch
    }
    git pull
    git checkout -b $newBranch
}

function git-new-branch-development($newBranch) {
    git-new-branch $newBranch development
}

function git-publish-branch {
    $currentBranch = git branch --show-current
    git push --set-upstream origin $currentBranch
}

function git-replace-remote-branch($remoteBranch) {
    $currentBranch = git branch --show-current
    $localRemote = $currentBranch + ":" + $remoteBranch
    git push origin $localRemote -f
}

## commit
function git-add-all-commit($commitmessage) {
    git pull
    git add .
    git commit -m $commitmessage
}

function git-commit-staged-push($commitmessage) {
    git pull
    git commit -m $commitmessage;
    $currentBranch = git branch --show-current
    git push --set-upstream origin $currentBranch
}

function gtaddcommitpush($commitmessage) {
    git-add-all-commit $commitmessage
    $currentBranch = git branch --show-current
    git push --set-upstream origin $currentBranch
}

function git-add-amend {
    git add .
    git commit --amend
}
