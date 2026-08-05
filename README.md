# OneCitizen BD

Flutter mobile app for Bangladesh's unified government cards and services platform.

## Features

### Citizen
- Phone OTP login (Firebase Auth + Django JWT exchange)
- Digital identity with QR code
- My Cards (Farmer, Family, Student, etc.)
- Apply for cards with document upload
- Application tracker with timeline
- Eligibility checker
- Complaints filing and history
- Profile management with NID OCR auto-fill

### Government Officer
- Pending applications dashboard with search/filter
- Application review (approve, reject, request documents)
- NID verification

### Admin
- User management (suspend/delete)
- Card type management
- Officer account management
- Complaint oversight
- System logs

## Tech Stack

- **Flutter** (Android & iOS)
- **Provider** state management
- **Dio** HTTP client with JWT interceptors
- **Firebase Auth** (Phone OTP)
- **Flutter Secure Storage** for tokens
- **qr_flutter**, **image_picker**, **google_mlkit_text_recognition**

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart`. Enable **Phone Authentication** in the Firebase Console.

### 3. API base URL

Without a backend URL, the app uses a local frontend workflow store. It starts
empty and records only accounts, requests, document reviews, decisions, funds,
and notifications created through the app on that device. This lets the
citizen and admin panels exercise the full workflow without seeded demo data.

When your backend is ready, supply its URL (including `/api`) when building or
running. The app then uses the backend instead of local storage:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example/api
```

Use the corresponding staging or production URL in CI/release builds.

### 4. Run the app

```bash
flutter run
```

## Backend API

All authenticated endpoints require `Authorization: Bearer <JWT>`.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/firebase/` | POST | Exchange Firebase token for JWT |
| `/auth/me/` | GET | Current user profile |
| `/auth/profile/` | PATCH | Update profile |
| `/cards/` | GET | User's issued cards |
| `/applications/` | GET/POST | List/submit applications |
| `/eligibility/check/` | POST | Check card eligibility |
| `/complaints/` | GET/POST | Complaints |
| `/officer/applications/` | GET/PATCH | Officer review |
| `/admin/users/` | GET/PATCH/DELETE | User management |
| `/admin/card-types/` | CRUD | Card type management |

## Project Structure

```
lib/
├── config/          # API, theme, routes
├── models/          # Data models
├── services/        # API & auth services
├── providers/       # State management
├── screens/         # UI by role (citizen, officer, admin)
└── widgets/         # Reusable components
```

## License

Proprietary — OneCitizen BD
