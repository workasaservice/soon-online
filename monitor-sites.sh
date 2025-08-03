#!/bin/bash

# Multi-Site Monitoring Script
# Monitors health and status of all deployed sites

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="soon-online-rg"
OUTPUT_FILE="sites-status.json"

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <command> [options]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  health-check              Check health of all sites"
    echo "  status                    Show detailed status"
    echo "  dns-check                 Check DNS propagation"
    echo "  ssl-check                 Check SSL certificates"
    echo "  performance               Check site performance"
    echo "  export                    Export status to JSON"
    echo "  summary                   Show summary report"
    echo "  help                      Show this help"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "  --resource-group <name>   Resource group name"
    echo "  --output <file>           Output file for export"
    echo "  --timeout <seconds>       Request timeout (default: 10)"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 health-check"
    echo "  $0 status --timeout 15"
    echo "  $0 export --output sites-report.json"
}

# Function to get sites from Azure
get_azure_sites() {
    echo -e "${BLUE}📋 Getting sites from Azure...${NC}"
    
    # Get all Static Web Apps in resource group
    sites=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, url:defaultHostname}" -o tsv 2>/dev/null || echo "")
    
    if [ -z "$sites" ]; then
        echo -e "${YELLOW}⚠️  No Static Web Apps found in resource group: $RESOURCE_GROUP${NC}"
        return 1
    fi
    
    echo "$sites"
}

# Function to check site health
check_site_health() {
    local site_name="$1"
    local domain="$2"
    local timeout="${3:-10}"
    
    local azure_url="https://$site_name.azurestaticapps.net"
    local results=()
    
    echo -e "${BLUE}🔍 Checking: $site_name${NC}"
    
    # Check Azure Static Web App
    local azure_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$azure_url" 2>/dev/null || echo "000")
    local azure_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$timeout" "$azure_url" 2>/dev/null || echo "0")
    
    if [ "$azure_status" = "200" ]; then
        echo -e "${GREEN}✅ Azure: $azure_status (${azure_time}s)${NC}"
        results+=("azure:ok:$azure_status:$azure_time")
    else
        echo -e "${RED}❌ Azure: $azure_status${NC}"
        results+=("azure:error:$azure_status:$azure_time")
    fi
    
    # Check custom domain if provided
    if [ -n "$domain" ] && [ "$domain" != "null" ]; then
        local domain_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "https://$domain" 2>/dev/null || echo "000")
        local domain_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$timeout" "https://$domain" 2>/dev/null || echo "0")
        
        if [ "$domain_status" = "200" ]; then
            echo -e "${GREEN}✅ Domain: $domain_status (${domain_time}s)${NC}"
            results+=("domain:ok:$domain_status:$domain_time")
        else
            echo -e "${YELLOW}⚠️  Domain: $domain_status${NC}"
            results+=("domain:error:$domain_status:$domain_time")
        fi
    fi
    
    # Check SSL certificate
    local ssl_check=$(echo | openssl s_client -servername "$site_name.azurestaticapps.net" -connect "$site_name.azurestaticapps.net:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d= -f2 || echo "unknown")
    
    if [ "$ssl_check" != "unknown" ]; then
        echo -e "${GREEN}✅ SSL: Valid until $ssl_check${NC}"
        results+=("ssl:ok:$ssl_check")
    else
        echo -e "${YELLOW}⚠️  SSL: Could not verify${NC}"
        results+=("ssl:error:unknown")
    fi
    
    echo ""
    echo "${results[*]}"
}

# Function to perform health check
health_check() {
    local timeout="${1:-10}"
    
    echo -e "${BLUE}🏥 Health Check for All Sites${NC}"
    echo "=================================="
    
    # Get sites from Azure
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local total_sites=0
    local healthy_sites=0
    local results=()
    
    # Process each site
    while IFS=$'\t' read -r site_name azure_url; do
        total_sites=$((total_sites + 1))
        
        # Get custom domain
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        
        # Check site health
        site_results=$(check_site_health "$site_name" "$domain" "$timeout")
        
        # Parse results
        for result in $site_results; do
            IFS=':' read -r check_type status code time <<< "$result"
            if [ "$status" = "ok" ]; then
                healthy_sites=$((healthy_sites + 1))
            fi
        done
        
        results+=("$site_name:$site_results")
        
    done <<< "$sites"
    
    # Summary
    echo -e "${BLUE}📊 Health Check Summary${NC}"
    echo "========================"
    echo -e "${BLUE}Total Sites:${NC} $total_sites"
    echo -e "${BLUE}Healthy Checks:${NC} $healthy_sites"
    echo -e "${BLUE}Success Rate:${NC} $((healthy_sites * 100 / (total_sites * 3)))%"
}

# Function to check DNS propagation
dns_check() {
    echo -e "${BLUE}🌐 DNS Propagation Check${NC}"
    echo "=========================="
    
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    while IFS=$'\t' read -r site_name azure_url; do
        echo -e "${BLUE}🔍 Checking DNS for: $site_name${NC}"
        
        # Get custom domain
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        
        if [ -n "$domain" ] && [ "$domain" != "null" ]; then
            # Check DNS resolution
            if nslookup "$domain" &> /dev/null; then
                echo -e "${GREEN}✅ DNS: $domain resolves${NC}"
            else
                echo -e "${RED}❌ DNS: $domain does not resolve${NC}"
            fi
            
            # Check CNAME record
            cname=$(dig +short CNAME "$domain" 2>/dev/null || echo "")
            if [ -n "$cname" ]; then
                echo -e "${GREEN}✅ CNAME: $domain -> $cname${NC}"
            else
                echo -e "${YELLOW}⚠️  CNAME: No CNAME record found${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  No custom domain configured${NC}"
        fi
        
        echo ""
    done <<< "$sites"
}

# Function to check SSL certificates
ssl_check() {
    echo -e "${BLUE}🔒 SSL Certificate Check${NC}"
    echo "=========================="
    
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    while IFS=$'\t' read -r site_name azure_url; do
        echo -e "${BLUE}🔍 Checking SSL for: $site_name${NC}"
        
        # Check Azure Static Web App SSL
        azure_ssl=$(echo | openssl s_client -servername "$azure_url" -connect "$azure_url:443" 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null || echo "error")
        
        if [ "$azure_ssl" != "error" ]; then
            echo -e "${GREEN}✅ Azure SSL: Valid${NC}"
            echo "$azure_ssl" | grep "notAfter"
        else
            echo -e "${RED}❌ Azure SSL: Error${NC}"
        fi
        
        # Check custom domain SSL
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        
        if [ -n "$domain" ] && [ "$domain" != "null" ]; then
            domain_ssl=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null || echo "error")
            
            if [ "$domain_ssl" != "error" ]; then
                echo -e "${GREEN}✅ Domain SSL: Valid${NC}"
                echo "$domain_ssl" | grep "notAfter"
            else
                echo -e "${RED}❌ Domain SSL: Error${NC}"
            fi
        fi
        
        echo ""
    done <<< "$sites"
}

# Function to check performance
performance_check() {
    local timeout="${1:-10}"
    
    echo -e "${BLUE}⚡ Performance Check${NC}"
    echo "====================="
    
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    while IFS=$'\t' read -r site_name azure_url; do
        echo -e "${BLUE}🔍 Testing performance: $site_name${NC}"
        
        # Test Azure Static Web App
        azure_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$timeout" "https://$azure_url" 2>/dev/null || echo "0")
        
        if (( $(echo "$azure_time > 0" | bc -l) )); then
            if (( $(echo "$azure_time < 1" | bc -l) )); then
                echo -e "${GREEN}✅ Azure: ${azure_time}s (Fast)${NC}"
            elif (( $(echo "$azure_time < 3" | bc -l) )); then
                echo -e "${YELLOW}⚠️  Azure: ${azure_time}s (Medium)${NC}"
            else
                echo -e "${RED}❌ Azure: ${azure_time}s (Slow)${NC}"
            fi
        else
            echo -e "${RED}❌ Azure: Timeout${NC}"
        fi
        
        # Test custom domain
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        
        if [ -n "$domain" ] && [ "$domain" != "null" ]; then
            domain_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$timeout" "https://$domain" 2>/dev/null || echo "0")
            
            if (( $(echo "$domain_time > 0" | bc -l) )); then
                if (( $(echo "$domain_time < 1" | bc -l) )); then
                    echo -e "${GREEN}✅ Domain: ${domain_time}s (Fast)${NC}"
                elif (( $(echo "$domain_time < 3" | bc -l) )); then
                    echo -e "${YELLOW}⚠️  Domain: ${domain_time}s (Medium)${NC}"
                else
                    echo -e "${RED}❌ Domain: ${domain_time}s (Slow)${NC}"
                fi
            else
                echo -e "${RED}❌ Domain: Timeout${NC}"
            fi
        fi
        
        echo ""
    done <<< "$sites"
}

# Function to export status
export_status() {
    local output_file="${1:-$OUTPUT_FILE}"
    
    echo -e "${BLUE}📤 Exporting status to: $output_file${NC}"
    
    # Get sites from Azure
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Start JSON
    echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","sites":[' > "$output_file"
    
    local first=true
    
    while IFS=$'\t' read -r site_name azure_url; do
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        # Get custom domain
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        
        # Check status
        azure_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$azure_url" 2>/dev/null || echo "000")
        domain_status=""
        
        if [ -n "$domain" ] && [ "$domain" != "null" ]; then
            domain_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain" 2>/dev/null || echo "000")
        fi
        
        # Write JSON
        cat >> "$output_file" << EOF
  {
    "name": "$site_name",
    "azure_url": "$azure_url",
    "custom_domain": "$domain",
    "azure_status": "$azure_status",
    "domain_status": "$domain_status",
    "healthy": $([ "$azure_status" = "200" ] && echo "true" || echo "false")
  }
EOF
    done <<< "$sites"
    
    # End JSON
    echo "],\"total_sites":$(echo "$sites" | wc -l)"}" >> "$output_file"
    
    echo -e "${GREEN}✅ Status exported to: $output_file${NC}"
}

# Function to show summary
summary() {
    echo -e "${BLUE}📊 Sites Summary Report${NC}"
    echo "========================"
    
    sites=$(get_azure_sites)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local total_sites=$(echo "$sites" | wc -l)
    local healthy_sites=0
    local domains_configured=0
    
    while IFS=$'\t' read -r site_name azure_url; do
        # Check health
        azure_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$azure_url" 2>/dev/null || echo "000")
        if [ "$azure_status" = "200" ]; then
            healthy_sites=$((healthy_sites + 1))
        fi
        
        # Check custom domain
        domain=$(az staticwebapp hostname list --name "$site_name" --resource-group "$RESOURCE_GROUP" --query "[0].hostname" -o tsv 2>/dev/null || echo "")
        if [ -n "$domain" ] && [ "$domain" != "null" ]; then
            domains_configured=$((domains_configured + 1))
        fi
    done <<< "$sites"
    
    echo -e "${BLUE}Total Sites:${NC} $total_sites"
    echo -e "${BLUE}Healthy Sites:${NC} $healthy_sites"
    echo -e "${BLUE}Domains Configured:${NC} $domains_configured"
    echo -e "${BLUE}Health Rate:${NC} $((healthy_sites * 100 / total_sites))%"
    echo -e "${BLUE}Domain Rate:${NC} $((domains_configured * 100 / total_sites))%"
}

# Main script logic
case "$1" in
    "health-check")
        health_check "$2"
        ;;
    "status")
        health_check "$2"
        dns_check
        ssl_check
        ;;
    "dns-check")
        dns_check
        ;;
    "ssl-check")
        ssl_check
        ;;
    "performance")
        performance_check "$2"
        ;;
    "export")
        export_status "$2"
        ;;
    "summary")
        summary
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        echo -e "${BLUE}Multi-Site Monitoring Script${NC}"
        echo "============================="
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
        echo "  health-check    - Check health of all sites"
        echo "  status          - Show detailed status"
        echo "  dns-check       - Check DNS propagation"
        echo "  ssl-check       - Check SSL certificates"
        echo "  performance     - Check site performance"
        echo "  export          - Export status to JSON"
        echo "  summary         - Show summary report"
        echo "  help            - Show detailed help"
        echo ""
        echo -e "${YELLOW}Run: $0 help for detailed usage${NC}"
        ;;
esac

echo -e "\n${BLUE}📚 For more information, see: AZURE-MULTI-SITE-SETUP.md${NC}" 