FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# We split this to ensure software-properties-common is installed before add-apt-repository
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    git-lfs \
    wget \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

# Add Python 3.8 PPA
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.8
RUN wget https://bootstrap.pypa.io/pip/3.8/get-pip.py && \
    python3.8 get-pip.py && \
    rm get-pip.py

# Set python3.8 as default python
RUN ln -s /usr/bin/python3.8 /usr/bin/python

# Install PyTorch and dependencies
# We install torch first to ensure the correct cuda version is picked up
RUN pip install --no-cache-dir torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu118

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire repository
COPY . /app

# Install customized 'Forward-Warp' package
WORKDIR /app/dependency/Forward-Warp
RUN chmod +x install.sh && ./install.sh

WORKDIR /app