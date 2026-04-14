# WiFi Diagnostic Tool Makefile
# Usage: make [target]

.PHONY: help build install test clean run scan status repair

# Default target
help:
@echo "Available targets:"
@echo "  build      - Build the project with Stack"
@echo "  install    - Install the binary locally"
@echo "  test       - Run unit tests"
@echo "  clean      - Clean build artifacts"
@echo "  run        - Run in interactive mode"
@echo "  scan       - Scan available networks"
@echo "  status     - Show network status"
@echo "  repair     - Run automatic repair"
@echo "  docker     - Build Docker image"
@echo "  docker-run - Run in Docker container"
@echo "  fmt        - Format Haskell code"
@echo "  lint       - Run HLint"
@echo "  pre-commit - Install pre-commit hooks"

# Build the project
build:
stack build

# Install binary
install:
stack install

# Run tests
test:
stack test

# Clean build artifacts
clean:
stack clean
rm -rf .stack-work

# Run interactive mode
run:
stack run

# Scan networks
scan:
stack run -- --scan

# Show status
status:
stack run -- --status

# Run repair
repair:
stack run -- --repair

# Docker build
docker:
docker build -t haskell-wifi .

# Docker run
docker-run:
docker run -it --rm --privileged --network host haskell-wifi

# Format code (requires fourmolu)
fmt:
fourmolu -i app/**/*.hs src/**/*.hs test/**/*.hs

# Lint code
lint:
hlint src app test

# Install pre-commit hooks
pre-commit:
pre-commit install

# Check for updates
update:
stack update
stack upgrade

# Generate documentation
docs:
stack haddock

# Run all checks (CI)
ci: lint test build
@echo "All checks passed!"
