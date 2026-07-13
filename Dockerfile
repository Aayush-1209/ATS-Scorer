FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
# - build-essential, libffi-dev: for compiling C extensions
# - libpango-1.0-0, libharfbuzz0b, libpangoft2-1.0-0: for WeasyPrint
# - libmagic1: for python-magic (file type detection)
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libmagic1 \
    libpango-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies (filtering out frontend packages to save space)
RUN grep -v -E "streamlit|requests|supabase" requirements.txt > backend-requirements.txt && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r backend-requirements.txt

# Spacy has been removed from this project to save image space

# Copy the rest of the application code
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Expose the application port
EXPOSE 8000

# Run the FastAPI application using uvicorn
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
