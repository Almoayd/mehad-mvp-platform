# Mehad Platform - LEAN MVP

Mehad is a professional platform designed to connect Clients, Contractors, and Consultants. This MVP (Minimum Viable Product) focuses on core value validation with a clean, Royal Blue brand identity and multi-language support.

## 🚀 Core Features
- **Authentication**: Sign up and Sign in with role selection (Client, Contractor, Consultant).
- **Discovery**: A centralized page to browse profiles with role-based filtering.
- **Profiles**: Minimalist profiles showcasing name, role, description, and ratings.
- **Localization**: Full support for English and Arabic (RTL/LTR) via JSON files.

## 🛠 Tech Stack
- **Frontend**: Flutter Web
- **Backend**: Firebase Authentication
- **Database**: Cloud Firestore
- **Localization**: `easy_localization`
- **Styling**: Royal Blue Theme with Google Fonts (Lato)

## 📁 Project Structure
```text
lib/
├── models/        # Data models (UserModel)
├── providers/     # State management (AuthProvider)
├── services/      # Firebase & API services
├── views/         # UI Screens (Login, Signup, Discovery)
└── widgets/       # Reusable UI components
assets/
└── translations/  # en.json, ar.json
```

## ⚙️ Setup Instructions

1. **Prerequisites**:
   - Flutter SDK installed.
   - Firebase project created.

2. **Installation**:
   ```bash
   git clone <repository-url>
   cd mehad
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Go to [Firebase Console](https://console.firebase.google.com/).
   - Add a Web App to your project.
   - Run `flutterfire configure` or manually add your `firebase_options.dart`.

4. **Run the App**:
   ```bash
   flutter run -d chrome
   ```

## 🌍 How to Add a New Language
1. Create a new JSON file in `assets/translations/` (e.g., `fr.json`).
2. Copy the keys from `en.json` and provide the translations.
3. Update `main.dart` to include the new locale:
   ```dart
   supportedLocales: const [Locale("en"), Locale("ar"), Locale("fr")],
   ```
4. Restart the app.

## ⚖️ License
This project is open-source and available under the MIT License.
