# Use an official Python runtime as a parent image
ARG PYTHON_VERSION
ARG REQUIREMENTS_FILE
FROM python:3.13-slim-bookworm

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of the application
COPY . .

# Run the command to start the development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
