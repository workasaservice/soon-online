// Array of funny and inspiring messages
const messages = [
    "Something amazing is brewing...",
    "Loading awesome things...",
    "Preparing to blow your mind...",
    "Assembling the dream team...",
    "Cooking up something special...",
    "Almost ready to launch...",
    "Adding the final touches...",
    "Making it perfect for you...",
    "Gathering the best ideas...",
    "Building the future...",
    "Creating something legendary...",
    "Preparing for greatness...",
    "Adding some magic...",
    "Getting everything just right...",
    "Almost there, promise!",
    "Loading infinite possibilities...",
    "Preparing to change the world...",
    "Adding the secret sauce...",
    "Making dreams come true...",
    "Building something epic..."
];

// Progress bar texts
const progressTexts = [
    "Loading awesome things...",
    "Preparing launch sequence...",
    "Assembling components...",
    "Adding finishing touches...",
    "Almost ready...",
    "Final preparations...",
    "Loading magic...",
    "Preparing for takeoff..."
];

let currentMessageIndex = 0;
let currentProgressIndex = 0;

// DOM elements
const messageElement = document.getElementById('message');
const progressFill = document.getElementById('progressFill');
const progressText = document.querySelector('.progress-text');
const emailForm = document.getElementById('emailForm');

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
    // Start message rotation
    rotateMessages();
    
    // Start progress text rotation
    rotateProgressText();
    
    // Add form submission handler
    if (emailForm) {
        emailForm.addEventListener('submit', handleEmailSubmission);
    }
    
    // Add some interactive effects
    addInteractiveEffects();
});

// Rotate messages every 3 seconds
function rotateMessages() {
    setInterval(() => {
        currentMessageIndex = (currentMessageIndex + 1) % messages.length;
        
        // Fade out
        messageElement.style.opacity = '0';
        messageElement.style.transform = 'translateY(10px)';
        
        setTimeout(() => {
            messageElement.textContent = messages[currentMessageIndex];
            messageElement.style.opacity = '1';
            messageElement.style.transform = 'translateY(0)';
        }, 300);
    }, 3000);
}

// Rotate progress text every 2 seconds
function rotateProgressText() {
    setInterval(() => {
        currentProgressIndex = (currentProgressIndex + 1) % progressTexts.length;
        
        // Fade out
        progressText.style.opacity = '0';
        
        setTimeout(() => {
            progressText.textContent = progressTexts[currentProgressIndex];
            progressText.style.opacity = '0.8';
        }, 200);
    }, 2000);
}

// Handle email form submission
function handleEmailSubmission(e) {
    e.preventDefault();
    
    const emailInput = emailForm.querySelector('input[type="email"]');
    const email = emailInput.value.trim();
    
    if (!email) {
        showNotification('Please enter a valid email address', 'error');
        return;
    }
    
    // Simulate form submission
    const submitButton = emailForm.querySelector('button');
    const originalText = submitButton.textContent;
    
    submitButton.textContent = 'Subscribing...';
    submitButton.disabled = true;
    
    // Simulate API call
    setTimeout(() => {
        showNotification('Thanks! You\'ll be the first to know when we launch! 🚀', 'success');
        emailInput.value = '';
        submitButton.textContent = originalText;
        submitButton.disabled = false;
    }, 1500);
}

// Show notification
function showNotification(message, type = 'info') {
    // Remove existing notification
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-message">${message}</span>
            <button class="notification-close">&times;</button>
        </div>
    `;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? 'rgba(76, 175, 80, 0.9)' : 'rgba(244, 67, 54, 0.9)'};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        z-index: 1000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255,255,255,0.2);
    `;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Add close functionality
    const closeButton = notification.querySelector('.notification-close');
    closeButton.style.cssText = `
        background: none;
        border: none;
        color: white;
        font-size: 1.2rem;
        cursor: pointer;
        margin-left: 1rem;
        opacity: 0.8;
        transition: opacity 0.2s;
    `;
    
    closeButton.addEventListener('click', () => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => notification.remove(), 300);
    });
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => notification.remove(), 300);
        }
    }, 5000);
}

// Add interactive effects
function addInteractiveEffects() {
    // Add hover effects to features
    const features = document.querySelectorAll('.feature');
    features.forEach(feature => {
        feature.addEventListener('mouseenter', () => {
            feature.style.transform = 'scale(1.05)';
            feature.style.transition = 'transform 0.3s ease';
        });
        
        feature.addEventListener('mouseleave', () => {
            feature.style.transform = 'scale(1)';
        });
    });
    
    // Add click effect to logo
    const logo = document.querySelector('.logo');
    if (logo) {
        logo.addEventListener('click', () => {
            logo.style.transform = 'scale(0.9)';
            setTimeout(() => {
                logo.style.transform = 'scale(1)';
            }, 150);
        });
    }
    
    // Add parallax effect to floating elements
    document.addEventListener('mousemove', (e) => {
        const floatingElements = document.querySelectorAll('.floating-element');
        const mouseX = e.clientX / window.innerWidth;
        const mouseY = e.clientY / window.innerHeight;
        
        floatingElements.forEach((element, index) => {
            const speed = (index + 1) * 0.5;
            const x = (mouseX - 0.5) * speed;
            const y = (mouseY - 0.5) * speed;
            
            element.style.transform = `translate(${x}px, ${y}px)`;
        });
    });
}

// Add some Easter eggs
document.addEventListener('keydown', (e) => {
    // Konami code easter egg
    if (e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
        const emoji = document.querySelector('.emoji');
        if (emoji) {
            emoji.textContent = '🎮';
            setTimeout(() => {
                emoji.textContent = '🚀';
            }, 1000);
        }
    }
    
    // Space bar easter egg
    if (e.code === 'Space') {
        e.preventDefault();
        const title = document.querySelector('.title');
        if (title) {
            title.style.animation = 'bounce 0.5s ease';
            setTimeout(() => {
                title.style.animation = '';
            }, 500);
        }
    }
});

// Add smooth scrolling for any anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add loading animation
window.addEventListener('load', () => {
    document.body.style.opacity = '0';
    document.body.style.transition = 'opacity 0.5s ease';
    
    setTimeout(() => {
        document.body.style.opacity = '1';
    }, 100);
}); 