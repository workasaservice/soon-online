#!/bin/bash

# Azure Multi-Site Setup Script
# Automates creation of multiple Static Web Apps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="soon-online-rg"
LOCATION="eastus"
REPO_URL="https://github.com/workasaservice/soon-online"

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <csv-file> [options]"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "  --resource-group <name>    Resource group name (default: soon-online-rg)"
    echo "  --location <region>        Azure region (default: eastus)"
    echo "  --dry-run                  Show what would be created without creating"
    echo "  --help                     Show this help"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 sites.csv"
    echo "  $0 sites.csv --resource-group my-rg --location westus"
    echo "  $0 sites.csv --dry-run"
}

# Function to check if Azure CLI is installed
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI is not installed${NC}"
        echo -e "${BLUE}💡 Install with:${NC}"
        echo -e "${BLUE}   macOS: brew install azure-cli${NC}"
        echo -e "${BLUE}   Windows: Download from Microsoft${NC}"
        echo -e "${BLUE}   Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Azure CLI is installed${NC}"
}

# Function to check if logged into Azure
check_azure_login() {
    if ! az account show &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged into Azure${NC}"
        echo -e "${BLUE}💡 Run: az login${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Logged into Azure${NC}"
    ACCOUNT=$(az account show --query "user.name" -o tsv)
    echo -e "${BLUE}   Account: $ACCOUNT${NC}"
}

# Function to create resource group
create_resource_group() {
    echo -e "${BLUE}🏗️  Creating resource group: $RESOURCE_GROUP${NC}"
    
    if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        echo -e "${GREEN}✅ Resource group already exists${NC}"
    else
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        echo -e "${GREEN}✅ Resource group created${NC}"
    fi
}

# Function to create Static Web App
create_static_web_app() {
    local site_name="$1"
    local domain="$2"
    local dry_run="$3"
    
    echo -e "${BLUE}📦 Creating Static Web App: $site_name${NC}"
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}   Would create: $site_name${NC}"
        echo -e "${YELLOW}   Branch: site-$site_name${NC}"
        echo -e "${YELLOW}   Domain: $domain${NC}"
        return
    fi
    
    # Check if Static Web App already exists
    if az staticwebapp show --name "$site_name" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
        echo -e "${YELLOW}⚠️  Static Web App already exists: $site_name${NC}"
    else
        # Create Static Web App
        az staticwebapp create \
            --name "$site_name" \
            --resource-group "$RESOURCE_GROUP" \
            --source "$REPO_URL" \
            --branch "site-$site_name" \
            --app-location "/" \
            --location "$LOCATION"
        
        echo -e "${GREEN}✅ Created Static Web App: $site_name${NC}"
    fi
    
    # Add custom domain
    echo -e "${BLUE}🌐 Adding custom domain: $domain${NC}"
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}   Would add domain: $domain${NC}"
    else
        # Check if domain already exists
        if az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[?hostname=='$domain']" --output table | grep -q "$domain"; then
            echo -e "${YELLOW}⚠️  Domain already configured: $domain${NC}"
        else
            az staticwebapp hostname set \
                --name "$site_name" \
                --resource-group "$RESOURCE_GROUP" \
                --hostname "$domain"
            
            echo -e "${GREEN}✅ Domain configured: $domain${NC}"
        fi
    fi
}

# Function to get deployment token
get_deployment_token() {
    local site_name="$1"
    
    echo -e "${BLUE}🔑 Getting deployment token for: $site_name${NC}"
    
    # Get deployment token
    token=$(az staticwebapp secrets list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "properties.apiKey" -o tsv 2>/dev/null || echo "")
    
    if [ -n "$token" ]; then
        echo -e "${GREEN}✅ Deployment token: $token${NC}"
        echo -e "${BLUE}💡 Add to GitHub secrets as: AZURE_STATIC_WEB_APPS_API_TOKEN_${site_name^^}${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not get deployment token${NC}"
    fi
}

# Function to process CSV file
process_csv() {
    local csv_file="$1"
    local dry_run="$2"
    
    if [ ! -f "$csv_file" ]; then
        echo -e "${RED}❌ CSV file not found: $csv_file${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📋 Processing CSV file: $csv_file${NC}"
    
    # Count total sites
    total_sites=$(tail -n +2 "$csv_file" | wc -l)
    echo -e "${BLUE}📊 Found $total_sites sites to process${NC}"
    
    # Process each site
    current=0
    tail -n +2 "$csv_file" | while IFS=',' read -r site_name domain primary_color secondary_color logo title; do
        current=$((current + 1))
        
        # Clean up variables
        site_name=$(echo "$site_name" | tr -d '"' | xargs)
        domain=$(echo "$domain" | tr -d '"' | xargs)
        
        echo -e "${BLUE}🔄 Processing site $current/$total_sites: $site_name${NC}"
        
        # Create Static Web App
        create_static_web_app "$site_name" "$domain" "$dry_run"
        
        # Get deployment token (only if not dry run)
        if [ "$dry_run" != "true" ]; then
            get_deployment_token "$site_name"
        fi
        
        echo ""
    done
}

# Function to show next steps
show_next_steps() {
    echo -e "${BLUE}📋 Next Steps${NC}"
    echo "============="
    echo -e "${GREEN}1.${NC} Add deployment tokens to GitHub secrets"
    echo -e "${GREEN}2.${NC} Configure DNS records for custom domains"
    echo -e "${GREEN}3.${NC} Test deployments"
    echo -e "${GREEN}4.${NC} Monitor site health"
    echo ""
    echo -e "${BLUE}GitHub Secrets to add:${NC}"
    echo "Go to: https://github.com/workasaservice/soon-online/settings/secrets/actions"
    echo "Add secrets for each site: AZURE_STATIC_WEB_APPS_API_TOKEN_SITENAME"
    echo ""
    echo -e "${BLUE}DNS Configuration:${NC}"
    echo "For each domain, add CNAME record pointing to: sitename.azurestaticapps.net"
}

# Main script logic
CSV_FILE=""
DRY_RUN="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            if [ -z "$CSV_FILE" ]; then
                CSV_FILE="$1"
            else
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [ -z "$CSV_FILE" ]; then
    echo -e "${RED}❌ Error: CSV file is required${NC}"
    show_usage
    exit 1
fi

echo -e "${BLUE}🚀 Azure Multi-Site Setup Script${NC}"
echo "=================================="
echo -e "${BLUE}CSV File:${NC} $CSV_FILE"
echo -e "${BLUE}Resource Group:${NC} $RESOURCE_GROUP"
echo -e "${BLUE}Location:${NC} $LOCATION"
echo -e "${BLUE}Dry Run:${NC} $DRY_RUN"
echo ""

# Check prerequisites
check_azure_cli
check_azure_login

# Create resource group
create_resource_group

# Process CSV file
process_csv "$CSV_FILE" "$DRY_RUN"

if [ "$DRY_RUN" = "true" ]; then
    echo -e "${GREEN}🎉 Dry run completed!${NC}"
    echo -e "${BLUE}💡 Run without --dry-run to create actual resources${NC}"
else
    echo -e "${GREEN}🎉 All Static Web Apps created successfully!${NC}"
    show_next_steps
fi

echo -e "\n${BLUE}📚 For more information, see: AZURE-MULTI-SITE-SETUP.md${NC}" 