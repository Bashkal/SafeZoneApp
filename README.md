# SafeZone - Community Watch App

A Flutter mobile application that allows users to report and track community issues in their neighborhood. Users can report problems like road hazards, broken streetlights, graffiti, lost pets, and more with photos and location information.

## Features

### 🔐 Authentication
- Google Sign-In integration
- User profile management
- Profile photo upload

### 📱 Core Features
- **Feed Page**: Browse all community reports with filtering options (All, Pending, In Progress, Resolved)
- **Map View**: Interactive map showing all reported issues with markers colored by status
- **Report Submission**: 
  - Add title, description, and category
  - Upload multiple photos from camera or gallery
  - Pin exact location on map with address
- **My Reports**: View, edit, and delete your own reports
- **Profile & Settings**: 
  - Update profile photo
  - Toggle dark/light theme
  - View report statistics
  - Sign out

### 🎨 UI Features
- Material Design 3
- Dark mode support
- Responsive design
- Smooth animations
- Image caching

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase account
- Android Studio / Xcode for mobile development

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "SafeZone"

2. **Enable Authentication**
   - Go to Authentication > Sign-in method
   - Enable Google Sign-In

3. **Create Firestore Database**
   - Go to Firestore Database and create database

4. **Enable Firebase Storage**
   - Go to Storage and enable it

5. **Add Firebase to Your App**
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and add to `ios/Runner/`

### Installation Steps

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase** (follow setup above)

3. **Run the app**
   ```bash
   flutter run
   ```

## Permissions Required

### Android
- Internet access
- Location (GPS)
- Camera
- Photo library

### iOS
- Location when in use
- Camera usage
- Photo library access

## Tech Stack

- Flutter & Dart
- Firebase (Auth, Firestore, Storage)
- Provider (State Management)
- flutter_map with OpenStreetMap
- Image Picker & Cached Network Image

## Report Categories

Road Hazard • Streetlight • Graffiti • Lost Pet • Found Pet • Parking • Noise • Waste • Other

Built with ❤️ using Flutter
