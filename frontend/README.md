# VetCare — Frontend Application

Flutter mobile and web client for **VetCare Centralized Veterinary Medical Records**.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (Material 3 with custom aesthetic design system)
- **State Management**: `Provider` & `ValueNotifier` reactive pattern
- **Backend / Cloud**:
  - `firebase_core`
  - `cloud_firestore`
  - `firebase_auth`
  - `firebase_storage`
- **Utility & UI Packages**:
  - `file_picker` (Medical documents & image uploads)
  - `url_launcher` (External PDF & prescription viewing)
  - `cupertino_icons`

---

## 📱 Running the Application

### Development Web Server
```powershell
flutter pub get
flutter run -d chrome --web-port=3000
```
Or run the root PowerShell script:
```powershell
.\run.ps1
```

### Android / iOS Device
```powershell
flutter run -d <device_id>
```

---

## 🧪 Testing

Run all 42 automated tests:
```powershell
flutter test
```

Run a specific milestone test:
```powershell
flutter test test/day11_day12_treatment_and_documents_test.dart
```

---

## 📂 Key Directory Layout

- `lib/models/`: Immutable data models with Firestore serialization (`PetModel`, `TreatmentModel`, `VaccinationModel`, `MedicalDocumentModel`, `UserModel`).
- `lib/screens/`:
  - `auth/`: Login and registration with persistent sessions.
  - `owner/`: Home dashboard and interactive Add Pet form.
  - `pet/`: Unified Pet Profile, dedicated Vaccinations tab, and Medical Documents screen.
  - `vet/`: Vet Search Pets, Today's Follow-ups worklist, and Add Treatment with Quick Protocol Presets.
- `lib/services/`:
  - `auth_service.dart`: Authentication state management.
  - `medical_records_service.dart`: Cross-branch record aggregation, reactive pet store (`petsNotifier`), and 0ms instant cached loader.
  - `storage_service.dart`: File picker and Firebase Storage integration.
- `lib/widgets/`: Aesthetic Care Card, mascot widgets, Limelight navigation bar, and custom cards.
