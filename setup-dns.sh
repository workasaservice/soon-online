#!/bin/bash

# DNS Setup Helper Script for GitHub Pages
# This script helps verify DNS configuration and GitHub Pages setup

echo "🚀 GitHub Pages DNS Setup Helper"
echo "=================================="

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

# Function to check GitHub Pages status
check_github_pages() {
    echo -e "\n${BLUE}📋 Checking GitHub Pages Status...${NC}"
    
    # Check if the repository exists and is accessible
    if curl -s -o /dev/null -w "%{http_code}" "https://github.com/workasaservice/soon-online" | grep -q "200"; then
        echo -e "${GREEN}✅ Repository is accessible${NC}"
    else
        echo -e "${RED}❌ Repository not accessible${NC}"
        return 1
    fi
    
    # Check GitHub Pages URL
    GITHUB_PAGES_URL="https://workasaservice.github.io/soon-online/"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$GITHUB_PAGES_URL")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ GitHub Pages is live at: $GITHUB_PAGES_URL${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub Pages might not be enabled yet (HTTP: $HTTP_CODE)${NC}"
        echo -e "${BLUE}💡 Go to: https://github.com/workasaservice/soon-online/settings/pages${NC}"
        echo -e "${BLUE}   Enable GitHub Pages with source: GitHub Actions${NC}"
    fi
}

# Function to check DNS propagation
check_dns() {
    echo -e "\n${BLUE}🌐 DNS Propagation Check${NC}"
    
    if [ -z "$1" ]; then
        echo -e "${YELLOW}⚠️  No domain provided. Usage: $0 <yourdomain.com>${NC}"
        return 1
    fi
    
    DOMAIN="$1"
    echo -e "${BLUE}Checking DNS for: $DOMAIN${NC}"
    
    # Check if dig is available
    if command_exists dig; then
        echo -e "\n${BLUE}🔍 DNS Records:${NC}"
        dig +short "$DOMAIN" CNAME
        
        echo -e "\n${BLUE}🔍 A Records:${NC}"
        dig +short "$DOMAIN" A
        
        echo -e "\n${BLUE}🔍 NS Records:${NC}"
        dig +short "$DOMAIN" NS
    else
        echo -e "${YELLOW}⚠️  'dig' command not found. Install dnsutils or bind-tools${NC}"
    fi
    
    # Check if nslookup is available
    if command_exists nslookup; then
        echo -e "\n${BLUE}🔍 Nslookup Results:${NC}"
        nslookup "$DOMAIN"
    fi
    
    # Test HTTP response
    echo -e "\n${BLUE}🌐 HTTP Response Test:${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Domain is accessible (HTTP: $HTTP_CODE)${NC}"
    else
        echo -e "${YELLOW}⚠️  Domain returned HTTP: $HTTP_CODE${NC}"
    fi
}

# Function to show DNS configuration examples
show_dns_examples() {
    echo -e "\n${BLUE}📋 DNS Configuration Examples${NC}"
    echo "=================================="
    
    echo -e "\n${YELLOW}For Cloudflare:${NC}"
    echo "Type: CNAME"
    echo "Name: @ (or subdomain name)"
    echo "Target: workasaservice.github.io"
    echo "Proxy status: DNS only (gray cloud)"
    
    echo -e "\n${YELLOW}For GoDaddy:${NC}"
    echo "Type: CNAME"
    echo "Host: @ (or subdomain)"
    echo "Points to: workasaservice.github.io"
    echo "TTL: 600"
    
    echo -e "\n${YELLOW}For Namecheap:${NC}"
    echo "Type: CNAME Record"
    echo "Host: @ (or subdomain)"
    echo "Value: workasaservice.github.io"
    echo "TTL: Automatic"
}

# Function to show next steps
show_next_steps() {
    echo -e "\n${BLUE}📋 Next Steps${NC}"
    echo "============="
    echo -e "${GREEN}1.${NC} Go to: https://github.com/workasaservice/soon-online/settings/pages"
    echo -e "${GREEN}2.${NC} Set Source to: GitHub Actions"
    echo -e "${GREEN}3.${NC} Add your custom domain"
    echo -e "${GREEN}4.${NC} Check 'Enforce HTTPS'"
    echo -e "${GREEN}5.${NC} Configure DNS records in your domain provider"
    echo -e "${GREEN}6.${NC} Wait for DNS propagation (5 minutes - 48 hours)"
    echo -e "${GREEN}7.${NC} Test your domain"
}

# Main script logic
case "$1" in
    "check")
        check_github_pages
        ;;
    "dns")
        check_dns "$2"
        ;;
    "examples")
        show_dns_examples
        ;;
    "next")
        show_next_steps
        ;;
    "help"|"-h"|"--help")
        echo -e "${BLUE}Usage:${NC}"
        echo "  $0 check                    - Check GitHub Pages status"
        echo "  $0 dns <domain.com>         - Check DNS propagation for domain"
        echo "  $0 examples                 - Show DNS configuration examples"
        echo "  $0 next                     - Show next steps"
        echo "  $0 help                     - Show this help"
        echo ""
        echo -e "${BLUE}Examples:${NC}"
        echo "  $0 check"
        echo "  $0 dns coming-soon.yourdomain.com"
        echo "  $0 examples"
        ;;
    *)
        echo -e "${BLUE}GitHub Pages DNS Setup Helper${NC}"
        echo "=================================="
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
        echo "  check    - Check GitHub Pages status"
        echo "  dns      - Check DNS propagation"
        echo "  examples - Show DNS configuration examples"
        echo "  next     - Show next steps"
        echo "  help     - Show detailed help"
        echo ""
        echo -e "${YELLOW}Run: $0 help for detailed usage${NC}"
        ;;
esac

echo -e "\n${BLUE}📚 For more information, see: DNS-SETUP.md${NC}" 