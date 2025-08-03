# 🚀 Coming Soon Page

A beautiful, modern "Coming Soon" page with rotating funny and inspiring messages. Perfect for projects that are still in development or for creating anticipation for your next big thing!

## ✨ Features

- **Modern Design**: Clean, responsive design with beautiful gradients and animations
- **Rotating Messages**: 20+ funny and inspiring messages that rotate automatically
- **Interactive Elements**: Hover effects, click animations, and parallax effects
- **Email Collection**: Built-in email signup form (frontend only - customize for your backend)
- **Responsive**: Works perfectly on desktop, tablet, and mobile devices
- **Easter Eggs**: Hidden interactive elements for fun
- **One-Click Deployment**: Ready for Azure Static Web Apps deployment

## 🎨 Customization

### Messages
Edit the `messages` array in `script.js` to customize the rotating messages:

```javascript
const messages = [
    "Your custom message here...",
    "Another inspiring message...",
    // Add more messages
];
```

### Colors and Styling
Modify the CSS variables in `styles.css` to change the color scheme:

```css
body {
    background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
}
```

### Logo and Branding
- Change the emoji in the logo section of `index.html`
- Update the title and meta description
- Customize social media links

## 🚀 Deployment

### Option 1: Azure Static Web Apps (Recommended)

1. **Fork or clone this repository**
2. **Create Azure Static Web App**:
   - Go to Azure Portal
   - Create a new Static Web App
   - Connect your GitHub repository
   - Azure will automatically set up the GitHub Actions workflow

3. **Configure Custom Domain** (Optional):
   - In your Static Web App settings
   - Add custom domain
   - Update DNS records as instructed

### Option 2: Manual Deployment

1. Upload all files to your web server
2. Ensure your server is configured to serve `index.html` for all routes
3. Update the `staticwebapp.config.json` for your server configuration

### Option 3: Other Platforms

This works with any static hosting service:
- **Netlify**: Drag and drop the folder
- **Vercel**: Connect your GitHub repository
- **GitHub Pages**: Enable in repository settings
- **Firebase Hosting**: Use Firebase CLI

## 📁 File Structure

```
soon-online/
├── index.html              # Main HTML file
├── styles.css              # CSS styles and animations
├── script.js               # JavaScript functionality
├── staticwebapp.config.json # Azure Static Web Apps config
├── .github/
│   └── workflows/
│       └── azure-static-web-apps.yml # GitHub Actions workflow
└── README.md               # This file
```

## 🛠️ Development

### Local Development
1. Clone the repository
2. Open `index.html` in your browser
3. Or use a local server:
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js
   npx serve .
   ```

### Customization Guide

#### Adding New Messages
1. Open `script.js`
2. Find the `messages` array
3. Add your new messages

#### Changing Colors
1. Open `styles.css`
2. Modify the gradient in the `body` selector
3. Update accent colors as needed

#### Adding Features
- **Analytics**: Add Google Analytics or other tracking
- **Backend Integration**: Connect the email form to your backend
- **Social Media**: Update social links with your actual profiles

## 🎯 Use Cases

- **Product Launches**: Create anticipation for new products
- **Website Redesigns**: Show while your site is being updated
- **Beta Testing**: Collect emails for beta access
- **Event Promotion**: Build excitement for upcoming events
- **Personal Projects**: Showcase work in progress

## 🔧 Configuration

### Azure Static Web Apps Settings

The `staticwebapp.config.json` file includes:
- **SPA Routing**: All routes serve `index.html`
- **Security Headers**: XSS protection, content type options
- **MIME Types**: Proper file type handling
- **404 Handling**: Graceful fallback to main page

### Environment Variables

For production deployment, you may want to add:
- `ANALYTICS_ID`: Google Analytics tracking ID
- `EMAIL_SERVICE_URL`: Backend API for email collection
- `SOCIAL_LINKS`: JSON object with social media URLs

## 🎨 Design Features

- **Gradient Background**: Beautiful purple-blue gradient
- **Floating Animations**: Subtle background elements
- **Smooth Transitions**: CSS animations for all interactions
- **Glass Morphism**: Modern backdrop blur effects
- **Responsive Typography**: Scales perfectly on all devices

## 🐛 Troubleshooting

### Common Issues

1. **Messages not rotating**: Check browser console for JavaScript errors
2. **Styling issues**: Ensure all CSS files are loaded
3. **Deployment fails**: Verify Azure Static Web Apps configuration
4. **Domain not working**: Check DNS settings and Azure configuration

### Browser Support

- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)
- ✅ Mobile browsers

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you need help with deployment or customization:
1. Check the troubleshooting section
2. Review Azure Static Web Apps documentation
3. Open an issue in this repository

---

**Made with ❤️ for the developer community** 