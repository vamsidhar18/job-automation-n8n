#!/bin/bash

# n8n v1.68+ startup script for Ubuntu + Playwright job automation
echo "🚀 Starting n8n v1.68+ with full Playwright support..."

# Memory optimization for Railway Pro
export NODE_OPTIONS="--max-old-space-size=4096"

# n8n Core Configuration
export N8N_HOST=0.0.0.0
export N8N_PORT=${PORT:-5678}
export N8N_PROTOCOL=https
export WEBHOOK_URL=https://${RAILWAY_STATIC_URL}

# n8n Authentication (v1.68+)
export N8N_USER_MANAGEMENT_DISABLED=false
export N8N_OWNER_EMAIL=${N8N_OWNER_EMAIL:-vdr1800@gmail.com}
export N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-$(openssl rand -hex 32 2>/dev/null || echo "default-key-change-in-production")}

# Database Configuration (SQLite for simplicity)
export DB_TYPE=sqlite
export DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
export DB_SQLITE_VACUUM_ON_STARTUP=true

# Execution Settings for High Volume Job Automation
export EXECUTIONS_PROCESS=main
export EXECUTIONS_MODE=regular
export EXECUTIONS_TIMEOUT=3600
export EXECUTIONS_MAX_TIMEOUT=7200
export EXECUTIONS_DATA_SAVE_ON_ERROR=all
export EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
export EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true

# Performance Optimization
export N8N_LOG_LEVEL=warn
export N8N_LOG_OUTPUT=console
export EXECUTIONS_DATA_PRUNE=true
export EXECUTIONS_DATA_MAX_AGE=168
export N8N_METRICS=true

# Security Settings
export N8N_SECURE_COOKIE=true
export N8N_COOKIES_SECURE=true
export N8N_JWT_AUTH_HEADER=authorization
export N8N_JWT_AUTH_HEADER_VALUE_PREFIX="Bearer "

# Job Automation Specific Settings
export N8N_DEFAULT_LOCALE=en
export GENERIC_TIMEZONE=America/New_York
export TZ=America/New_York

# Browser Automation Settings (Ubuntu + Playwright)
export PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=false
export DISPLAY=:99

# Concurrency for massive job applications
export N8N_CONCURRENCY_PRODUCTION=100

# External Services Integration
export N8N_EXTERNAL_FRONTEND_HOOKS_URLS=${WEBHOOK_URL}

echo "✅ n8n v1.68+ configured for massive job automation"
echo "🌐 n8n URL: ${WEBHOOK_URL}"
echo "📧 Owner Email: ${N8N_OWNER_EMAIL}"
echo "🔧 Database: SQLite"
echo "🎭 Browsers: Playwright (Chromium + Firefox + Webkit)"
echo "🎯 Max Concurrent Jobs: 100"

# Initialize n8n database if first run
if [ ! -f "/home/node/.n8n/database.sqlite" ]; then
    echo "📦 Initializing n8n database..."
    n8n db:migrate
fi

# Start virtual display for browsers (Ubuntu requirement)
if command -v Xvfb >/dev/null 2>&1; then
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    echo "🖥️  Virtual display started"
fi

echo "🚀 Starting n8n with full Playwright support..."

# Start n8n with job automation focus
exec n8n start
