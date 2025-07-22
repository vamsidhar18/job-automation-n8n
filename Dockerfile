# n8n + Playwright on Ubuntu base for Railway Pro compatibility
FROM ubuntu:22.04

# Install Node.js and system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    xvfb \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install n8n
RUN npm install -g n8n@1.68.0

# Install Playwright and browsers (Ubuntu native support)
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    @playwright/test

# Install Playwright browsers with dependencies (this works on Ubuntu!)
RUN npx playwright install --with-deps chromium firefox webkit

# Create n8n user and directories
RUN useradd -m -s /bin/bash node
USER node
WORKDIR /home/node

RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials

# Copy configuration files to the correct path
COPY --chown=node:node n8n-config.json /home/node/.n8n/config/
COPY --chown=node:node fallback-jobs.json /home/node/.n8n/
COPY --chown=node:node start-n8n-latest.sh /home/node/

# Make startup script executable
USER root
RUN chmod +x /home/node/start-n8n-latest.sh
USER node

# Environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_STEALTH=true
ENV PUPPETEER_STEALTH=true
ENV DISPLAY=:99

# Health check - use n8n's default health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s \
  CMD curl -f http://localhost:${PORT:-5678}/ || exit 1

EXPOSE $PORT

CMD ["/home/node/start-n8n-latest.sh"]
