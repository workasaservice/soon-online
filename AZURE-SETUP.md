# 🚀 Azure Static Web Apps Setup Guide

## 💰 Free Hosting Benefits

Azure Static Web Apps offers an excellent **FREE tier** with:
- **2GB storage** per app
- **100GB bandwidth** per month
- **Unlimited builds** per month
- **Custom domains** with free SSL certificates
- **Global CDN** for fast loading
- **GitHub integration** for automatic deployments

## 📋 Prerequisites

1. ✅ Code pushed to GitHub (already done)
2. ✅ Azure Static Web Apps workflow configured (already done)
3. 🔄 Azure account (free tier available)

## 🚀 Step 1: Create Azure Account (Free)

1. **Go to Azure**: https://azure.microsoft.com/free/
2. **Sign up for free account**:
   - No credit card required for free tier
   - Get $200 free credits for 12 months
   - Always free services available

## 🏗️ Step 2: Create Azure Static Web App

### Option A: Azure Portal (Recommended)

1. **Go to Azure Portal**: https://portal.azure.com
2. **Create a resource**:
   - Click "Create a resource"
   - Search for "Static Web App"
   - Click "Create"

3. **Configure the app**:
   ```
   Subscription: Your subscription
   Resource Group: Create new (e.g., "soon-online-rg")
   Name: soon-online (or your preferred name)
   Region: Choose closest to your users
   Source: GitHub
   ```

4. **Connect GitHub**:
   - Click "Sign in with GitHub"
   - Authorize Azure
   - Select repository: `workasaservice/soon-online`
   - Branch: `main`

5. **Build configuration**:
   ```
   Build Preset: Custom
   App location: /
   API location: (leave empty)
   Output location: (leave empty)
   ```

6. **Review + Create**: Click create and wait for deployment

### Option B: Azure CLI (Advanced)

```bash
# Install Azure CLI
# macOS: brew install azure-cli
# Windows: Download from Microsoft

# Login to Azure
az login

# Create resource group
az group create --name soon-online-rg --location eastus

# Create Static Web App
az staticwebapp create \
  --name soon-online \
  --resource-group soon-online-rg \
  --source https://github.com/workasaservice/soon-online \
  --branch main \
  --app-location "/" \
  --location eastus
```

## 🔧 Step 3: Configure GitHub Secrets

After creating the Static Web App, Azure will provide a deployment token:

1. **Copy the deployment token** from Azure Portal
2. **Go to your GitHub repository**: https://github.com/workasaservice/soon-online/settings/secrets/actions
3. **Add new repository secret**:
   - Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
   - Value: Paste the deployment token from Azure

## 🌐 Step 4: Configure Custom Domains

### Add Custom Domain in Azure:

1. **Go to your Static Web App** in Azure Portal
2. **Click "Custom domains"**
3. **Click "Add"**
4. **Enter your domain** (e.g., `coming-soon.yourdomain.com`)
5. **Follow DNS configuration instructions**

### DNS Configuration:

#### **For Subdomain (e.g., coming-soon.yourdomain.com):**
```
Type: CNAME
Name: coming-soon
Value: your-app-name.azurestaticapps.net
TTL: 300
```

#### **For Root Domain (yourdomain.com):**
```
Type: CNAME
Name: @
Value: your-app-name.azurestaticapps.net
TTL: 300
```

## ⚙️ Step 5: Environment Configuration

### Add Environment Variables (Optional):

1. **Go to your Static Web App** in Azure Portal
2. **Click "Configuration"**
3. **Add application settings**:
   ```
   ANALYTICS_ID=your-google-analytics-id
   EMAIL_SERVICE_URL=your-backend-api-url
   ```

## 🔍 Step 6: Verify Deployment

### Check Deployment Status:

1. **GitHub Actions**: Go to your repository → Actions tab
2. **Azure Portal**: Check deployment status in your Static Web App
3. **Test URLs**:
   - Azure URL: `https://your-app-name.azurestaticapps.net`
   - Custom domain: `https://yourdomain.com`

### Test Features:

1. **Visit your site**
2. **Check message rotation**
3. **Test email form**
4. **Verify responsive design**
5. **Check HTTPS**

## 📊 Step 7: Monitor Usage

### Free Tier Limits:
- **Storage**: 2GB per app
- **Bandwidth**: 100GB per month
- **Builds**: Unlimited
- **Custom domains**: Unlimited

### Monitor in Azure Portal:
1. **Go to your Static Web App**
2. **Click "Overview"**
3. **Check usage metrics**

## 🔧 Advanced Configuration

### Custom Headers:
The `staticwebapp.config.json` file is already configured with:
- Security headers
- SPA routing
- MIME types
- 404 handling

### Authentication (Optional):
```json
{
  "routes": [
    {
      "route": "/admin/*",
      "allowedRoles": ["authenticated"]
    }
  ]
}
```

### API Integration (Optional):
```json
{
  "routes": [
    {
      "route": "/api/*",
      "serve": "/api"
    }
  ]
}
```

## 🐛 Troubleshooting

### Common Issues:

#### **Deployment Fails**
- Check GitHub Actions logs
- Verify `AZURE_STATIC_WEB_APPS_API_TOKEN` secret
- Ensure workflow file is correct

#### **Custom Domain Not Working**
- Check DNS propagation: https://www.whatsmydns.net/
- Verify CNAME records
- Wait for SSL certificate (up to 24 hours)

#### **404 Errors**
- Check `staticwebapp.config.json` configuration
- Verify all files are in the correct location
- Check Azure Portal for deployment status

#### **Build Errors**
- Check GitHub Actions workflow
- Verify file paths in configuration
- Check for syntax errors in code

## 💡 Best Practices

1. **Use HTTPS**: Always enforce HTTPS
2. **Monitor Usage**: Stay within free tier limits
3. **Regular Updates**: Keep dependencies updated
4. **Backup Configuration**: Save your `staticwebapp.config.json`
5. **Test Locally**: Use Azure Static Web Apps CLI for local testing

## 🛠️ Local Development

### Install Azure Static Web Apps CLI:
```bash
npm install -g @azure/static-web-apps-cli
```

### Run Locally:
```bash
# Start local server
swa start

# Build and serve
swa build
```

## 📞 Support

- **Azure Documentation**: https://docs.microsoft.com/en-us/azure/static-web-apps/
- **GitHub Actions**: Check Actions tab in your repository
- **Azure Support**: Available in Azure Portal

## 🎯 Quick Commands

```bash
# Check deployment status
az staticwebapp show --name your-app-name --resource-group your-rg

# List custom domains
az staticwebapp hostname list --name your-app-name --resource-group your-rg

# Add custom domain
az staticwebapp hostname set --name your-app-name --resource-group your-rg --hostname yourdomain.com
```

---

**Ready to deploy?** Follow the steps above and your Coming Soon page will be live on Azure Static Web Apps with free hosting! 