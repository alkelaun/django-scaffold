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
    # Add uv to PATH for the current session and future sessions
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    if ! command_exists uv ; then
        echo "❌ Failed to install uv. Please ensure curl is installed and you have write permissions to your home directory."
        exit 1
    fi
else
    echo "✅ uv is already installed."
fi

---
### Step 2: Create a new virtual environment
echo "➡️ Creating a new virtual environment with uv..."
uv venv

# Activate the virtual environment
source .venv/bin/activate

---
### Step 3: Install Django and clone the template
echo "➡️ Installing Django into the new environment..."
uv pip install Django

echo "➡️ Cloning Django template from GitHub..."
git clone "$GITHUB_TEMPLATE_URL" "$PROJECT_NAME"

# Check if cloning was successful
if [ ! -d "$PROJECT_NAME" ]; then
    echo "❌ Failed to clone the repository. Check the URL and try again."
    exit 1
fi

cd "$PROJECT_NAME"

---
### Step 4: Install dependencies and set up the project
echo "➡️ Installing dependencies from requirements.txt..."
if [ -f "requirements.txt" ]; then
    uv pip install -r requirements.txt
else
    echo "⚠️ requirements.txt not found. Skipping package installation."
fi

echo "➡️ Creating new Django app using the template..."
django-admin startapp "$APP_NAME" .

echo "✅ All done! Your Django project '$PROJECT_NAME' and app '$APP_NAME' are ready."
echo "   Navigate to the directory: cd $PROJECT_NAME"
echo "   To run the server: python manage.py runserver"
