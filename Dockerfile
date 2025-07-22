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
    netcat \
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
RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials \
    && mkdir -p /home/node/.n8n/config \
    && chown -R node:node /home/node

# Copy configuration files BEFORE switching user
COPY n8n-config.json /home/node/.n8n/config/
COPY fallback-jobs.json /home/node/.n8n/
COPY start-n8n-latest.sh /home/node/

# Fix ownership and permissions
RUN chown -R node:node /home/node && \
    chmod +x /home/node/start-n8n-latest.sh

# Switch to node user
USER node
WORKDIR /home/node

# Environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_STEALTH=true
ENV PUPPETEER_STEALTH=true
ENV DISPLAY=:99

EXPOSE $PORT

CMD ["/home/node/start-n8n-latest.sh"]
