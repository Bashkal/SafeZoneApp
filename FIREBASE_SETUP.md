# Firebase Configuration Guide for SafeZone

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: **SafeZone**
4. Enable/disable Google Analytics (your choice)
5. Click "Create project"

---

### 2. Add Android App

1. In Firebase Console, click the Android icon
2. Enter package name: `com.example.safezone` (or your package name from `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place the file in: `android/app/google-services.json`

#### Update Android Files:

**File: `android/build.gradle.kts`**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**File: `android/app/build.gradle.kts`**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}

android {
    defaultConfig {
        minSdk = 21 // Make sure this is at least 21
    }
}
```

**File: `android/app/src/main/AndroidManifest.xml`**
Add these permissions inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32"/>
```

---

### 3. Add iOS App

1. In Firebase Console, click the iOS icon
2. Enter bundle ID: `com.example.safezone` (from `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into the Runner folder in Xcode
6. Make sure "Copy items if needed" is checked

#### Update iOS Files:

**File: `ios/Runner/Info.plist`**
Add these keys:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby reports and pin report locations</string>

<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of community issues</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload images</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos</string>
```

---

### 4. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Go to **Sign-in method** tab
4. Enable **Google** sign-in provider
5. Set support email
6. Click "Save"

#### For Android (Get SHA-1):
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 from the debug keystore and add it in Firebase Console > Project Settings > Your apps > Android app > Add fingerprint

---

### 5. Set Up Firestore Database

1. Go to **Firestore Database** in Firebase Console
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location (choose nearest to your users)
5. Click "Enable"

#### Update Firestore Rules:

Go to **Rules** tab and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reports collection
    match /reports/{reportId} {
      // Anyone can read reports
      allow read: if true;
      
      // Only authenticated users can create reports
      allow create: if request.auth != null;
      
      // Only the report owner can update or delete
      allow update, delete: if request.auth != null && 
                                resource.data.userId == request.auth.uid;
    }
  }
}
```

Click "Publish"

---

### 6. Set Up Firebase Storage

1. Go to **Storage** in Firebase Console
2. Click "Get started"
3. Choose "Start in production mode"
4. Click "Done"

#### Update Storage Rules:

Go to **Rules** tab and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Reports images
    match /reports/{reportId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User profile photos
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click "Publish"

---

### 7. Test the Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Try signing in with Google

3. Create a test report

4. Check Firebase Console:
   - Authentication > Users (should show your account)
   - Firestore > Data (should show users and reports collections)
   - Storage (should show uploaded images)

---

## Common Issues & Solutions

### Issue: Build failed with "google-services.json not found"
**Solution**: Make sure the file is in `android/app/` directory, not `android/`

### Issue: Google Sign-In not working on Android
**Solution**: 
1. Make sure you added SHA-1 fingerprint in Firebase Console
2. Download the updated `google-services.json` after adding SHA-1
3. Replace the old file and rebuild

### Issue: "Permissions denied" errors in Firestore
**Solution**: Double-check your Firestore security rules match the ones above

### Issue: Camera/Location not working
**Solution**: Make sure you added all permissions to AndroidManifest.xml and Info.plist

### Issue: iOS build fails
**Solution**: 
1. Run `cd ios && pod install`
2. Open Xcode and clean build folder (Shift + Cmd + K)
3. Rebuild

---

## Verification Checklist

- [ ] Firebase project created
- [ ] Android app added with google-services.json
- [ ] iOS app added with GoogleService-Info.plist
- [ ] Google Sign-In enabled in Authentication
- [ ] Firestore database created with rules
- [ ] Storage enabled with rules
- [ ] Permissions added to Android manifest
- [ ] Permissions added to iOS Info.plist
- [ ] SHA-1 added for Android (for Google Sign-In)
- [ ] App builds successfully
- [ ] Can sign in with Google
- [ ] Can create and view reports

---

## Next Steps After Setup

1. **Test all features**: Sign in, create reports, view map, edit reports
2. **Add test data**: Create several reports to populate the feed
3. **Customize**: Update app name, package name, and icons
4. **Deploy**: Build release versions for Android/iOS

For questions or issues, refer to:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
