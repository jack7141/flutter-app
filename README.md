# Celeb Voice

AI-powered celebrity voice messaging app built with Flutter.

## Features

- Social login (Google, Kakao, Naver)
- AI-powered celebrity voice generation
- Daily message generation
- User profile management
- TTS (Text-to-Speech) functionality

## Tech Stack

- **Framework**: Flutter 3.32.4
- **State Management**: Riverpod 2.6.1
- **Navigation**: Go Router 14.8.1
- **Authentication**: 
  - Google Sign-In 6.3.0
  - Kakao Flutter SDK 1.9.7+3
  - Naver Login SDK 3.0.2
  - Sign in with Apple 7.0.1
- **HTTP Client**: Dio 5.8.0+1
- **Storage**: 
  - Flutter Secure Storage 9.2.4
  - Shared Preferences 2.5.3
- **UI**: 
  - Google Fonts 6.2.1
  - Font Awesome Flutter 10.8.0
- **Media**: 
  - Audio Players 6.5.0
  - YouTube Player Flutter 9.1.1
  - Flutter InAppWebView 6.1.5

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.32.4
- **Dart SDK**: 3.8.1
- **iOS**: Xcode 16.4 (Build 16F6)
- **Android**: Android Studio 2024.3
- **CocoaPods**: 1.16.2
- **macOS**: 15.6 (24G84)
- **Java**: OpenJDK 17.0.16

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd celeb_voice
```

2. Install dependencies
```bash
flutter pub get
```

3. iOS setup
```bash
cd ios
pod install
cd ..
```

4. Run the app
```bash
flutter run
```

### Connected Devices
- **iOS Device**: gwang hoe iphone (iOS 18.5)
- **macOS**: macOS 15.6 (darwin-arm64)
- **Web**: Chrome 138.0.7204.184

### Available Updates
- 38 packages have newer versions available
- Run `flutter pub outdated` for detailed update information

## Configuration

### Bundle ID
- **iOS**: `com.sellbuymusic.celebvoice`
- **Android**: `com.sellbuymusic.celebvoice`

### Social Login Setup

#### Google Sign-In
- Client ID: `978445308352-i3il5vk7n161tsm0556lgfc4ksak2ld8.apps.googleusercontent.com`
- URL Scheme: `com.googleusercontent.apps.978445308352-i3il5vk7n161tsm0556lgfc4ksak2ld8`

#### Kakao Login
- URL Scheme: `kakaoe1b50342b8edb35b7eb4e09d6b1fa33f`

#### Naver Login
- Consumer Key: `oohNqpOV6pom7AsYsYne`
- Consumer Secret: `VYTsuML5sV`
- URL Scheme: `com.sellbuymusic.celebvoice`

## TestFlight Deployment

### Prerequisites
- Apple Developer Account
- App Store Connect access
- Valid provisioning profiles and certificates

### Build for TestFlight

1. Run the build script:
```bash
./build_testflight.sh
```

> **Note**: The build script includes codesigning disabled for device testing. Manual codesigning is required before TestFlight deployment.

2. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

3. In Xcode:
   - Select "Any iOS Device (arm64)" as target
   - Go to Product > Archive
   - In Organizer, click "Distribute App"
   - Select "App Store Connect" and "Upload"
   - Follow the signing process
   - Upload to TestFlight

### Build Information
- **Bundle ID**: `com.sellbuymusic.celebvoice`
- **App Name**: Celeb Voice
- **Version**: 1.0.0+5
- **Build Size**: 35.8MB (iOS)
- **Last Build**: ✅ Success (68.3s)

## Project Structure

```
lib/
├── common/           # Common widgets and navigation
├── config/           # App configuration
├── constants/        # App constants
├── features/         # Feature modules
│   ├── authentication/
│   ├── celerbrity/
│   ├── generation/
│   ├── main/
│   ├── storage/
│   ├── subscription/
│   ├── user_info/
│   └── user_profile/
├── models/           # Data models
├── services/         # API services
└── utils/            # Utility functions
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is proprietary software. All rights reserved.
