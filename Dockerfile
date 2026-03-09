# Custom ZeroClaw image with CLI tools and Docker CLI
ARG ZEROCLAW_VERSION=v0.1.7
FROM ghcr.io/zeroclaw-labs/zeroclaw:${ZEROCLAW_VERSION} AS original

FROM debian:trixie-slim

# Install runtime dependencies and Docker CLI
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    bash \
    jq \
    gnupg \
    lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary and data from the original image
COPY --from=original /usr/local/bin/zeroclaw /usr/local/bin/zeroclaw
COPY --from=original /zeroclaw-data /zeroclaw-data

# Set environment variables
ENV ZEROCLAW_WORKSPACE=/zeroclaw-data/workspace
ENV HOME=/zeroclaw-data
ENV SHELL=/bin/bash

WORKDIR /zeroclaw-data
# Run as root to have permission to use /var/run/docker.sock
USER root
EXPOSE 42617
ENTRYPOINT ["zeroclaw"]
CMD ["gateway"]
