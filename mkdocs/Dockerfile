FROM python:3.8-slim-bullseye AS builder
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
RUN apt update && apt install -y python3-pip python3-cffi python3-brotli libpango-1.0-0 libpangoft2-1.0-0
COPY . .
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:80"]
EXPOSE 80