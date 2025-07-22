# Base Ubuntu image with Node.js (Ubuntu 22.04 LTS + Node 18)
FROM node:18-bullseye-slim

# Set environment variables
ENV N8N_VERSION=1.68.0
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and browsers
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    bash \
    git \
    ca-certificates \
    chromium \
    chromium-driver \
    libgtk-3-0 \
    libxss1 \
    libasound2 \
    libnss3 \
    libxshmfence-dev \
    libgbm-dev \
    fonts-liberation \
    libappindicator3-1 \
    wget \
    unzip \
    python3 \
    python3-pip \
    xvfb \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install n8n
RUN npm install -g n8n@${N8N_VERSION}

# Install Playwright and Puppeteer tools globally
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    @playwright/test && \
    npx playwright install chromium firefox webkit

# Create n8n working directory
RUN mkdir -p /home/node/.n8n
WORKDIR /home/node

# Add configuration and fallback files
COPY n8n-config.json /home/node/.n8n/config/
COPY fallback-jobs.json /home/node/.n8n/

# Add start script
COPY start-n8n-latest.sh /home/node/
RUN chmod +x /home/node/start-n8n-latest.sh

# Healthcheck for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:${PORT:-5678}/ || exit 1

# Expose n8n port
EXPOSE ${PORT:-5678}

# Start n8n
CMD ["/home/node/start-n8n-latest.sh"]
