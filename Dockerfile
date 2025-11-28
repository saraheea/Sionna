# Use TensorFlow GPU base image
FROM tensorflow/tensorflow:2.14.0-gpu

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3.11 \
    python3.11-dev

# Set working directory
WORKDIR /app

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
    tensorflow==2.14.0 \
    numpy==1.26.4 \
    scipy>=1.14.1 \
    matplotlib>=3.10 \
    importlib_resources>=6.4.5 \
    sionna

# Create test program to check versions and available devices
RUN echo 'import tensorflow as tf\n\
import sionna\n\
print("TensorFlow version:", tf.__version__)\n\
print("Sionna version:", sionna.__version__)\n\
print("GPU Available: ", tf.config.list_physical_devices("GPU"))\n\
print("All Devices: ", tf.config.list_physical_devices())' > test_sionna.py

# Define the command to run when container starts
CMD ["python", "test_sionna.py"]
