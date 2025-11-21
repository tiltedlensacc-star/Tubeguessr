# TubeGuesser - App Store Submission Setup Guide

This guide will help you fix the App Store rejection and successfully resubmit your app.

## Overview

Your app was rejected because it's missing functional links to Terms of Use (EULA) and Privacy Policy. This guide will help you:
1. Host these documents on GitHub Pages
2. Add them to your app
3. Update App Store Connect metadata

---

## Step 1: Add SettingsView.swift to Xcode Project

1. Open `TubeGuesser.xcodeproj` in Xcode
2. Right-click on the `TubeGuesser` folder in the Project Navigator
3. Select "Add Files to TubeGuesser..."
4. Navigate to and select `TubeGuesser/SettingsView.swift`
5. Make sure "Copy items if needed" is checked
6. Click "Add"
7. Build the project (⌘+B) to verify no errors

---

## Step 2: Set Up GitHub Repository and GitHub Pages

### Create GitHub Repository

1. Go to [github.com](https://github.com) and sign in
2. Click the "+" icon in the top right and select "New repository"
3. Name your repository (e.g., "tubeguessr" or "TubeGuesser")
4. Make it **Public** (required for GitHub Pages free tier)
5. Don't initialize with README (your project already has one)
6. Click "Create repository"

### Connect Your Local Repository to GitHub

```bash
cd /Users/inkduangsri/Desktop/Platformed/Platformed/Platformed

# Add the remote (replace YOUR_GITHUB_USERNAME and YOUR_REPO_NAME)
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git

# Verify the remote was added
git remote -v
```

### Commit and Push Your Code

```bash
# Add all files including the new docs folder
git add .

# Commit the changes
git commit -m "Add legal documents and settings view for App Store submission"

# Push to GitHub
git push -u origin main
```

### Enable GitHub Pages

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Scroll down to "Pages" in the left sidebar
4. Under "Source", select **"Deploy from a branch"**
5. Under "Branch", select **"main"** and **"/docs"**
6. Click "Save"
7. Wait 1-2 minutes for deployment
8. Your site will be available at: `https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME`

---

## Step 3: Update URLs in Your App

After GitHub Pages is deployed, update the placeholder URLs in your code:

### Files to Update:

1. **TubeGuesser/SettingsView.swift** (line 6)
   ```swift
   private let baseURL = "https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME"
   ```
   Change to your actual URL.

2. **TubeGuesser/SubscriptionView.swift** (lines 198 and 201)
   ```swift
   Link("Privacy Policy", destination: URL(string: "https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/privacy-policy.html")!)

   Link("Terms of Service", destination: URL(string: "https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/terms.html")!)
   ```
   Change to your actual URLs.

### Test the URLs

After updating, test the links:
1. Build and run your app on simulator/device (⌘+R)
2. Go to the "About" tab
3. Tap each link to verify they open correctly in Safari
4. Also test links in the subscription view

---

## Step 4: Update App Store Connect Metadata

### In App Store Connect:

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app (TubeGuesser)
3. Go to the version that was rejected
4. Click "Edit" or "Prepare for Submission"

### Update App Information:

**App Description (add at the end):**
```
Terms of Service: https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/terms.html
```

**Support URL:**
```
https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/support.html
```

**Privacy Policy URL:**
```
https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/privacy-policy.html
```

### Update Subscription Information:

1. Go to "Features" → "In-App Purchases"
2. Select your "Season Ticket" subscription
3. Add the Terms of Service URL if there's a field for it

---

## Step 5: Build and Submit New Version

### Create New Build:

1. In Xcode, increment the build number:
   - Select your project in the Project Navigator
   - Select the "TubeGuesser" target
   - Go to "General" tab
   - Increment the "Build" number (e.g., from 1 to 2)

2. Archive the app:
   - Select "Any iOS Device (arm64)" as the build destination
   - Menu: Product → Archive
   - Wait for archive to complete

3. Distribute to App Store:
   - In the Organizer window that appears, click "Distribute App"
   - Select "App Store Connect"
   - Click "Upload"
   - Follow the prompts to upload the new build

### Resubmit for Review:

1. In App Store Connect, select the new build
2. Review all information (make sure URLs are added!)
3. Click "Submit for Review"

---

## Step 6: App Review Notes (Optional but Recommended)

In the "App Review Information" section, add a note to the reviewer:

```
Hello,

This is a resubmission addressing the previous rejection regarding missing Terms of Use and Privacy Policy links.

Changes made:
- Added a new "About" tab in the app with functional links to Privacy Policy, Terms of Service, and Support pages
- Updated subscription view to include functional links to legal documents
- All legal documents are now hosted and accessible at:
  * Privacy Policy: https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/privacy-policy.html
  * Terms of Service: https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/terms.html
  * Support: https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/support.html

Please let me know if you need any additional information.

Thank you!
```

---

## Verification Checklist

Before resubmitting, verify:

- [ ] SettingsView.swift is added to Xcode project and builds successfully
- [ ] GitHub repository is created and code is pushed
- [ ] GitHub Pages is enabled and URLs are accessible in browser
- [ ] All placeholder URLs in the code are updated to actual GitHub Pages URLs
- [ ] Links work correctly when tested in the app (tap each one)
- [ ] App Store Connect metadata includes all three URLs
- [ ] Build number is incremented
- [ ] New build is uploaded to App Store Connect
- [ ] App description includes Terms of Service URL

---

## Testing Your Implementation

### Test in the App:

1. **About Tab:**
   - Open the app
   - Navigate to "About" tab
   - Tap "Privacy Policy" → should open in Safari
   - Tap "Terms of Service" → should open in Safari
   - Tap "Help & Support" → should open in Safari

2. **Subscription View:**
   - Go to Game tab
   - Tap "Get Season Ticket" button
   - Scroll to bottom
   - Tap "Privacy Policy" and "Terms of Service" links
   - Verify they open correctly

### Test URLs in Browser:

Open these URLs in Safari to verify they load:
- `https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/`
- `https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/privacy-policy.html`
- `https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/terms.html`
- `https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/support.html`

---

## What Changed in Your App

### New Files:
- `TubeGuesser/SettingsView.swift` - New "About" tab with legal links
- `docs/` folder - Contains all legal documents for GitHub Pages
  - `index.html` - Landing page for your GitHub Pages site
  - `terms.html` - Terms of Service
  - `privacy-policy.html` - Privacy Policy
  - `support.html` - Support page

### Modified Files:
- `TubeGuesser/ContentView.swift` - Added "About" tab to TabView
- `TubeGuesser/SubscriptionView.swift` - Made legal links functional

---

## Troubleshooting

### GitHub Pages Not Loading:
- Wait 2-3 minutes after enabling GitHub Pages
- Check that the repository is Public
- Verify you selected "/docs" folder as source
- Check GitHub Actions tab for deployment status

### Links Not Working in App:
- Verify URLs are correct (no typos, correct username/repo name)
- Make sure URLs use `https://` not `http://`
- Test URLs in Safari browser first
- Rebuild the app after changing URLs

### App Store Still Rejecting:
- Verify all three URLs are added to App Store Connect
- Make sure URLs are publicly accessible (test in incognito browser)
- Include the app review note explaining the changes
- Contact App Store support if issue persists

---

## Need Help?

If you encounter issues:
1. Check that GitHub Pages is deployed and URLs are accessible
2. Verify all placeholder text is replaced with actual values
3. Test all links in the app before submitting
4. Make sure App Store Connect has all required URLs

Good luck with your resubmission! 🚇
