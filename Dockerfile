# Use TensorFlow GPU base image
# FROM --platform=linux/arm64 tensorflow/tensorflow:2.14.0-gpu

# Base image optimized for Apple Silicon(ARM64)
FROM python:3.11-slim

# Install necessary packages
RUN apt-get update && apt-get install -y git build-essential python3-dev

# Set working directory
WORKDIR /app

# Install Python packages
RUN pip install --upgrade pip
RUN pip install tensorflow==2.14.0 \
	numpy==1.26.4 \
	scipy>=1.41.1 \
	matplotlib>=3.10 \
	importlib_resources>=6.4.5

# Copy local Sionna source code to container
COPY sionna/ /app/sionna/

# Install Sionna
RUN cd sionna && pip install sionna

# Copy test program
COPY test_sionna.py .

# Modify test program content (test_sionna.py)
RUN echo 'import tensorflow as tf\n\
import sionna\n\
print("TensorFlow version:", tf.__version__)\n\
print("Sionna version:", sionna.__version__)\n\
devices = tf.config.list_physical_devices()\n\
print("Available devices:", devices)' > test_sionna.py

# Command to run when container starts
CMD ["python", "test_sionna.py"]

