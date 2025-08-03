# 🚀 Quick Deployment Guide

## Azure Static Web Apps (Recommended)

### Step 1: Prepare Your Repository
1. Push your code to GitHub
2. Ensure you have the following files:
   - `index.html`
   - `styles.css`
   - `script.js`
   - `staticwebapp.config.json`
   - `.github/workflows/azure-static-web-apps.yml`

### Step 2: Create Azure Static Web App
1. Go to [Azure Portal](https://portal.azure.com)
2. Click "Create a resource"
3. Search for "Static Web App"
4. Click "Create"

### Step 3: Configure the App
1. **Basics**:
   - Subscription: Choose your subscription
   - Resource Group: Create new or use existing
   - Name: Your app name (e.g., "my-coming-soon")
   - Region: Choose closest to your users
   - Source: GitHub

2. **Build Details**:
   - Organization: Your GitHub organization
   - Repository: Your repository name
   - Branch: `main` or `master`
   - Build Preset: Custom
   - App location: `/`
   - API location: Leave empty
   - Output location: Leave empty

3. **Review + Create**: Click create and wait for deployment

### Step 4: Configure Custom Domain (Optional)
1. Go to your Static Web App in Azure Portal
2. Click "Custom domains"
3. Click "Add"
4. Enter your domain name
5. Follow the DNS configuration instructions

## Alternative Platforms

### Netlify
1. Go to [netlify.com](https://netlify.com)
2. Drag and drop your project folder
3. Your site is live!

### Vercel
1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repository
3. Deploy automatically

### GitHub Pages
1. Go to your repository settings
2. Scroll to "Pages" section
3. Select source branch
4. Save

## Environment Variables (Optional)

Add these in your hosting platform's settings:

```
ANALYTICS_ID=your-google-analytics-id
EMAIL_SERVICE_URL=your-backend-api-url
```

## Testing Your Deployment

1. Visit your deployed URL
2. Check that messages are rotating
3. Test the email form
4. Verify responsive design on mobile
5. Check that all animations work

## Troubleshooting

### Common Issues:
- **404 errors**: Ensure `staticwebapp.config.json` is configured correctly
- **Styling issues**: Check that all CSS files are being served
- **JavaScript errors**: Verify all JS files are loaded
- **Domain issues**: Check DNS configuration

### Support:
- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [GitHub Issues](https://github.com/your-repo/issues)

---

**Need help?** Check the main README.md for detailed instructions! 