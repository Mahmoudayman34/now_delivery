# Apple App Store Review - Response to Guideline 2.1

## Application Information
- **App Name**: Now Delivery (Now Shipping)
- **Bundle ID**: com.nowshipping.courier
- **Version**: 1.0.4+5
- **Category**: Business - Logistics & Delivery Management

---

## Response to Information Needed - Business Model Questions

### 1. Who are the users that will use the paid content in the app?

**Answer:**

The users of this application are **business owners, retailers, and merchants** who operate delivery and shipping services. Specifically:

- Small to medium-sized businesses that need to manage their delivery operations
- E-commerce merchants who handle product deliveries
- Retail stores offering delivery services to customers
- Logistics companies managing multiple delivery routes
- Individual entrepreneurs running courier services

These users utilize the app to:
- Manage and track delivery orders
- Schedule pickups from customers or warehouses
- Monitor their delivery fleet and couriers
- Track financial transactions and payments
- Communicate with end customers about deliveries

**Important Note:** This is a B2B (Business-to-Business) application. End consumers do not use this app. Only registered business accounts with valid business credentials can access the application.

---

### 2. Where can users purchase the subscriptions that can be accessed in the app?

**Answer:**

**There are NO in-app purchases or subscriptions available within the iOS application.**

All subscription plans and payment processing occur **exclusively through our website** at https://nowshipping.co:

- **Registration Process**: Business users must first register on our website (https://nowshipping.co)
- **Subscription Selection**: Users select and purchase their service plan through our web portal
- **Payment Processing**: All payments are processed through our website using external payment processors (not through Apple's IAP)
- **Account Activation**: Once payment is confirmed on the website, the business account is activated
- **Mobile App Access**: Users then log into the mobile app using their activated credentials

**Subscription Tiers** (purchased via website only):
- Free Trial: Limited features for 14 days
- Basic Plan: For small businesses with low delivery volume
- Professional Plan: For medium-sized businesses
- Enterprise Plan: For large-scale logistics operations

**Why subscriptions are not in the app:**
This is a multi-platform business solution (Web, iOS, Android, Desktop). Subscriptions are managed centrally through our web platform to:
- Maintain consistent pricing across all platforms
- Provide unified account management
- Enable enterprise-level features like team management and API access
- Comply with B2B billing requirements (invoices, tax documents, etc.)

---

### 3. What specific types of previously purchased features and services can a user access in the app?

**Answer:**

Users access features based on their **subscription tier purchased through our website**. The mobile app validates the user's account status upon login and enables features accordingly:

**Features Available Based on Subscription:**

**Free Trial Features:**
- Create up to 10 delivery orders
- Basic order tracking
- Single user account
- Standard dashboard with basic analytics

**Basic Plan Features:**
- Unlimited delivery orders
- Customer management
- Order tracking with real-time updates
- Pickup scheduling
- Basic financial reporting
- Email notifications

**Professional Plan Features:**
- All Basic Plan features, plus:
- Advanced analytics and reporting
- Multi-user accounts (up to 5 team members)
- Priority customer support
- Branded delivery notifications
- Export capabilities (CSV, PDF)
- API access for integrations
- Wallet and payment tracking

**Enterprise Plan Features:**
- All Professional Plan features, plus:
- Unlimited team members
- Custom branding and white-labeling
- Dedicated account manager
- Advanced API features
- Custom reporting and analytics
- Integration with accounting software
- SLA guarantees

**How the app accesses these features:**
1. User logs in with credentials
2. App makes API call to our backend (https://nowshipping.co/api/v1)
3. Backend validates JWT token and returns user's subscription tier
4. App enables/disables features based on the subscription level
5. No payment or subscription upgrade occurs within the app

---

### 4. What paid content, subscriptions, or features are unlocked within your app that do not use in-app purchase?

**Answer:**

**ALL subscription features are unlocked through external website purchases, NOT through Apple's In-App Purchase system.**

**Justification for NOT using IAP:**

This application qualifies for the exemption under **App Store Review Guideline 3.1.3(b)** - "Business to Business Apps" because:

1. **B2B Nature**: This app is exclusively for business users managing logistics operations, not for consumer content or services

2. **Multi-Platform Enterprise System**: The subscription provides access to:
   - Web dashboard (primary business management interface)
   - iOS mobile app (for on-the-go management)
   - Android mobile app
   - API access for business integrations
   - Backend infrastructure and storage

3. **Physical Services Component**: The subscription includes:
   - Delivery routing and logistics infrastructure
   - Integration with courier services
   - GPS tracking and mapping services
   - Customer notification systems (SMS, Email)
   - Physical delivery management (not digital content)

4. **Enterprise Billing Requirements**: Business customers require:
   - Corporate invoices with tax documentation
   - Purchase orders and payment terms (Net 30, etc.)
   - Multi-user account management
   - Centralized billing for multiple team members

**Features Unlocked Without IAP:**

All features listed in Question 3 are controlled server-side based on the user's web-purchased subscription:

- **Premium Dashboard Analytics**: Advanced charts and business intelligence
- **Multi-User Access**: Team collaboration features
- **Advanced Reporting**: Comprehensive business reports
- **API Access**: Integration capabilities for enterprise systems
- **Priority Support**: Enhanced customer service
- **Custom Branding**: White-label options for enterprise clients
- **Extended Storage**: Increased order history and data retention

**Important Clarification:**
- Users CANNOT purchase or upgrade subscriptions within the iOS app
- Users CANNOT unlock features through in-app payments
- The app only displays "Upgrade" prompts that redirect to the external website
- All monetization happens outside the app ecosystem

**Compliance Statement:**
We comply with App Store guidelines by:
- Clearly indicating this is a business application
- Not processing any payments within the app
- Redirecting users to our website for subscription management
- Providing transparent information about subscription requirements
- Not using deceptive practices to avoid IAP

---

## Additional Information

### Account Creation Process
1. Users visit https://nowshipping.co
2. Register with business information
3. Select subscription plan
4. Complete payment on website
5. Receive login credentials
6. Download iOS app from App Store
7. Log in with credentials
8. Access features based on subscription tier

### App Functionality Overview
- **Order Management**: Create, track, and manage delivery orders
- **Pickup Scheduling**: Schedule pickups from business locations
- **Customer Management**: Maintain customer delivery information
- **Financial Tracking**: Monitor delivery fees and payments
- **Team Collaboration**: Multiple users can manage operations
- **Real-time Tracking**: GPS-based delivery tracking
- **Reporting**: Business analytics and performance metrics

### Revenue Model
- SaaS (Software as a Service) subscription model
- Charged monthly or annually through website
- Enterprise contracts available for large businesses
- No commission on deliveries
- No transaction fees within the app

---

## Contact Information for Review Team

If Apple's review team needs additional clarification:
- **Support Email**: support@nowshipping.co
- **Website**: https://nowshipping.co
- **Documentation**: Available in app under "Help Center"

We are committed to full transparency and compliance with App Store guidelines. If any modifications are needed, we will promptly address them.

---

*Document prepared for Apple App Store Review Team*
*Date: October 15, 2025*

