# VetCare — Centralized Veterinary Medical Records

VetCare is a Flutter + Firebase mobile application where a pet's medical history follows the pet across vet clinic branches instead of staying siloed at one branch.

## Repository Architecture

```text
vetcare/
├── frontend/             # Flutter Mobile Application
│   ├── lib/              # App source code (screens, routes, theme, widgets)
│   ├── pubspec.yaml      # Flutter & Firebase dependencies
│   └── analysis_options.yaml
├── backend/              # Cloud Functions & Serverless API Services
│   └── README.md
└── database/             # Firestore Schemas, Security Rules & Indexes
    ├── firestore.rules
    ├── firestore.indexes.json
    └── README.md
```

## Running the Frontend App

```powershell
cd frontend
flutter pub get
flutter run
```
