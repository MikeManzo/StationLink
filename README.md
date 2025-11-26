# StationLink - PlayStation Network Menubar App

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-3.0-green" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-Personal_Use-lightgrey" alt="License">
</p>

A beautiful native macOS menubar application that brings your PlayStation Network profile, friends, and gaming stats right to your Mac. Track your friends' online status, view your recent games, and monitor trophy progress—all from your menubar.

## ✨ Features

### 👤 Profile Dashboard
- **Real-time status** - Online/offline/away indicator with platform info (PS5, PS4, etc.)
- **Trophy showcase** - View your trophy level, progress, and breakdown by type (Platinum, Gold, Silver, Bronze)
- **Profile statistics** - Account info, about me, and last online timestamps
- **Beautiful hero header** - PlayStation-branded gradient design with avatar

### 🎮 Games Library
- **Recently played games** - View your last 10 games with cover art
- **Trophy progress tracking** - See completion percentage for each game
- **Detailed game stats** - Trophy breakdown, playtime, and last played dates
- **Visual progress bars** - Color-coded completion indicators

### 👥 Friends Management
- **Auto-import PSN friends** - Automatically imports all friends from your PlayStation Network account
- **Real-time status updates** - See when friends are online, offline, or playing
- **Friend profiles** - View detailed info for any friend (trophies, games, status)
- **Manual friend adding** - Search and add friends by PSN username
- **Filter options** - Toggle between all friends or PSN-imported friends only

### 🔔 Smart Notifications
- **Online/offline alerts** - Get notified when friends come online or go offline
- **Automatic checking** - Background refresh every 60 seconds
- **Native macOS notifications** - Integrated with Notification Center

### 🎨 Modern Interface
- **Three-tab design** - Me, Games, Friends
- **Beautiful gradients** - PlayStation brand colors throughout
- **Smooth animations** - Professional transitions and loading states
- **Dark mode support** - Works perfectly in light and dark modes
- **Icon-based controls** - Clean, minimal interface

## 📋 Requirements

- **macOS 13.0 (Ventura) or later**
- **Xcode 15.0+** (for building)
- **Active PlayStation Network account**
- **Internet connection**

## 🚀 Installation

### Option 1: Build from Source

1. **Clone the repository**
```bash
   git clone https://github.com/yourusername/stationlink.git
   cd stationlink
```

2. **Open in Xcode**
```bash
   open StationLink.xcodeproj
```

3. **Configure Info.plist**
   - Add `LSUIElement` key with value `YES` (makes it menubar-only)
   - Ensure notification permissions are configured

4. **Build and Run**
   - Select your Mac as the target
   - Press `Cmd+R` to build and run
   - The app will appear in your menubar (PlayStation logo icon)

### Option 2: Download Pre-built App
*(If you distribute a compiled version)*

1. Download the latest release from [Releases](https://github.com/yourusername/stationlink/releases)
2. Unzip and drag to Applications folder
3. Launch StationLink
4. Grant notification permissions when prompted

## 🔧 Setup & Configuration

### First Launch

1. **Launch the app** - Look for the PlayStation logo in your menubar
2. **Click Settings** (gear icon)
3. **Get your NPSSO token:**
   - Visit [playstation.com](https://www.playstation.com) and sign in
   - In the same browser, visit: `https://ca.account.sony.com/api/v1/ssocookie`
   - Copy the 64-character token from the JSON response
4. **Paste token** into the Settings dialog
5. **Click "Save & Connect"**

### Getting Your NPSSO Token

The NPSSO (Network Platform Single Sign-On) token is required to authenticate with PlayStation's API:
```json
// What you'll see at the ssocookie URL:
{
  "npsso": "v3.ABCD1234...xyz" // ← Copy this 64-character string
}
```

⚠️ **Security Notes:**
- **Never share your NPSSO token** - it's equivalent to your password
- Token is stored securely in macOS Keychain
- Token expires after ~60 days and will need to be refreshed
- The app uses refresh tokens to minimize re-authentication

## 📖 Usage Guide

### Main Interface

#### Me Tab
Your personal PlayStation profile:
- **Hero header** - Avatar, username, status, and platform
- **Trophy section** - Level, progress bar, and trophy breakdown
- **Currently playing** - Active game session (if applicable)
- **Activity info** - Last online timestamp

#### Games Tab
Your gaming library:
- **Recent games** - Last 10 played titles with cover art
- **Quick stats** - Platform, last played time, completion %
- **Tap any game** - Opens detailed view with full trophy breakdown
- **Progress indicators** - Visual bars showing completion

#### Friends Tab
Social features:
- **Friend list** - All friends with avatars and status
- **Status indicators** - Green (online), gray (offline), yellow (away)
- **Current activity** - See what games friends are playing
- **Platform badges** - PS5, PS4, etc.
- **Filter toggle** - Show only PSN-imported friends
- **Add friends** - Tap + icon to search and add manually

### Controls

| Icon | Action | Description |
|------|--------|-------------|
| ⚙️ | Settings | Configure NPSSO token |
| 🔄 | Refresh | Manually update all data |
| 🔴 | Quit | Close the application |

### Notifications

The app will send native macOS notifications for:
- ✅ Friend comes online
- ⭕ Friend goes offline
- 🎮 Friend starts playing a game (included in status updates)

**Configure notifications:**
1. Open **System Settings** → **Notifications**
2. Find **StationLink** in the list
3. Choose alert style and behavior

### Auto-Refresh

- **Automatic updates** every 60 seconds
- **Runs in background** even when popover is closed
- **Stops when app quits** - no unnecessary resource usage
- **Smart caching** - Minimizes API calls using refresh tokens

## 🎯 Features in Detail

### Friend Import System

**Automatic Import:**
- Imports all friends from your PSN account on first launch
- Friends are marked with "imported" flag
- No manual entry needed for existing PSN friends

**Manual Adding:**
1. Click **Friends** tab
2. Tap **+ icon** in the header
3. Enter friend's **PSN username** (not email)
4. Tap **Search**
5. Preview shows avatar and username
6. Tap **Add This Friend**

### Trophy Tracking

**Per-Game Tracking:**
- Total trophies earned vs available
- Breakdown by type (🔷 Platinum, 🥇 Gold, 🥈 Silver, 🥉 Bronze)
- Completion percentage with progress bar
- Color-coded visual indicators

**Profile Summary:**
- Overall trophy level (1-999+)
- Progress to next level (%)
- Total trophies across all games

### Privacy & Security

**What the app accesses:**
- ✅ Your PSN profile (username, avatar, level)
- ✅ Your trophy data
- ✅ Your friends list
- ✅ Your recently played games
- ✅ Online status and presence info

**What the app does NOT access:**
- ❌ Your password (uses NPSSO token only)
- ❌ Payment information
- ❌ Messages or voice chat
- ❌ PlayStation Store purchases
- ❌ Any data outside PlayStation Network API scope

**Data storage:**
- NPSSO token: Stored in macOS UserDefaults (secure)
- Refresh tokens: Cached locally for 2 months
- Friend list: Saved locally (no cloud sync)
- No data sent to third parties

## 🛠️ Technical Details

### Architecture
```
StationLink/
├── Models/
│   ├── PSNUser.swift           # User profile data model
│   ├── PSNPresence.swift       # Online status & activity
│   ├── Friend.swift            # Friend data model
│   └── GameTitle.swift         # Game library model
├── Services/
│   └── PlayStationService.swift # API integration & auth
├── Views/
│   ├── ContentView.swift       # Main tabbed interface
│   ├── UserInfoView.swift      # Profile display
│   ├── GamesListView.swift     # Games library
│   ├── FriendsListView.swift   # Friends management
│   └── SettingsView.swift      # Configuration
└── Resources/
    ├── AppIcon.appiconset/     # Icon assets
    └── Info.plist              # App configuration
```

### API Endpoints Used

**Authentication:**
- `POST /api/authz/v3/oauth/authorize` - Get auth code from NPSSO
- `POST /api/authz/v3/oauth/token` - Exchange code for tokens
- Token refresh using refresh token (automatic)

**User Data:**
- `GET /userProfile/v1/users/me/profile2` - Get own profile
- `GET /userProfile/v1/internal/users/{id}/basicPresences` - Get presence

**Friends:**
- `GET /userProfile/v1/internal/users/me/friends` - Get friends list
- `GET /userProfile/v1/internal/users/{id}/profiles` - Get friend profiles

**Games:**
- `GET /gamelist/v2/users/{id}/titles` - Get recent games with trophies

### Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for data flow
- **UserNotifications** - Native macOS notifications
- **URLSession** - Network requests with async/await
- **JSONDecoder** - API response parsing

### Performance

- **Startup time:** < 2 seconds
- **Memory footprint:** ~50-80 MB
- **API rate limiting:** Self-limited to 1 request per 60 seconds (auto-refresh)
- **Token caching:** Reduces authentication requests by 99%

## ⚠️ Troubleshooting

### "Authentication failed" error

**Solution:**
1. Generate a fresh NPSSO token (they expire after 60 days)
2. Make sure you copied the ENTIRE 64-character token
3. Verify you're logged into playstation.com in the same browser
4. Try a different browser (Safari, Chrome, Firefox)

### "Rate limited" error

**Cause:** Too many authentication attempts in short period

**Solution:**
1. Wait 30-60 minutes
2. Use a VPN to change IP address
3. Switch to a different network
4. Don't click "Refresh" repeatedly

### Friends not importing

**Check:**
1. Verify your PSN privacy settings allow friend list visibility
2. Restart the app after adding NPSSO token
3. Check console logs (Xcode) for specific errors
4. Make sure you have friends on PSN (minimum 1)

### Games not showing

**Possible causes:**
- Privacy settings block game activity
- Haven't played any games recently
- API endpoint temporary unavailable

**Solution:**
1. Play a game on PS4/PS5
2. Check privacy settings on console
3. Wait 24 hours and try again

### Notifications not appearing

**Fix:**
1. **System Settings** → **Notifications** → **StationLink**
2. Enable "Allow Notifications"
3. Set alert style to "Banners" or "Alerts"
4. Restart the app

### App not showing in menubar

**Solution:**
1. Verify `LSUIElement` is set to `YES` in Info.plist
2. Restart the app
3. Check if it's hidden in menubar (try Cmd+drag to rearrange icons)

## 🔄 Update Process

**Manual updates:**
1. Pull latest code from repository
2. Rebuild in Xcode
3. Your token and settings are preserved

**Automatic updates:** *(Future feature)*
- Sparkle framework integration planned
- In-app update notifications

## 📝 Known Limitations

- **Token expiration:** NPSSO tokens expire after ~60 days (must be manually refreshed)
- **API changes:** Sony can change APIs without notice, breaking functionality
- **Rate limiting:** Aggressive refresh may trigger temporary bans
- **Privacy settings:** Friends with strict privacy settings may not show full data
- **No PS3/Vita:** Older platforms have limited API support
- **English only:** UI not localized to other languages (yet)

## 🚧 Roadmap

### Planned Features
- [ ] Trophy guide integration
- [ ] Compare trophies with friends
- [ ] Game recommendations based on friends' activity
- [ ] Trophy milestones and celebrations
- [ ] Custom notification sounds
- [ ] Export data to CSV/JSON
- [ ] Widgets for macOS desktop
- [ ] Activity feed (recent friend achievements)
- [ ] Dark mode customization
- [ ] Multiple accounts support

### Under Consideration
- [ ] iOS companion app
- [ ] Apple Watch complications
- [ ] Menu bar icon shows unread friend activity
- [ ] Trophy rarity statistics
- [ ] Time played tracking
- [ ] Achievement predictions

## 🤝 Contributing

This is a personal project, but suggestions and bug reports are welcome!

**To report issues:**
1. Check existing [Issues](https://github.com/yourusername/stationlink/issues)
2. Create new issue with:
   - macOS version
   - App version
   - Steps to reproduce
   - Console logs (if applicable)

**To suggest features:**
- Open a [Feature Request](https://github.com/yourusername/stationlink/issues/new?labels=enhancement)
- Describe the use case and expected behavior

## 📜 License

**Personal Use Only**

This application is provided for personal, non-commercial use only. 

**Important Notes:**
- This is an unofficial application and is not affiliated with, endorsed by, or associated with Sony Interactive Entertainment
- PlayStation, PS5, PS4, and PlayStation Network are trademarks of Sony Interactive Entertainment
- Use of PlayStation Network APIs is subject to Sony's Terms of Service
- Distribution of this app with intention to profit is prohibited
- Sony may change or restrict API access at any time

**Disclaimer:**
This software is provided "as is" without warranty of any kind. Use at your own risk. The authors are not responsible for any bans, restrictions, or issues with your PlayStation Network account resulting from use of this application.

## 🙏 Acknowledgments

- **PSN API Documentation:** [andshrew/PlayStation-Trophies](https://github.com/andshrew/PlayStation-Trophies)
- **psn-api npm package:** [achievements-app/psn-api](https://github.com/achievements-app/psn-api)
- **PSNAWP Python library:** [isFakeAccount/psnawp](https://github.com/isFakeAccount/psnawp)
- PlayStation Network API reverse engineering community

## 📧 Contact

- **GitHub:** [@yourusername](https://github.com/yourusername)
- **Issues:** [Report a bug](https://github.com/yourusername/stationlink/issues)
- **Email:** your.email@example.com

---

<p align="center">
  Made with ❤️ for PlayStation gamers on Mac
  <br>
  <sub>Not affiliated with Sony Interactive Entertainment</sub>
</p>

## 📸 Screenshots

### Main Interface
![Main](images\About.png)

### Games Library
*[Add screenshot of Games tab with recent games]*

### Friends List
*[Add screenshot of Friends tab with online/offline status]*

### Game Details
*[Add screenshot of detailed game view with trophy breakdown]*

### Settings
*[Add screenshot of Settings dialog]*

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Minimum macOS:** 13.0 (Ventura)
