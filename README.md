# TubeGuesser - London Underground Daily Puzzle Game

A daily iOS guessing game where players identify London Underground stations based on the lines they serve.

## Features

- 🚇 Daily puzzles featuring stations with 2+ lines
- 🎯 5 guesses per game
- 💡 One hint per day (station trivia)
- 📊 Statistics tracking with win rates and streaks
- 🎨 Authentic London Underground theming
- 💾 Local storage - no internet required

## How to Run

1. Open `TubeGuesser.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Project Structure

```
TubeGuesser/
├── TubeGuesserApp.swift      # App entry point
├── ContentView.swift         # Tab navigation
├── GameView.swift           # Main game interface
├── StatsView.swift          # Statistics display
├── Models.swift             # Data models
├── StationsData.swift       # London Underground data
├── GameManager.swift        # Game logic
└── PersistenceManager.swift # Local storage
```

## Game Rules

- One game per day
- Guess the station name based on the tube lines shown
- Up to 5 guesses allowed
- One hint available per game (reveals station trivia)
- Win by guessing correctly within 5 attempts

## Technical Details

- **Framework**: SwiftUI
- **Storage**: UserDefaults for local persistence
- **Data**: 50+ authentic London Underground stations
- **Theme**: Official TfL colors and design elements

Built with ❤️ for London transport enthusiasts!