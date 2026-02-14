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

## Storage Setup & Quick Tests

- Enable **Firebase Storage** in the Firebase console and set basic security rules for MVP (allow authenticated users to read/write under `users/` and `projects/` paths). For production review rules with a security engineer.
- Ensure `firebase_storage` is added in `pubspec.yaml` (already included).

Quick test (upload a portfolio image and attach to a message):

1. Sign up as a Contractor and open `Profile` from the Dashboard.
2. Click **Upload portfolio** and select one or more images.
3. Open a project (or create one as Client) and go to the Project Workspace.
4. Click the paperclip icon, select a file and confirm that the attachment appears in the chat list.

If uploads fail, check the browser console for CORS/storage errors and confirm the `firebase_options.dart` configuration matches your Firebase project.

Commands to run locally:
```bash
flutter pub get
flutter run -d chrome
```

Optional: to generate `firebase_options.dart` and wire Firebase automatically use the FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Firestore Security Rules (MVP example)

Add these temporary rules in Firebase Console → Firestore → Rules to allow project owners and authenticated users to operate during early testing. Review and tighten before production.

```js
rules_version = '2';
service cloud.firestore {
   match /databases/{database}/documents {
      // Users: allow users to read/write their own document
      match /users/{userId} {
         allow read: if true; // public profile read
         allow write: if request.auth != null && request.auth.uid == userId;
      }

      // Projects: clients create projects; anyone can read pending projects; only authenticated users write attachments/offers
      match /projects/{projectId} {
         allow create: if request.auth != null && request.resource.data.clientId == request.auth.uid;
         allow read: if true;
         allow update: if request.auth != null && (
            request.auth.uid == resource.data.clientId || request.auth.uid == resource.data.contractorId
         );

         // Offers subcollection
         match /offers/{offerId} {
            allow create: if request.auth != null && request.resource.data.contractorId == request.auth.uid;
            allow read: if request.auth != null && (
               request.auth.uid == resource.parent.data.clientId || request.auth.uid == request.resource.data.contractorId
            );
            allow update: if request.auth != null && request.auth.uid == resource.parent.data.clientId; // client can accept
         }

         // Messages subcollection
         match /messages/{msgId} {
            allow create: if request.auth != null;
            allow read: if true;
         }
      }

      // Default deny
      match /{document=**} {
         allow read, write: if false;
      }
   }
}
```

These rules are intentionally permissive for rapid MVP testing. Before production, restrict reads, validate fields, and enforce stricter write rules.

## Mail Worker (optional)

For automatic email notifications when an offer is accepted, a background worker (Cloud Function) should process documents added to the `mail_requests` collection. The app enqueues a request with fields: `to`, `subject`, `body`, `projectId`, `offerId`, `createdAt`, `processed:false`.

Example Node.js Cloud Function (SendGrid) — deploy in Firebase Cloud Functions. Replace `SENDGRID_API_KEY` with your key.

```js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

exports.processMailRequests = functions.firestore
   .document('mail_requests/{reqId}')
   .onCreate(async (snap, ctx) => {
      const data = snap.data();
      if (!data || !data.to) return null;
      const msg = {
         to: data.to,
         from: 'noreply@mehad.app',
         subject: data.subject || 'Notification',
         text: data.body || '',
      };
      try {
         await sgMail.send(msg);
         await snap.ref.update({ processed: true, processedAt: admin.firestore.FieldValue.serverTimestamp() });
      } catch (err) {
         console.error('SendGrid error', err);
      }
      return null;
   });
```

Deploy notes:
- Create a Firebase Functions project and set `SENDGRID_API_KEY` in function environment variables.
- `npm install @sendgrid/mail firebase-admin firebase-functions` then `firebase deploy --only functions`.


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

## 🔧 Firebase Schema (MVP)
Collections used:
- `users` (documents keyed by `uid`): { email, name, role, description, rating }
- `projects` (documents): { clientId, type, location, minBudget, maxBudget, description, status, createdAt, selectedOffer, contractorId }
   - Subcollection `offers` under each project: { projectId, contractorId, price, message, status, createdAt }
   - Subcollection `messages` under each project: { text, sender, createdAt }

## ⚙️ Firebase Setup (quick)
1. Create a Firebase project and enable **Authentication (Email/Password)**.
2. Create a Web App and add config. Use `flutterfire configure` to generate `firebase_options.dart` or add config manually.
3. Enable **Cloud Firestore** in production mode (start in test mode for quick dev).
4. (Optional) Enable **Storage** if you want to store portfolio files and uploads.

## ▶️ Run (Flutter Web)
```bash
flutter pub get
flutter run -d chrome
```

Notes:
- The code uses `firebase_core`, `firebase_auth`, `cloud_firestore`, and `firebase_storage`.
- For fast MVP testing you can run without Firebase; the app contains lightweight mock fallbacks in discovery view.
