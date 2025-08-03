#!/bin/bash

# Multi-Site Creation Script
# Creates new site branches with custom configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <site-name> <domain> [options]"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "  --theme <primary> <secondary>    Custom theme colors"
    echo "  --logo <emoji>                   Custom logo emoji"
    echo "  --title <title>                  Custom page title"
    echo "  --messages <file>                Custom messages file"
    echo "  --help                           Show this help"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 mysite mysite.com"
    echo "  $0 startup startup.com --theme '#ff6b6b' '#4ecdc4'"
    echo "  $0 tech tech.com --logo '💻' --title 'Tech Coming Soon'"
}

# Function to validate domain
validate_domain() {
    local domain="$1"
    if [[ ! "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}❌ Invalid domain format: $domain${NC}"
        exit 1
    fi
}

# Function to create site configuration
create_site_config() {
    local site_name="$1"
    local domain="$2"
    local primary_color="${3:-#667eea}"
    local secondary_color="${4:-#764ba2}"
    local logo="${5:-🚀}"
    local title="${6:-Coming Soon}"
    
    # Create site configuration
    cat > "sites/$site_name.json" << EOF
{
  "site_name": "$site_name",
  "domain": "$domain",
  "theme": {
    "primary": "$primary_color",
    "secondary": "$secondary_color"
  },
  "branding": {
    "logo": "$logo",
    "title": "$title"
  },
  "messages": [
    "Something amazing is brewing...",
    "Loading awesome things...",
    "Preparing to blow your mind...",
    "Assembling the dream team...",
    "Cooking up something special...",
    "Almost ready to launch...",
    "Adding the final touches...",
    "Making it perfect for you...",
    "Gathering the best ideas...",
    "Building the future..."
  ],
  "features": [
    {
      "icon": "⚡",
      "text": "Lightning Fast"
    },
    {
      "icon": "🎯",
      "text": "Purpose Built"
    },
    {
      "icon": "🌟",
      "text": "Game Changing"
    }
  ],
  "social_links": {
    "twitter": "#",
    "linkedin": "#",
    "github": "#"
  },
  "analytics": {
    "enabled": false,
    "tracking_id": ""
  }
}
EOF
}

# Function to create site-specific files
create_site_files() {
    local site_name="$1"
    local config_file="sites/$site_name.json"
    
    # Create sites directory if it doesn't exist
    mkdir -p sites
    
    # Create site-specific HTML
    cat > "sites/$site_name.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{SITE_TITLE}}</title>
    <meta name="description" content="Something amazing is coming soon. Stay tuned for updates!">
    <link rel="stylesheet" href="../styles.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>{{SITE_LOGO}}</text></svg>">
    <style>
        :root {
            --primary-color: {{PRIMARY_COLOR}};
            --secondary-color: {{SECONDARY_COLOR}};
        }
        body {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="content">
            <div class="logo">
                <span class="emoji">{{SITE_LOGO}}</span>
            </div>
            
            <h1 class="title">{{SITE_TITLE}}</h1>
            
            <div class="message-container">
                <p class="message" id="message">Something amazing is brewing...</p>
                <div class="loading-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
            
            <div class="progress-container">
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
                <p class="progress-text">Loading awesome things...</p>
            </div>
            
            <div class="features">
                <div class="feature">
                    <span class="feature-icon">{{FEATURE_1_ICON}}</span>
                    <span class="feature-text">{{FEATURE_1_TEXT}}</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">{{FEATURE_2_ICON}}</span>
                    <span class="feature-text">{{FEATURE_2_TEXT}}</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">{{FEATURE_3_ICON}}</span>
                    <span class="feature-text">{{FEATURE_3_TEXT}}</span>
                </div>
            </div>
            
            <div class="newsletter">
                <h3>Want to be first to know?</h3>
                <form class="email-form" id="emailForm">
                    <input type="email" placeholder="Enter your email" required>
                    <button type="submit">Notify Me</button>
                </form>
                <p class="form-note">No spam, just awesome updates!</p>
            </div>
            
            <div class="social-links">
                <a href="{{SOCIAL_TWITTER}}" class="social-link" title="Twitter">
                    <span>🐦</span>
                </a>
                <a href="{{SOCIAL_LINKEDIN}}" class="social-link" title="LinkedIn">
                    <span>💼</span>
                </a>
                <a href="{{SOCIAL_GITHUB}}" class="social-link" title="GitHub">
                    <span>🐙</span>
                </a>
            </div>
        </div>
        
        <div class="background-animation">
            <div class="floating-element" style="--delay: 0s">✨</div>
            <div class="floating-element" style="--delay: 2s">💡</div>
            <div class="floating-element" style="--delay: 4s">🎉</div>
            <div class="floating-element" style="--delay: 6s">🔥</div>
            <div class="floating-element" style="--delay: 8s">🚀</div>
        </div>
    </div>
    
    <script src="../script.js"></script>
    <script>
        // Load site-specific configuration
        fetch('../sites/{{SITE_NAME}}.json')
            .then(response => response.json())
            .then(config => {
                // Update messages
                if (config.messages && config.messages.length > 0) {
                    window.siteMessages = config.messages;
                }
                
                // Update analytics
                if (config.analytics && config.analytics.enabled && config.analytics.tracking_id) {
                    // Add Google Analytics
                    const script = document.createElement('script');
                    script.src = `https://www.googletagmanager.com/gtag/js?id=${config.analytics.tracking_id}`;
                    document.head.appendChild(script);
                    
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('js', new Date());
                    gtag('config', config.analytics.tracking_id);
                }
            })
            .catch(error => console.log('Using default configuration'));
    </script>
</body>
</html>
EOF
}

# Function to create branch for site
create_site_branch() {
    local site_name="$1"
    local branch_name="site-$site_name"
    
    echo -e "${BLUE}🌿 Creating branch: $branch_name${NC}"
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    
    # Create site configuration
    create_site_config "$@"
    
    # Create site-specific files
    create_site_files "$site_name"
    
    # Create site-specific index.html
    cp "sites/$site_name.html" "index.html"
    
    # Update staticwebapp.config.json for custom domain
    cat > "staticwebapp.config.json" << EOF
{
  "routes": [
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*", "/css/*", "/js/*", "/api/*", "*.{ico,png,jpg,jpeg,gif,svg,css,js,woff,woff2,ttf,eot}"]
  },
  "responseOverrides": {
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "Permissions-Policy": "camera=(), microphone=(), geolocation=()"
  },
  "mimeTypes": {
    ".json": "application/json",
    ".css": "text/css",
    ".js": "application/javascript",
    ".html": "text/html",
    ".ico": "image/x-icon",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".svg": "image/svg+xml",
    ".woff": "font/woff",
    ".woff2": "font/woff2",
    ".ttf": "font/ttf",
    ".eot": "application/vnd.ms-fontobject"
  }
}
EOF
    
    # Create CNAME file for custom domain
    echo "$2" > CNAME
    
    # Commit changes
    git add .
    git commit -m "Add site: $site_name ($2)"
    
    # Push branch
    git push -u origin "$branch_name"
    
    echo -e "${GREEN}✅ Site '$site_name' created successfully!${NC}"
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo -e "${BLUE}   1. Create Azure Static Web App for branch: $branch_name${NC}"
    echo -e "${BLUE}   2. Configure custom domain: $2${NC}"
    echo -e "${BLUE}   3. Set up DNS records${NC}"
}

# Main script logic
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "$1" ]; then
    show_usage
    exit 0
fi

SITE_NAME="$1"
DOMAIN="$2"
PRIMARY_COLOR="$4"
SECONDARY_COLOR="$5"
LOGO="$6"
TITLE="$7"

# Validate inputs
if [ -z "$SITE_NAME" ] || [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ Error: Site name and domain are required${NC}"
    show_usage
    exit 1
fi

validate_domain "$DOMAIN"

echo -e "${BLUE}🚀 Creating new site: $SITE_NAME${NC}"
echo -e "${BLUE}🌐 Domain: $DOMAIN${NC}"

# Create site
create_site_branch "$SITE_NAME" "$DOMAIN" "$PRIMARY_COLOR" "$SECONDARY_COLOR" "$LOGO" "$TITLE"

echo -e "${GREEN}🎉 Site creation complete!${NC}"
echo -e "${BLUE}📚 For deployment instructions, see: AZURE-SETUP.md${NC}" 