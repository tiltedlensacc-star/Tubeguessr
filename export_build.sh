#!/bin/bash

# TubeGuesser Build Export Script
# This script archives and exports your app for App Store/TestFlight

set -e  # Exit on error

PROJECT_PATH="/Users/inkduangsri/Desktop/Platformed/Platformed/Platformed/TubeGuesser.xcodeproj"
SCHEME="TubeGuesser"
ARCHIVE_PATH="$HOME/Desktop/TubeGuesser.xcarchive"
EXPORT_PATH="$HOME/Desktop/TubeGuesser_Export"

echo "🔨 Starting build process for TubeGuesser..."

# Step 1: Clean build folder
echo "🧹 Cleaning build folder..."
xcodebuild clean -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration Release

# Step 2: Create archive
echo "📦 Creating archive..."
xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS'

# Step 3: Create export options plist
echo "⚙️  Creating export options..."
cat > /tmp/ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF

# Step 4: Export archive
echo "📤 Exporting archive..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist /tmp/ExportOptions.plist

echo "✅ Build exported successfully!"
echo "📁 Archive location: $ARCHIVE_PATH"
echo "📁 Export location: $EXPORT_PATH"
echo ""
echo "Next steps:"
echo "1. Open Xcode → Window → Organizer"
echo "2. Find your archive and click 'Distribute App'"
echo "3. Or upload the .ipa file using Transporter app"
