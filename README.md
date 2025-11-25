# Sionna Setup Guide

## Section 1: Overview

- **What is Sionna?**: Sionna is NVIDIA's open-source toolkit for wireless communications research built on TensorFlow.
- **GitHub Repository**: [https://github.com/nvlabs/sionna](https://github.com/nvlabs/sionna)
- **System Requirements**:
  - Python 3.10-3.12
  - TensorFlow 2.14-2.19
  - GPU support recommended

## Section 2: EC2 Setup (Recommended Method)

### 1. AWS Configuration

```bash
# AMI Selection
# Deep Learning OSS Nvidia Driver AMI GPU TensorFlow 2.18 (Amazon Linux 2023)

# Instance Type
# g4dn.xlarge (NVIDIA T4 GPU)
```

### 2. Initial Setup

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install NVIDIA Container Toolkit
#distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

#sudo yum install -y nvidia-container-toolkit
#sudo nvidia-ctk runtime configure --runtime=docker
#sudo systemctl restart docker
```

### 3. Docker Configuration

```dockerfile
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
```

### 4. Build and Run

```bash
# Build Docker image
docker build -t sionna-test .

# Run with GPU support
docker run --gpus all sionna-test
```

## Section 3: Alternative Method - Local Development (Reference)

### Platform Considerations

When developing locally and transferring to EC2, be aware of architecture differences:
- Local ARM64 (Apple Silicon) vs EC2 AMD64
- Image compatibility issues
- Platform-specific builds required

### Local Development Steps

```bash
# Build for AMD64 (EC2) on Apple Silicon
docker buildx create --use
docker buildx build --platform linux/amd64 -t sionna-test .

# Save and transfer image
docker save sionna-test > sionna-test.tar
scp -i my-keypair.pem sionna-test.tar ec2-user@[EC2-IP]:~
```

### Common Issues

#### Platform Mismatch

```bash
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64)
```

**Solution**: Use platform-specific build commands

#### GPU Access

```bash
# Check GPU availability
nvidia-smi
docker run --gpus all sionna-test
```

#### Docker Permission Issues

```bash
# Add user to docker group
sudo usermod -a -G docker ec2-user
```

## Section 4: Verification

```bash
# Expected Output
GPU Available: [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
All Devices: [PhysicalDevice(name='/physical_device:CPU:0', device_type='CPU'),
              PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
```

This guide provides both recommended (EC2-direct) and alternative (local-to-EC2) setup methods for Sionna, with considerations for different architectures and common troubleshooting steps.
