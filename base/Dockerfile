# Use an official Python image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . /app

# Install dependencies from requirements.txt
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 (Flask default)
EXPOSE 5000

# Define the command to run the app
CMD ["python", "app.py"]