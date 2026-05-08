FROM python:3.11-alpine

# Set working directory inside the container
WORKDIR /app

# Copy dependency list first (best practice)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application file into /app
COPY app.py .

# Expose Flask port
EXPOSE 8000

# Start the application
CMD ["python", "app.py"]
