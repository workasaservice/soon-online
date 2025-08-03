#!/bin/bash

# Azure Static Web Apps Setup Helper
# This script helps verify Azure deployment and configuration

echo "🚀 Azure Static Web Apps Setup Helper"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Azure CLI
check_azure_cli() {
    echo -e "\n${BLUE}🔍 Checking Azure CLI...${NC}"
    
    if command_exists az; then
        echo -e "${GREEN}✅ Azure CLI is installed${NC}"
        
        # Check if logged in
        if az account show >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Logged into Azure${NC}"
            ACCOUNT=$(az account show --query "user.name" -o tsv 2>/dev/null)
            echo -e "${BLUE}   Account: $ACCOUNT${NC}"
        else
            echo -e "${YELLOW}⚠️  Not logged into Azure${NC}"
            echo -e "${BLUE}💡 Run: az login${NC}"
        fi
    else
        echo -e "${RED}❌ Azure CLI not installed${NC}"
        echo -e "${BLUE}💡 Install with:${NC}"
        echo -e "${BLUE}   macOS: brew install azure-cli${NC}"
        echo -e "${BLUE}   Windows: Download from Microsoft${NC}"
        echo -e "${BLUE}   Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash${NC}"
    fi
}

# Function to check GitHub repository
check_github_repo() {
    echo -e "\n${BLUE}📋 Checking GitHub Repository...${NC}"
    
    REPO_URL="https://github.com/workasaservice/soon-online"
    
    if curl -s -o /dev/null -w "%{http_code}" "$REPO_URL" | grep -q "200"; then
        echo -e "${GREEN}✅ Repository is accessible${NC}"
        echo -e "${BLUE}   URL: $REPO_URL${NC}"
    else
        echo -e "${RED}❌ Repository not accessible${NC}"
        return 1
    fi
    
    # Check if Azure workflow exists
    WORKFLOW_URL="https://github.com/workasaservice/soon-online/blob/main/.github/workflows/azure-static-web-apps.yml"
    if curl -s -o /dev/null -w "%{http_code}" "$WORKFLOW_URL" | grep -q "200"; then
        echo -e "${GREEN}✅ Azure workflow exists${NC}"
    else
        echo -e "${YELLOW}⚠️  Azure workflow not found${NC}"
    fi
}

# Function to check Static Web App status
check_static_web_app() {
    echo -e "\n${BLUE}🌐 Checking Static Web App Status...${NC}"
    
    if [ -z "$1" ]; then
        echo -e "${YELLOW}⚠️  No app name provided. Usage: $0 check-app <app-name>${NC}"
        return 1
    fi
    
    APP_NAME="$1"
    AZURE_URL="https://$APP_NAME.azurestaticapps.net"
    
    echo -e "${BLUE}Checking: $AZURE_URL${NC}"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$AZURE_URL")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Static Web App is live!${NC}"
        echo -e "${BLUE}   URL: $AZURE_URL${NC}"
    else
        echo -e "${YELLOW}⚠️  Static Web App returned HTTP: $HTTP_CODE${NC}"
        echo -e "${BLUE}💡 Check Azure Portal for deployment status${NC}"
    fi
}

# Function to show Azure setup steps
show_azure_steps() {
    echo -e "\n${BLUE}📋 Azure Static Web Apps Setup Steps${NC}"
    echo "=========================================="
    echo -e "${GREEN}1.${NC} Create Azure account (free): https://azure.microsoft.com/free/"
    echo -e "${GREEN}2.${NC} Go to Azure Portal: https://portal.azure.com"
    echo -e "${GREEN}3.${NC} Create Static Web App:"
    echo -e "${BLUE}   - Search for 'Static Web App'${NC}"
    echo -e "${BLUE}   - Click 'Create'${NC}"
    echo -e "${BLUE}   - Connect GitHub repository${NC}"
    echo -e "${BLUE}   - Select: workasaservice/soon-online${NC}"
    echo -e "${BLUE}   - Branch: main${NC}"
    echo -e "${BLUE}   - App location: /${NC}"
    echo -e "${GREEN}4.${NC} Copy deployment token from Azure"
    echo -e "${GREEN}5.${NC} Add to GitHub secrets:"
    echo -e "${BLUE}   - Go to: https://github.com/workasaservice/soon-online/settings/secrets/actions${NC}"
    echo -e "${BLUE}   - Add: AZURE_STATIC_WEB_APPS_API_TOKEN${NC}"
    echo -e "${GREEN}6.${NC} Push code to trigger deployment"
    echo -e "${GREEN}7.${NC} Add custom domains (optional)"
}

# Function to show free tier benefits
show_free_tier() {
    echo -e "\n${BLUE}💰 Azure Static Web Apps Free Tier${NC}"
    echo "=================================="
    echo -e "${GREEN}✅ 2GB storage per app${NC}"
    echo -e "${GREEN}✅ 100GB bandwidth per month${NC}"
    echo -e "${GREEN}✅ Unlimited builds per month${NC}"
    echo -e "${GREEN}✅ Custom domains with free SSL${NC}"
    echo -e "${GREEN}✅ Global CDN for fast loading${NC}"
    echo -e "${GREEN}✅ GitHub integration${NC}"
    echo -e "${GREEN}✅ No credit card required${NC}"
}

# Function to show DNS configuration
show_dns_config() {
    echo -e "\n${BLUE}🌐 DNS Configuration for Custom Domains${NC}"
    echo "=========================================="
    
    if [ -z "$1" ]; then
        echo -e "${YELLOW}⚠️  No app name provided. Usage: $0 dns <app-name>${NC}"
        return 1
    fi
    
    APP_NAME="$1"
    
    echo -e "${BLUE}For subdomain (e.g., coming-soon.yourdomain.com):${NC}"
    echo "Type: CNAME"
    echo "Name: coming-soon"
    echo "Value: $APP_NAME.azurestaticapps.net"
    echo "TTL: 300"
    
    echo -e "\n${BLUE}For root domain (yourdomain.com):${NC}"
    echo "Type: CNAME"
    echo "Name: @"
    echo "Value: $APP_NAME.azurestaticapps.net"
    echo "TTL: 300"
    
    echo -e "\n${BLUE}Add in Azure Portal:${NC}"
    echo "1. Go to your Static Web App"
    echo "2. Click 'Custom domains'"
    echo "3. Click 'Add'"
    echo "4. Enter your domain"
    echo "5. Follow DNS instructions"
}

# Function to show troubleshooting
show_troubleshooting() {
    echo -e "\n${BLUE}🔧 Troubleshooting${NC}"
    echo "================"
    echo -e "${YELLOW}Deployment fails:${NC}"
    echo "- Check GitHub Actions logs"
    echo "- Verify AZURE_STATIC_WEB_APPS_API_TOKEN secret"
    echo "- Ensure workflow file is correct"
    
    echo -e "\n${YELLOW}Custom domain not working:${NC}"
    echo "- Check DNS propagation: https://www.whatsmydns.net/"
    echo "- Verify CNAME records"
    echo "- Wait for SSL certificate (up to 24 hours)"
    
    echo -e "\n${YELLOW}404 errors:${NC}"
    echo "- Check staticwebapp.config.json"
    echo "- Verify all files are in correct location"
    echo "- Check Azure Portal deployment status"
}

# Main script logic
case "$1" in
    "check")
        check_azure_cli
        check_github_repo
        ;;
    "check-app")
        check_static_web_app "$2"
        ;;
    "steps")
        show_azure_steps
        ;;
    "free")
        show_free_tier
        ;;
    "dns")
        show_dns_config "$2"
        ;;
    "troubleshoot")
        show_troubleshooting
        ;;
    "help"|"-h"|"--help")
        echo -e "${BLUE}Usage:${NC}"
        echo "  $0 check                    - Check Azure CLI and GitHub repo"
        echo "  $0 check-app <app-name>     - Check Static Web App status"
        echo "  $0 steps                    - Show Azure setup steps"
        echo "  $0 free                     - Show free tier benefits"
        echo "  $0 dns <app-name>           - Show DNS configuration"
        echo "  $0 troubleshoot             - Show troubleshooting guide"
        echo "  $0 help                     - Show this help"
        echo ""
        echo -e "${BLUE}Examples:${NC}"
        echo "  $0 check"
        echo "  $0 check-app my-app"
        echo "  $0 dns my-app"
        echo "  $0 steps"
        ;;
    *)
        echo -e "${BLUE}Azure Static Web Apps Setup Helper${NC}"
        echo "======================================"
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
        echo "  check        - Check Azure CLI and GitHub repo"
        echo "  check-app    - Check Static Web App status"
        echo "  steps        - Show Azure setup steps"
        echo "  free         - Show free tier benefits"
        echo "  dns          - Show DNS configuration"
        echo "  troubleshoot - Show troubleshooting guide"
        echo "  help         - Show detailed help"
        echo ""
        echo -e "${YELLOW}Run: $0 help for detailed usage${NC}"
        ;;
esac

echo -e "\n${BLUE}📚 For more information, see: AZURE-SETUP.md${NC}" 