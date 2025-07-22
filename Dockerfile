# Base image with Node and Ubuntu for Playwright compatibility
FROM mcr.microsoft.com/playwright:v1.43.1-jammy

# Set working directory
WORKDIR /home/node

# Install core dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    wget \
    sqlite3 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install n8n globally
RUN npm install -g n8n

# Install playwright browsers
RUN npx playwright install --with-deps

# Add n8n config directory and set permissions
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# ADDED: Copy the n8n-config.json file so its settings are applied
COPY n8n-config.json /home/node/.n8n/config.json

# Copy your startup script
COPY start-n8n-latest.sh /usr/local/bin/start-n8n
RUN chmod +x /usr/local/bin/start-n8n

# Switch to node user for security
USER node

# Expose default n8n port
EXPOSE 5678

# CORRECTED: Healthcheck now points to the /healthz endpoint
# This fixes the error by using the dedicated health check URL
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=6 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n via custom script (job automation optimized)
ENTRYPOINT ["/usr/local/bin/start-n8n"]
