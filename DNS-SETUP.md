# 🌐 DNS Setup Guide for GitHub Pages

## 📋 Prerequisites

1. ✅ Code pushed to GitHub repository
2. ✅ GitHub Pages workflow added
3. ✅ Custom domain name ready

## 🚀 Step 1: Enable GitHub Pages

1. **Go to your repository**: https://github.com/workasaservice/soon-online
2. **Navigate to Settings** → **Pages**
3. **Source**: Select "GitHub Actions"
4. **Save the settings**

## 🌍 Step 2: Configure Custom Domain

### Option A: Single Domain
1. In **Settings** → **Pages**
2. **Custom domain**: Enter your domain (e.g., `coming-soon.yourdomain.com`)
3. **Save**
4. Check "Enforce HTTPS" (recommended)

### Option B: Multiple Domains
1. Create a `CNAME` file in your repository root
2. Add your domains (one per line):
   ```
   coming-soon.yourdomain.com
   www.yourdomain.com
   yourdomain.com
   ```

## 🔧 Step 3: DNS Configuration

### For Different Domain Providers:

#### **Cloudflare**
1. Go to your Cloudflare dashboard
2. Select your domain
3. Go to **DNS** → **Records**
4. Add these records:

   **For subdomain (e.g., coming-soon.yourdomain.com):**
   ```
   Type: CNAME
   Name: coming-soon
   Target: workasaservice.github.io
   Proxy status: DNS only (gray cloud)
   ```

   **For root domain (yourdomain.com):**
   ```
   Type: CNAME
   Name: @
   Target: workasaservice.github.io
   Proxy status: DNS only (gray cloud)
   ```

   **For www subdomain:**
   ```
   Type: CNAME
   Name: www
   Target: workasaservice.github.io
   Proxy status: DNS only (gray cloud)
   ```

#### **GoDaddy**
1. Go to your GoDaddy DNS management
2. Add these records:

   **For subdomain:**
   ```
   Type: CNAME
   Host: coming-soon
   Points to: workasaservice.github.io
   TTL: 600 (or default)
   ```

   **For root domain:**
   ```
   Type: CNAME
   Host: @
   Points to: workasaservice.github.io
   TTL: 600 (or default)
   ```

#### **Namecheap**
1. Go to **Domain List** → **Manage** → **Advanced DNS**
2. Add these records:

   **For subdomain:**
   ```
   Type: CNAME Record
   Host: coming-soon
   Value: workasaservice.github.io
   TTL: Automatic
   ```

   **For root domain:**
   ```
   Type: CNAME Record
   Host: @
   Value: workasaservice.github.io
   TTL: Automatic
   ```

#### **AWS Route 53**
1. Go to Route 53 console
2. Select your hosted zone
3. Create records:

   **For subdomain:**
   ```
   Record type: CNAME
   Record name: coming-soon
   Value: workasaservice.github.io
   TTL: 300
   ```

   **For root domain:**
   ```
   Record type: CNAME
   Record name: (leave empty for root)
   Value: workasaservice.github.io
   TTL: 300
   ```

## ⏱️ Step 4: Wait for Propagation

DNS changes can take up to 48 hours to propagate globally, but usually take effect within:
- **Cloudflare**: 5-10 minutes
- **GoDaddy**: 30 minutes - 2 hours
- **Namecheap**: 30 minutes - 2 hours
- **Route 53**: 5-10 minutes

## ✅ Step 5: Verify Setup

1. **Check GitHub Pages status**:
   - Go to repository → **Settings** → **Pages**
   - Should show "Your site is live at https://yourdomain.com"

2. **Test your domain**:
   - Visit your custom domain
   - Should show the Coming Soon page

3. **Check HTTPS**:
   - Ensure HTTPS is working
   - GitHub Pages provides free SSL certificates

## 🔍 Troubleshooting

### Common Issues:

#### **Domain not working**
- Check DNS propagation: https://www.whatsmydns.net/
- Verify CNAME records are correct
- Ensure no conflicting A records

#### **HTTPS not working**
- Wait 24 hours for SSL certificate
- Check "Enforce HTTPS" in GitHub Pages settings
- Clear browser cache

#### **404 errors**
- Ensure GitHub Pages is enabled
- Check workflow is running successfully
- Verify custom domain is set correctly

#### **Multiple domains not working**
- Check CNAME file format
- Ensure one domain per line
- Remove any extra spaces or characters

## 📞 Support

- **GitHub Pages Documentation**: https://docs.github.com/en/pages
- **DNS Propagation Checker**: https://www.whatsmydns.net/
- **GitHub Support**: https://support.github.com/

## 🎯 Quick Commands

```bash
# Check DNS propagation
dig yourdomain.com
nslookup yourdomain.com

# Test HTTPS
curl -I https://yourdomain.com

# Check GitHub Pages status
curl -I https://workasaservice.github.io/soon-online/
```

---

**Need help?** Check the main README.md or open an issue in the repository! 