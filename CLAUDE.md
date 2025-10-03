# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Django project scaffold that uses Docker containers and an initialization script to bootstrap new Django projects from a GitHub template.

## Setup and Running

### Initial Project Setup
```bash
./start.sh
```
This script:
- Creates the `project/` directory structure
- Downloads Django project template from GitHub
- Copies Docker configuration files to root
- Initializes Django project inside a temporary container
- Builds and starts all services via docker-compose

### Running the Application
```bash
docker compose up --build
```
Access the application at http://localhost (nginx serves on port 80)

### Stopping Services
```bash
docker compose down
```

## Architecture

### Multi-Container Setup
The application runs across three Docker services:

1. **nginx** (django_nginx): Reverse proxy and static file server
   - Listens on port 80
   - Proxies requests to Django on port 8000
   - Serves static files from `/static/`
   - Serves media files from `/media/`

2. **django** (django_web): Django application server
   - Python 3.13-slim-bookworm
   - Development server on port 8000 (internal)
   - Mounted volumes for live code reloading

3. **redis** (redis_broker): Redis 7 Alpine
   - Available for caching or Celery (Celery services commented out in docker-compose.yml)

### Nginx Protected File Serving

The nginx configuration supports X-Accel-Redirect for serving protected files:
- `/protected/files/` and `/protected/images/` are marked as `internal`
- Django can return `X-Accel-Redirect` headers to authorize nginx to serve protected content
- Regular media files are served directly from `/media/files/` and `/media/images/`

Configuration: `nginx/nginx.conf`

### Template-based Initialization

The `start.sh` script uses a GitHub template to scaffold Django projects:
- Template URL: `https://github.com/alkelaun/project_name/archive/refs/heads/master.zip`
- Runs `django-admin startproject --template <url>` inside a temporary container
- Uses user/group ID mapping to avoid permission issues

## Configuration

### Environment Variables
Set in `.env` file (referenced by docker-compose.yml):
- `PYTHON_VERSION`: Python Docker image version (default: 3-slim-bookworm)
- `REQUIREMENTS_FILE`: Requirements file to install (default: requirements.txt)

### Python Dependencies
Requirements are managed in `project/requirements.txt` and copied to root during setup.

### Docker Build Arguments
The Dockerfile accepts build args from .env:
- `PYTHON_VERSION`
- `REQUIREMENTS_FILE`
