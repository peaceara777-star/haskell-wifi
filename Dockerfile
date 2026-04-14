# WiFi Diagnostic Tool Docker Image
# Multi-stage build for optimal size

FROM haskell:9.8-slim AS builder

WORKDIR /build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    network-manager \
    rfkill \
    && rm -rf /var/lib/apt/lists/*

# Copy package definitions
COPY package.yaml stack.yaml ./

# Copy source code
COPY src/ ./src/
COPY app/ ./app/
COPY test/ ./test/

# Build the project
RUN stack build --system-ghc --copy-bins

# Prepare the binary
RUN stack install --local-bin-path /output

# Runtime stage
FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="WiFi Diagnostic Tool"
LABEL org.opencontainers.image.description="Professional WiFi Diagnostic and Repair Tool in Haskell"
LABEL org.opencontainers.image.source="https://github.com/peaceara777-star/haskell-wifi"
LABEL org.opencontainers.image.licenses="MIT"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    network-manager \
    rfkill \
    iputils-ping \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /output/wifi-diagnostic /usr/local/bin/

# Create non-root user
RUN useradd -m -u 1000 wifi-user
USER wifi-user
WORKDIR /home/wifi-user

# Default command
ENTRYPOINT ["wifi-diagnostic"]
CMD ["--help"]
