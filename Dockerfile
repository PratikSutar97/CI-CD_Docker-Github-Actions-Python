# -------- Stage 1: Build dependencies --------
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system deps for building Python wheels (if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements for better layer caching
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# -------- Stage 2: Final runtime image --------
FROM python:3.11-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Copy installed dependencies from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages \
     /usr/local/lib/python3.11/site-packages

# Copy application code
COPY app/ .

# Expose Flask port
EXPOSE 5000

USER appuser

# Start app
CMD ["python", "app.py"]

