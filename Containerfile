# Pin ESPHome release
FROM ghcr.io/esphome/esphome:2025.11.4

# Install development tools using apt (not apk)
RUN apt-get update && apt-get install -y --no-install-recommends \
    age \
    git \
    bash \
    make \
    gcc \
    g++

# Create a workspace dir inside the container
RUN mkdir -p /workspace

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sh"]

