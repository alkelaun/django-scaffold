#!/bin/bash

# Define variables
# The GitHub template URL is still a fixed value
GITHUB_TEMPLATE_URL="https://github.com/alkelaun/project_name/archive/refs/heads/master.zip"
#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
PROJECT_NAME="my_django_project"
PYTHON_VERSION="3.11"
REQUIREMENTS_FILE="requirements.txt"
TEMPLATE_DIR="./django_docker_template" # Directory containing your Docker files

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
cd $PROJECT_NAME

echo "--- Copying Docker files from template directory... ---"
cp "$TEMPLATE_DIR/Dockerfile" .
cp "$TEMPLATE_DIR/docker-compose.yml" .

echo "--- Creating requirements.txt... ---"
cat << EOF > $REQUIREMENTS_FILE
Django
EOF

echo "--- Running django-admin inside a temporary container... ---"
docker run --rm -v "$(pwd)":/usr/src/app python:$PYTHON_VERSION /bin/bash -c "pip install django && django-admin startproject $PROJECT_NAME ."

echo "--- Building and running containers... ---"
docker-compose up --build -d

echo "--- Setup complete! ---"
echo "Your Django project '$PROJECT_NAME' is running inside a Docker container."
echo "You can access it at http://localhost:8000"
echo "To stop the containers, run 'docker-compose down' from the '$PROJECT_NAME' directory."
