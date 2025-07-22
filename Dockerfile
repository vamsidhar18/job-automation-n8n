# Base image with Node and Ubuntu for Playwright compatibility
FROM mcr.microsoft.com/playwright:v1.43.1-jammy

# Set working directory
WORKDIR /app

# All commands run as 'root' by default from here
# Install core dependencies, n8n, and playwright with its system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    wget \
    sqlite3 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g n8n

# CORRECTED: Run playwright install as root to allow system dependency installation
RUN npx playwright install --with-deps

# Create the home and config directory for the non-root user 'pwuser'
# The 'pwuser' is created by the base image
RUN mkdir -p /home/pwuser/.n8n && chown -R pwuser:pwuser /home/pwuser

# Copy config files and set ownership to the non-root user
COPY --chown=pwuser:pwuser n8n-config.json /home/pwuser/.n8n/config.json
COPY start-n8n-latest.sh /usr/local/bin/start-n8n
RUN chmod +x /usr/local/bin/start-n8n

# NOW we switch to the non-root user for security
USER pwuser

# Set user's home directory for n8n and other tools
ENV HOME=/home/pwuser
WORKDIR /home/pwuser

# Expose default n8n port
EXPOSE 5678

# Healthcheck for Railway (ensures service is reachable)
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=6 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n via custom script
ENTRYPOINT ["/usr/local/bin/start-n8n"]
