#!/bin/bash

# Define variables
# The GitHub template URL is still a fixed value
GITHUB_TEMPLATE_URL="https://github.com/alkelaun/project_name/archive/refs/heads/master.zip"

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
PROJECT_NAME="project"
PYTHON_VERSION="3.13-slim-bookworm"
REQUIREMENTS_FILE="requirements.txt"
TEMPLATE_DIR="./docker" # Directory containing your Docker files

# --- Function to check for dependencies ---
check_dependencies() {
    if ! command -v docker &> /dev/null
    then
        echo "Error: Docker is not installed. Please install it to continue."
        exit 1
    fi
    if ! command -v docker compose &> /dev/null
    then
        echo "Error: Docker Compose is not installed. Please install it to continue."
        exit 1
    fi
}

# --- Function to cleanup existing containers ---
cleanup_containers() {
    echo "--- Cleaning up existing containers... ---"
    # Stop and remove containers if they exist
    docker compose down 2>/dev/null || true
    docker rm -f django_web django_nginx redis_broker 2>/dev/null || true
}

# --- Main Script ---

echo "--- Checking dependencies... ---"
check_dependencies

# Check if the template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory '$TEMPLATE_DIR' not found."
    exit 1
fi

# Cleanup existing containers
cleanup_containers

# Check if project already exists
if [ -f "manage.py" ]; then
    echo "--- Django project already exists, skipping initialization... ---"
    echo "--- Building and running containers... ---"
    docker compose up -d --build
    echo "--- Setup complete! ---"
    echo "Your Django project '$PROJECT_NAME' is running at http://localhost"
    exit 0
fi

echo "--- Creating Django project structure... ---"
mkdir -p $PROJECT_NAME

echo "--- Copying Docker files from template directory... ---"
cp "$TEMPLATE_DIR/Dockerfile" .
cp "$TEMPLATE_DIR/docker-compose.yml" .
cp "$TEMPLATE_DIR/.env" .
cp "$TEMPLATE_DIR/Makefile" . 2>/dev/null || echo "Warning: Makefile not found in template directory"

echo "--- Creating temporary requirements.txt... ---"
cat << EOF > $PROJECT_NAME/$REQUIREMENTS_FILE
Django
EOF

echo "--- Running django-admin inside a temporary container... ---"
USER_ID=$(id -u)
GROUP_ID=$(id -g)

docker run --rm \
    --user $USER_ID:$GROUP_ID \
    -v "$(pwd)/$PROJECT_NAME":/usr/src/app \
    -w /usr/src/app \
    python:3.13-slim-bookworm /bin/bash -c "
        # 1. Define a writable installation directory inside the container
        INSTALL_DIR=/tmp/pip-target;
        mkdir -p \$INSTALL_DIR;

        # 2. Add the /bin folder to PATH (for the executable: django-admin)
        export PATH=\$INSTALL_DIR/bin:\$PATH;

        # 3. Add the target folder to PYTHONPATH (for the module code: import django)
        export PYTHONPATH=\$INSTALL_DIR:\$PYTHONPATH;

        # 4. Install Django to the writable directory
        pip install --target \$INSTALL_DIR django &&

        # 4A move the requirements.txt file
        mv requirements.txt requirements.txt.bak &&

        # 5. Create the project files
        django-admin startproject --template $GITHUB_TEMPLATE_URL $PROJECT_NAME .
"

echo "--- Restructuring project files... ---"
# Move Django project files to root and clean up nested structure
mv $PROJECT_NAME/* . 2>/dev/null || true
mv $PROJECT_NAME/.* . 2>/dev/null || true

# Fix nested project directory if it exists
if [ -d "$PROJECT_NAME/$PROJECT_NAME" ]; then
    mv $PROJECT_NAME/$PROJECT_NAME/* $PROJECT_NAME/ 2>/dev/null || true
    rmdir $PROJECT_NAME/$PROJECT_NAME 2>/dev/null || true
fi

# Remove empty project directory
rmdir $PROJECT_NAME 2>/dev/null || true

# Copy requirements to root for Docker build
cp requirements.txt ./requirements.txt 2>/dev/null || echo "Django" > requirements.txt

echo "--- Building and running containers... ---"
docker compose up -d --build

echo "--- Running initial migrations... ---"
sleep 5  # Wait for containers to be ready
docker compose exec django python manage.py migrate

echo ""
echo "==================================================================="
echo "--- Setup complete! ---"
echo "Your Django project '$PROJECT_NAME' is running at http://localhost"
echo ""
echo "Useful commands:"
echo "  docker compose logs -f       # View logs"
echo "  docker compose down          # Stop containers"
echo "  docker compose up -d         # Start containers"
echo "  make help                    # See all available commands"
echo "==================================================================="

