# Base image with Node and Ubuntu for Playwright compatibility
FROM mcr.microsoft.com/playwright:v1.43.1-jammy

# Set working directory
WORKDIR /home/pwuser

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
# CORRECTED: Run as pwuser to install in the correct home directory
USER pwuser
RUN npx playwright install --with-deps
USER root

# Add n8n config directory and set permissions
# CORRECTED: Changed owner from 'node:node' to 'pwuser:pwuser'
RUN mkdir -p /home/pwuser/.n8n && chown -R pwuser:pwuser /home/pwuser/.n8n

# Copy the n8n-config.json file so its settings are applied
# CORRECTED: Changed destination owner to 'pwuser:pwuser'
COPY --chown=pwuser:pwuser n8n-config.json /home/pwuser/.n8n/config.json

# Copy your startup script
COPY start-n8n-latest.sh /usr/local/bin/start-n8n
RUN chmod +x /usr/local/bin/start-n8n

# Switch to the correct non-root user for security
# CORRECTED: Changed user from 'node' to 'pwuser'
USER pwuser

# Set home directory for n8n
ENV HOME=/home/pwuser

# Expose default n8n port
EXPOSE 5678

# Healthcheck for Railway (ensures service is reachable)
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=6 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n via custom script (job automation optimized)
ENTRYPOINT ["/usr/local/bin/start-n8n"]
