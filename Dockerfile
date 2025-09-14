# Dockerfile for Idle Adventurer development environment
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xvfb \
    x11vnc \
    fluxbox \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Godot 4.2
RUN wget -q https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip \
    && unzip Godot_v4.2.1-stable_linux.x86_64.zip \
    && mv Godot_v4.2.1-stable_linux.x86_64 /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm Godot_v4.2.1-stable_linux.x86_64.zip

# Install pre-commit
RUN pip3 install pre-commit

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . .

# Install pre-commit hooks
RUN pre-commit install

# Set display for headless operation
ENV DISPLAY=:99

# Create entrypoint script
RUN echo '#!/bin/bash\n\
    Xvfb :99 -screen 0 1024x768x24 &\n\
    fluxbox &\n\
    exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
