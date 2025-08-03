# 🚀 Azure Static Web Apps Multi-Site Configuration Guide

## 🎯 Deployment Strategies for Multiple Sites

### Strategy 1: Multiple Static Web Apps (Recommended for 70+ Sites)
- **One Static Web App per site**
- **Individual custom domains**
- **Independent scaling and monitoring**
- **Free tier: 70+ apps = $0 cost**

### Strategy 2: Single Static Web App with Multiple Routes
- **One Static Web App for all sites**
- **Route-based site serving**
- **Shared resources**
- **More complex configuration**

### Strategy 3: Hybrid Approach
- **Multiple Static Web Apps by category**
- **Grouped sites for easier management**
- **Balanced resource usage**

## 🏗️ Strategy 1: Multiple Static Web Apps (Recommended)

### Step 1: Prepare Your Sites

First, create your sites using the automation scripts:

```bash
# Create sites from CSV
./deploy-all.sh create-batch your-sites.csv

# Or create individual sites
./create-site.sh mysite1 mysite1.com
./create-site.sh mysite2 mysite2.com
```

### Step 2: Create Azure Static Web Apps

#### Option A: Azure Portal (Manual)

1. **Go to Azure Portal**: https://portal.azure.com
2. **Create Static Web App for each site**:
   ```
   Name: mysite1 (unique name)
   Resource Group: soon-online-rg
   Region: East US (or closest to users)
   Source: GitHub
   Repository: workasaservice/soon-online
   Branch: site-mysite1
   Build Preset: Custom
   App location: /
   ```

3. **Repeat for each site** (70+ times)

#### Option B: Azure CLI (Automated)

Create a script to automate Static Web App creation:

```bash
#!/bin/bash
# create-azure-apps.sh

# List of sites from your CSV
sites=(
    "mysite1:mysite1.com"
    "mysite2:mysite2.com"
    "mysite3:mysite3.com"
    # Add all 70+ sites here
)

for site in "${sites[@]}"; do
    IFS=':' read -r site_name domain <<< "$site"
    
    echo "Creating Static Web App for: $site_name"
    
    az staticwebapp create \
        --name "$site_name" \
        --resource-group "soon-online-rg" \
        --source "https://github.com/workasaservice/soon-online" \
        --branch "site-$site_name" \
        --app-location "/" \
        --location "eastus"
    
    echo "✅ Created: $site_name"
done
```

#### Option C: Azure Bicep Template (Infrastructure as Code)

Create `azure-static-web-apps.bicep`:

```bicep
param sites array = [
  {
    name: 'mysite1'
    domain: 'mysite1.com'
    branch: 'site-mysite1'
  }
  {
    name: 'mysite2'
    domain: 'mysite2.com'
    branch: 'site-mysite2'
  }
  // Add all 70+ sites
]

resource staticWebApp 'Microsoft.Web/staticSites@2021-02-01' = [for site in sites: {
  name: site.name
  location: resourceGroup().location
  properties: {
    repositoryUrl: 'https://github.com/workasaservice/soon-online'
    branch: site.branch
    buildProperties: {
      appLocation: '/'
      apiLocation: ''
      outputLocation: ''
    }
  }
}]
```

### Step 3: Configure Custom Domains

#### Automated Domain Configuration

Create a script to add custom domains:

```bash
#!/bin/bash
# configure-domains.sh

# List of sites and domains
sites=(
    "mysite1:mysite1.com"
    "mysite2:mysite2.com"
    "mysite3:mysite3.com"
)

for site in "${sites[@]}"; do
    IFS=':' read -r site_name domain <<< "$site"
    
    echo "Configuring domain for: $site_name -> $domain"
    
    # Add custom domain
    az staticwebapp hostname set \
        --name "$site_name" \
        --resource-group "soon-online-rg" \
        --hostname "$domain"
    
    echo "✅ Domain configured: $domain"
done
```

### Step 4: Set Up GitHub Secrets

For each Static Web App, you'll need to add the deployment token to GitHub:

1. **Get deployment token** from each Static Web App in Azure Portal
2. **Add to GitHub Secrets**:
   ```
   AZURE_STATIC_WEB_APPS_API_TOKEN_SITE1
   AZURE_STATIC_WEB_APPS_API_TOKEN_SITE2
   AZURE_STATIC_WEB_APPS_API_TOKEN_SITE3
   ```

## 🏗️ Strategy 2: Single Static Web App with Multiple Routes

### Step 1: Create Single Static Web App

```bash
az staticwebapp create \
    --name "soon-online-multi" \
    --resource-group "soon-online-rg" \
    --source "https://github.com/workasaservice/soon-online" \
    --branch "main" \
    --app-location "/" \
    --location "eastus"
```

### Step 2: Configure Routes

Update `staticwebapp.config.json`:

```json
{
  "routes": [
    {
      "route": "/mysite1/*",
      "serve": "/sites/mysite1.html",
      "statusCode": 200
    },
    {
      "route": "/mysite2/*",
      "serve": "/sites/mysite2.html",
      "statusCode": 200
    },
    {
      "route": "/mysite3/*",
      "serve": "/sites/mysite3.html",
      "statusCode": 200
    },
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
  }
}
```

### Step 3: Configure Multiple Custom Domains

```bash
# Add multiple domains to single Static Web App
az staticwebapp hostname set \
    --name "soon-online-multi" \
    --resource-group "soon-online-rg" \
    --hostname "mysite1.com"

az staticwebapp hostname set \
    --name "soon-online-multi" \
    --resource-group "soon-online-rg" \
    --hostname "mysite2.com"

az staticwebapp hostname set \
    --name "soon-online-multi" \
    --resource-group "soon-online-rg" \
    --hostname "mysite3.com"
```

## 🏗️ Strategy 3: Hybrid Approach

### Group Sites by Category

```bash
# Create Static Web Apps by category
az staticwebapp create --name "soon-online-startups" --resource-group "soon-online-rg" --source "https://github.com/workasaservice/soon-online" --branch "startups" --app-location "/"
az staticwebapp create --name "soon-online-tech" --resource-group "soon-online-rg" --source "https://github.com/workasaservice/soon-online" --branch "tech" --app-location "/"
az staticwebapp create --name "soon-online-creative" --resource-group "soon-online-rg" --source "https://github.com/workasaservice/soon-online" --branch "creative" --app-location "/"
```

## 🔧 Automated Setup Script

Create `setup-azure-multi.sh`:

```bash
#!/bin/bash

# Azure Multi-Site Setup Script
# Automates creation of multiple Static Web Apps

set -e

# Configuration
RESOURCE_GROUP="soon-online-rg"
LOCATION="eastus"
REPO_URL="https://github.com/workasaservice/soon-online"

# Read sites from CSV
CSV_FILE="your-sites.csv"

echo "🚀 Setting up Azure Static Web Apps for multiple sites..."

# Create resource group if it doesn't exist
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Read CSV and create Static Web Apps
tail -n +2 "$CSV_FILE" | while IFS=',' read -r site_name domain primary_color secondary_color logo title; do
    # Clean up variables
    site_name=$(echo "$site_name" | tr -d '"' | xargs)
    domain=$(echo "$domain" | tr -d '"' | xargs)
    
    echo "📦 Creating Static Web App for: $site_name"
    
    # Create Static Web App
    az staticwebapp create \
        --name "$site_name" \
        --resource-group "$RESOURCE_GROUP" \
        --source "$REPO_URL" \
        --branch "site-$site_name" \
        --app-location "/" \
        --location "$LOCATION"
    
    echo "✅ Created Static Web App: $site_name"
    
    # Add custom domain
    echo "🌐 Adding custom domain: $domain"
    az staticwebapp hostname set \
        --name "$site_name" \
        --resource-group "$RESOURCE_GROUP" \
        --hostname "$domain"
    
    echo "✅ Domain configured: $domain"
    echo ""
done

echo "🎉 All Static Web Apps created successfully!"
```

## 📊 Monitoring and Management

### Health Check Script

```bash
#!/bin/bash
# monitor-sites.sh

# Check all sites health
sites=(
    "mysite1:mysite1.com"
    "mysite2:mysite2.com"
    "mysite3:mysite3.com"
)

for site in "${sites[@]}"; do
    IFS=':' read -r site_name domain <<< "$site"
    
    # Check Azure Static Web App
    azure_url="https://$site_name.azurestaticapps.net"
    azure_status=$(curl -s -o /dev/null -w "%{http_code}" "$azure_url")
    
    # Check custom domain
    domain_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain")
    
    echo "$site_name: Azure=$azure_status, Domain=$domain_status"
done
```

### Cost Monitoring

```bash
# Monitor resource usage
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/soon-online-rg/providers/Microsoft.Web/staticSites" \
    --metric "FunctionExecutionCount" \
    --interval PT1H
```

## 🎯 Recommended Approach for 70+ Sites

### Phase 1: Start with 10 Sites
1. Create 10 Static Web Apps manually
2. Test the process
3. Verify everything works

### Phase 2: Scale to 70+ Sites
1. Use automated scripts
2. Create all remaining Static Web Apps
3. Configure all custom domains

### Phase 3: Monitor and Optimize
1. Set up monitoring
2. Track costs
3. Optimize performance

## 💰 Cost Analysis

### Free Tier (70 Static Web Apps):
- **Storage**: 140GB (70 × 2GB)
- **Bandwidth**: 7TB (70 × 100GB)
- **Builds**: Unlimited
- **Cost**: $0

### If Exceeding Free Tier:
- **Standard Plan**: $0.20 per GB of bandwidth
- **Premium Plan**: $0.40 per GB of bandwidth

## 🚀 Quick Start Commands

```bash
# 1. Create resource group
az group create --name "soon-online-rg" --location "eastus"

# 2. Create sites
./deploy-all.sh create-batch your-sites.csv

# 3. Create Static Web Apps (automated)
./setup-azure-multi.sh

# 4. Monitor sites
./monitor-sites.sh
```

## 🔧 Troubleshooting

### Common Issues:

1. **Branch not found**: Ensure site branches exist
2. **Domain not working**: Check DNS configuration
3. **Deployment fails**: Verify GitHub secrets
4. **Cost exceeded**: Monitor usage and upgrade plan

### Support Resources:
- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Ready to deploy 70+ sites?** Start with the automated scripts and scale up! 🚀 