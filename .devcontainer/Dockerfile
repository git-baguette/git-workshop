# Go development environment
FROM mcr.microsoft.com/devcontainers/go:1-1.23-bookworm

# Install additional tools
RUN go install github.com/googlecodelabs/tools/claat@latest

# Set the working directory
WORKDIR /workspace

# Expose the default port
EXPOSE 8080

# Start the claat server
CMD ["claat", "serve"]