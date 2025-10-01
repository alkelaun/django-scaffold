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
        echo "Docker is not installed. Please install it to continue."
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose is not installed. Please install it to continue."
        exit 1
    fi
}

# --- Main Script ---

echo "--- Checking dependencies... ---"
check_dependencies

# Check if the template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory '$TEMPLATE_DIR' not found."
    exit 1
fi

echo "--- Creating Django project structure... ---"
mkdir -p $PROJECT_NAME


echo "--- Copying Docker files from template directory... ---"
cp "$TEMPLATE_DIR/Dockerfile" .
cp "$TEMPLATE_DIR/docker-compose.yml" .
cp "$TEMPLATE_DIR/.env" .

cd $PROJECT_NAME

echo "--- Creating requirements.txt... ---"
cat << EOF > $REQUIREMENTS_FILE
Django
EOF

echo "--- Running django-admin inside a temporary container... ---"
USER_ID=$(id -u)
GROUP_ID=$(id -g)

docker run --rm -it \
    --user $USER_ID:$GROUP_ID \
    -v "$(pwd)":/usr/src/app \
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

echo "--- Building and running containers... ---"
cp requirements.txt ../requirements.txt
docker compose --build --force-recreate 

echo "--- Setup complete! ---"
echo "Your Django project '$PROJECT_NAME' is running inside a Docker container."
echo "You can access it at http://localhost:8000"
echo "To stop the containers, run 'docker-compose down' from the '$PROJECT_NAME' directory."

