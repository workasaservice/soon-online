#!/bin/bash

# Bulk Deployment and Management Script
# Manages multiple sites and their deployments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration file
SITES_FILE="sites-list.txt"

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <command> [options]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  create-batch <file>           Create multiple sites from CSV file"
    echo "  deploy-all                    Deploy all sites"
    echo "  check-all                     Check status of all sites"
    echo "  update-all                    Update all sites with latest code"
    echo "  list-sites                    List all configured sites"
    echo "  health-check                  Check health of all sites"
    echo "  cleanup                       Clean up old branches"
    echo "  help                          Show this help"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 create-batch sites.csv"
    echo "  $0 deploy-all"
    echo "  $0 check-all"
    echo "  $0 health-check"
}

# Function to create sites from CSV file
create_batch_sites() {
    local csv_file="$1"
    
    if [ ! -f "$csv_file" ]; then
        echo -e "${RED}❌ CSV file not found: $csv_file${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📋 Creating sites from: $csv_file${NC}"
    
    # Skip header line and process each row
    tail -n +2 "$csv_file" | while IFS=',' read -r site_name domain primary_color secondary_color logo title; do
        echo -e "${BLUE}🚀 Creating site: $site_name ($domain)${NC}"
        
        # Remove quotes and trim whitespace
        site_name=$(echo "$site_name" | tr -d '"' | xargs)
        domain=$(echo "$domain" | tr -d '"' | xargs)
        primary_color=$(echo "$primary_color" | tr -d '"' | xargs)
        secondary_color=$(echo "$secondary_color" | tr -d '"' | xargs)
        logo=$(echo "$logo" | tr -d '"' | xargs)
        title=$(echo "$title" | tr -d '"' | xargs)
        
        # Create site
        ./create-site.sh "$site_name" "$domain" "$primary_color" "$secondary_color" "$logo" "$title"
        
        echo -e "${GREEN}✅ Created: $site_name${NC}"
    done
    
    echo -e "${GREEN}🎉 Batch creation complete!${NC}"
}

# Function to deploy all sites
deploy_all_sites() {
    echo -e "${BLUE}🚀 Deploying all sites...${NC}"
    
    # Get all site branches
    local branches=$(git branch -r | grep "origin/site-" | sed 's/origin\///')
    
    for branch in $branches; do
        echo -e "${BLUE}📦 Deploying: $branch${NC}"
        
        # Switch to branch
        git checkout "$branch"
        
        # Pull latest changes
        git pull origin "$branch"
        
        # Push to trigger deployment
        git push origin "$branch"
        
        echo -e "${GREEN}✅ Deployed: $branch${NC}"
    done
    
    # Return to main branch
    git checkout main
    
    echo -e "${GREEN}🎉 All sites deployed!${NC}"
}

# Function to check all sites status
check_all_sites() {
    echo -e "${BLUE}🔍 Checking all sites status...${NC}"
    
    # Get all site branches
    local branches=$(git branch -r | grep "origin/site-" | sed 's/origin\///')
    
    for branch in $branches; do
        local site_name=$(echo "$branch" | sed 's/site-//')
        echo -e "${BLUE}📋 Checking: $site_name${NC}"
        
        # Check if branch exists locally
        if git show-ref --verify --quiet refs/heads/"$branch"; then
            echo -e "${GREEN}✅ Branch exists locally${NC}"
        else
            echo -e "${YELLOW}⚠️  Branch not found locally${NC}"
        fi
        
        # Check if site configuration exists
        if [ -f "sites/$site_name.json" ]; then
            echo -e "${GREEN}✅ Site config exists${NC}"
        else
            echo -e "${RED}❌ Site config missing${NC}"
        fi
    done
    
    echo -e "${GREEN}🎉 Status check complete!${NC}"
}

# Function to update all sites
update_all_sites() {
    echo -e "${BLUE}🔄 Updating all sites...${NC}"
    
    # Get all site branches
    local branches=$(git branch -r | grep "origin/site-" | sed 's/origin\///')
    
    for branch in $branches; do
        echo -e "${BLUE}📦 Updating: $branch${NC}"
        
        # Switch to branch
        git checkout "$branch"
        
        # Merge latest changes from main
        git merge main --no-edit
        
        # Push updates
        git push origin "$branch"
        
        echo -e "${GREEN}✅ Updated: $branch${NC}"
    done
    
    # Return to main branch
    git checkout main
    
    echo -e "${GREEN}🎉 All sites updated!${NC}"
}

# Function to list all sites
list_sites() {
    echo -e "${BLUE}📋 Listing all sites...${NC}"
    
    # Get all site branches
    local branches=$(git branch -r | grep "origin/site-" | sed 's/origin\///')
    
    if [ -z "$branches" ]; then
        echo -e "${YELLOW}No sites found${NC}"
        return
    fi
    
    echo -e "${BLUE}Found $(echo "$branches" | wc -l) sites:${NC}"
    echo ""
    
    for branch in $branches; do
        local site_name=$(echo "$branch" | sed 's/site-//')
        local domain=""
        
        # Get domain from config if exists
        if [ -f "sites/$site_name.json" ]; then
            domain=$(grep '"domain"' "sites/$site_name.json" | cut -d'"' -f4)
        fi
        
        echo -e "${GREEN}• $site_name${NC}"
        if [ -n "$domain" ]; then
            echo -e "${BLUE}  Domain: $domain${NC}"
        fi
        echo -e "${BLUE}  Branch: $branch${NC}"
        echo ""
    done
}

# Function to health check all sites
health_check() {
    echo -e "${BLUE}🏥 Health check for all sites...${NC}"
    
    # Get all site branches
    local branches=$(git branch -r | grep "origin/site-" | sed 's/origin\///')
    
    for branch in $branches; do
        local site_name=$(echo "$branch" | sed 's/site-//')
        local domain=""
        
        # Get domain from config
        if [ -f "sites/$site_name.json" ]; then
            domain=$(grep '"domain"' "sites/$site_name.json" | cut -d'"' -f4)
        fi
        
        echo -e "${BLUE}🔍 Checking: $site_name${NC}"
        
        if [ -n "$domain" ]; then
            # Check if domain is accessible
            local http_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain" 2>/dev/null || echo "000")
            
            if [ "$http_code" = "200" ]; then
                echo -e "${GREEN}✅ $domain is live (HTTP: $http_code)${NC}"
            else
                echo -e "${YELLOW}⚠️  $domain returned HTTP: $http_code${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  No domain configured${NC}"
        fi
        
        # Check if Azure Static Web App exists (basic check)
        local azure_url="https://$site_name.azurestaticapps.net"
        local azure_code=$(curl -s -o /dev/null -w "%{http_code}" "$azure_url" 2>/dev/null || echo "000")
        
        if [ "$azure_code" = "200" ]; then
            echo -e "${GREEN}✅ Azure Static Web App is live${NC}"
        else
            echo -e "${YELLOW}⚠️  Azure Static Web App returned HTTP: $azure_code${NC}"
        fi
        
        echo ""
    done
    
    echo -e "${GREEN}🎉 Health check complete!${NC}"
}

# Function to cleanup old branches
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up old branches...${NC}"
    
    # Get all local site branches
    local local_branches=$(git branch | grep "site-" | sed 's/^[ *]*//')
    
    for branch in $local_branches; do
        echo -e "${BLUE}🗑️  Cleaning: $branch${NC}"
        
        # Delete local branch
        git branch -D "$branch"
        
        echo -e "${GREEN}✅ Cleaned: $branch${NC}"
    done
    
    echo -e "${GREEN}🎉 Cleanup complete!${NC}"
}

# Function to create sample CSV file
create_sample_csv() {
    echo -e "${BLUE}📝 Creating sample CSV file...${NC}"
    
    cat > "sites-sample.csv" << EOF
site_name,domain,primary_color,secondary_color,logo,title
startup,startup.com,#ff6b6b,#4ecdc4,🚀,Startup Coming Soon
tech,tech.com,#667eea,#764ba2,💻,Tech Coming Soon
creative,creative.com,#f093fb,#f5576c,🎨,Creative Coming Soon
business,business.com,#4facfe,#00f2fe,💼,Business Coming Soon
food,food.com,#43e97b,#38f9d7,🍕,Food Coming Soon
EOF
    
    echo -e "${GREEN}✅ Sample CSV created: sites-sample.csv${NC}"
    echo -e "${BLUE}💡 Edit this file and run: $0 create-batch sites-sample.csv${NC}"
}

# Main script logic
case "$1" in
    "create-batch")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Error: CSV file required${NC}"
            show_usage
            exit 1
        fi
        create_batch_sites "$2"
        ;;
    "deploy-all")
        deploy_all_sites
        ;;
    "check-all")
        check_all_sites
        ;;
    "update-all")
        update_all_sites
        ;;
    "list-sites")
        list_sites
        ;;
    "health-check")
        health_check
        ;;
    "cleanup")
        cleanup
        ;;
    "sample-csv")
        create_sample_csv
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        echo -e "${BLUE}Bulk Deployment and Management Script${NC}"
        echo "=========================================="
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
        echo "  create-batch    - Create multiple sites from CSV"
        echo "  deploy-all      - Deploy all sites"
        echo "  check-all       - Check all sites status"
        echo "  update-all      - Update all sites"
        echo "  list-sites      - List all sites"
        echo "  health-check    - Health check all sites"
        echo "  cleanup         - Clean up old branches"
        echo "  sample-csv      - Create sample CSV file"
        echo "  help            - Show detailed help"
        echo ""
        echo -e "${YELLOW}Run: $0 help for detailed usage${NC}"
        ;;
esac

echo -e "\n${BLUE}📚 For more information, see: MULTI-SITE-SETUP.md${NC}" 