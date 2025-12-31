# Setup Instructions

## Firebase Configuration

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your project:
```bash
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart` with your Firebase configuration
- Set up Android and iOS Firebase configuration files

3. Make sure to:
   - Enable Google Sign-In in Firebase Authentication
   - Create a Firestore database
   - Set up security rules for production

## Android Setup

1. Place `google-services.json` in `android/app/` directory
2. Update `android/build.gradle`:
   - Add Google services classpath
   - Apply Google services plugin

## iOS Setup

1. Place `GoogleService-Info.plist` in `ios/Runner/` directory
2. Update `ios/Podfile` if needed
3. Configure URL schemes for Google Sign-In

## Running the App

1. Install dependencies:
```bash
flutter pub get
```

2. Run on device/emulator:
```bash
flutter run
```

## In-App Purchase Setup

### Android
1. Create a subscription product in Google Play Console
2. Product ID: `ad_free_monthly`
3. Price: $0.55/month

### iOS
1. Create a subscription product in App Store Connect
2. Product ID: `ad_free_monthly`
3. Price: $0.55/month

## Testing

- Use Firebase Emulator Suite for local testing
- Test Google Sign-In with test accounts
- Test offline functionality by disabling network
- Test data export functionality

