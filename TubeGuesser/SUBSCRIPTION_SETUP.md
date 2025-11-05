# TubeGuessr In-App Subscriptions Setup

## Overview
I've implemented a complete in-app subscription system for TubeGuessr with a **freemium model focused on unlimited games**:

### 🎯 Premium Features
- **Unlimited Daily Games**: Play as many rounds as you want every day
- **No Daily Limits**: Never wait until tomorrow to play again
- **Advanced Statistics**: Detailed analytics and performance insights
- **Priority Access**: First to try new features and stations
- **Exclusive Content**: Access to premium station collections

### 📁 Files Created
1. **`SubscriptionManager.swift`** - Complete StoreKit 2 implementation
2. **`SubscriptionView.swift`** - Beautiful subscription paywall UI
3. **`Configuration.storekit`** - StoreKit testing configuration
4. **`SUBSCRIPTION_SETUP.md`** - This setup guide

## 🔧 Setup Instructions

### Step 1: Add Files to Xcode Project
1. Open your TubeGuessr project in Xcode
2. Add the following files to your project target:
   - `SubscriptionManager.swift`
   - `SubscriptionView.swift`
   - `Configuration.storekit`

### Step 2: Enable StoreKit in GameView
In `GameView.swift`, replace the mock subscription manager:

```swift
// Replace this line:
@State private var subscriptionManager = MockSubscriptionManager()

// With this:
@StateObject private var subscriptionManager = SubscriptionManager.shared
```

Then uncomment the subscription-related code:
- Subscription initialization in `onAppear`
- Subscription sheet presentation

### Step 3: Configure StoreKit Testing
1. In Xcode, go to **Product > Scheme > Edit Scheme**
2. Select the **Run** tab
3. Go to **Options** tab
4. Under **StoreKit Configuration**, select `Configuration.storekit`

### Step 4: App Store Connect Setup (for production)
1. Create subscription products in App Store Connect:
   - **Monthly**: `com.tubeguessr.premium.monthly` (£0.99/month)
   - **Yearly**: `com.tubeguessr.premium.yearly` ($29.99/year)
2. Both include 1-week free trials
3. Update product IDs in `SubscriptionManager.swift` if needed

## 🎮 How It Works

### Current Implementation
- **Free users**: Get full access to all hints and features, but limited to one game per day
- **Premium users**: Can play unlimited games throughout the day
- **Premium prompt**: Appears after completing a game (for free users only)
- **Crown icon**: Shows in top-left after completing today's game (free users)

### User Flow
1. Free user completes their daily game
2. Premium prompt appears: "Want to play more? Upgrade to Premium for unlimited daily games!"
3. User can upgrade or wait until tomorrow
4. Premium users can immediately start new games

## 🧪 Testing
- **Triple-tap the title "TubeGuessr"** to toggle premium status for testing
- Use the StoreKit configuration file to test purchases
- Test both free and premium user experiences

## 🚀 Next Steps
1. Add the files to your Xcode project target
2. Test subscription flow in simulator
3. Configure App Store Connect products
4. Submit for App Store review

## 💡 Monetization Strategy
- **Free tier**: Full game experience with daily limit (1 game/day)
- **Premium tier**: Unlimited games + advanced features
- **7-day free trial** to encourage conversions
- **Family sharing** disabled to maximize revenue
- **Natural upgrade prompt** after users complete their daily game

This model ensures users get to experience the full game quality before being asked to pay, leading to higher conversion rates!