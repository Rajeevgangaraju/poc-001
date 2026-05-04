FROM python:3.11-alpine
# Install build dependencies for certain python packages
RUN apk add --no-cache gcc musl-dev linux-headers
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Delete the venv if it accidentally got copied
RUN rm -rf venv
EXPOSE 8000
CMD ["python", "app.py"]
