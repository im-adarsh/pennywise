# Daily Expense Book

A Flutter mobile application for tracking daily expenses, managing bill reminders, and monitoring household spending.

## Features

- **Expense Tracking**: Quickly log daily expenses with category, amount, description, and date
- **Bill Reminders**: Set reminders for recurring bills with due dates
- **Household Member Management**: Add and manage household members to track individual spending
- **Monthly Summaries**: View spending breakdown by category and member
- **Offline Functionality**: All features work without internet connection
- **Data Export**: Export expense data in CSV or PDF format
- **Google Login**: Secure authentication using Google Sign-In
- **Firebase Backend**: Cloud storage and synchronization
- **Ad-Free Subscription**: Subscribe for $0.55/month to remove ads

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project set up
- Google Sign-In credentials configured

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pennywise
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. Configure Google Sign-In:
   - Enable Google Sign-In in Firebase Authentication
   - Configure OAuth consent screen in Google Cloud Console
   - Add SHA-1 fingerprint for Android (if needed)

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
│   ├── expense.dart
│   ├── bill.dart
│   └── household_member.dart
├── services/                # Business logic and API services
│   ├── auth_service.dart
│   ├── expense_service.dart
│   ├── bill_service.dart
│   ├── member_service.dart
│   ├── subscription_service.dart
│   ├── local_storage_service.dart
│   └── export_service.dart
├── screens/                 # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── expenses/
│   │   ├── add_expense_screen.dart
│   │   └── expense_list_screen.dart
│   ├── bills/
│   │   ├── bills_screen.dart
│   │   └── add_bill_screen.dart
│   ├── members/
│   │   ├── members_screen.dart
│   │   └── add_member_screen.dart
│   └── summary/
│       └── monthly_summary_screen.dart
├── widgets/                 # Reusable widgets
│   └── category_icon.dart
└── theme/                   # App theming
    └── app_theme.dart
```

## Configuration

### Firebase Setup

1. Create a Firebase project
2. Enable Authentication with Google Sign-In
3. Create Firestore database
4. Set up security rules (for production)

### In-App Purchases

Configure the subscription product in:
- Google Play Console (Android)
- App Store Connect (iOS)

Product ID: `ad_free_monthly`
Price: $0.55/month

## Style Guidelines

- **Primary Color**: Forest green (#388E3C)
- **Background Color**: Light green (#E8F5E9)
- **Accent Color**: Teal (#26A69A)
- **Font**: PT Sans (via Google Fonts)
- **Design**: Simple, intuitive layout optimized for one-hand use

## License

This project is licensed under the MIT License.

