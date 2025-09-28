# Use an official Python runtime as a parent image
FROM python:$PYTHON_VERSION

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
COPY ./$REQUIREMENTS_FILE .
RUN pip install --upgrade pip
RUN pip install -r ./$REQUIREMENTS_FILE

# Copy the rest of the application
COPY . .

# Run the command to start the development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
