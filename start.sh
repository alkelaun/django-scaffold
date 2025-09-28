#!/bin/bash

# Define variables
PROJECT_NAME="myproject"
APP_NAME="myapp"
GITHUB_TEMPLATE_URL="https://github.com/alkelaun/project_name.git"

# --- Function to check if a command exists ---
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# --- Step 1: Install uv if not already present ---
if ! command_exists uv ; then
    echo "➡️ uv not found. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for the current session
    export PATH="$HOME/.cargo/bin:$PATH"
    if ! command_exists uv ; then
        echo "❌ Failed to install uv. Please ensure curl is installed and you have write permissions to your home directory."
        exit 1
    fi
else
    echo "✅ uv is already installed."
fi

# --- Step 2: Create a virtual environment with uv ---
echo "➡️ Creating a new virtual environment with uv..."
uv venv

# Activate the virtual environment. This is good practice for the script's scope.
# The 'uv run' command does not require activation, but this ensures a clean context.
source .venv/bin/activate

# --- Step 3: Install Django into the new environment ---
echo "➡️ Installing Django into the virtual environment..."
uv pip install Django

# --- Step 4: Clone the template from GitHub ---
echo "➡️ Cloning Django template from GitHub..."
git clone "$GITHUB_TEMPLATE_URL" "$PROJECT_NAME"

# Check if cloning was successful
if [ ! -d "$PROJECT_NAME" ]; then
    echo "❌ Failed to clone the repository. Check the URL and try again."
    exit 1
fi

cd "$PROJECT_NAME"

# --- Step 5: Install necessary packages from requirements.txt using uv ---
echo "➡️ Installing dependencies from requirements.txt..."
if [ -f "requirements.txt" ]; then
    uv pip install -r requirements.txt
else
    echo "⚠️ requirements.txt not found. Skipping package installation."
fi

# --- Step 6: Create the new Django app using the cloned project as a template ---
echo "➡️ Creating new Django app using the template..."
# 'uv run' executes the command within the virtual environment
uv run django-admin startapp "$APP_NAME" .

echo "✅ All done! Your Django project '$PROJECT_NAME' and app '$APP_NAME' are ready."
echo "   Navigate to the directory: cd $PROJECT_NAME"
echo "   To run the server: uv run python manage.py runserver"
