# VetCare — Frontend Application

Flutter mobile and web client for **VetCare Centralized Veterinary Medical Records**.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/Tests-57%2F57%20Passing%20(100%25)-success)](https://github.com)

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (Material 3 with custom agency-grade aesthetic design system)
- **State Management**: `Provider` & `ValueNotifier` reactive pattern
- **Backend / Cloud**:
  - `firebase_core`
  - `cloud_firestore`
  - `firebase_auth`
  - `firebase_storage`
  - `google_sign_in` (Web & Mobile Google OAuth)
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

Run all **57 automated unit, widget, and integration tests**:
```powershell
flutter test
```

### Specific Milestone Test Suites
```powershell
# Full System Verification (Complete Multi-Clinic Story)
flutter test test/vetcare_full_system_verification_test.dart

# Admin Dashboard & End-to-End Workflows
flutter test test/day13_day14_day15_admin_and_e2e_test.dart

# Treatments & Document Uploads
flutter test test/day11_day12_treatment_and_documents_test.dart

# Vet Search Pets & Cross-Branch Followups
flutter test test/day9_day10_vet_flow_test.dart

# Pet Profile & Immunization Ratios
flutter test test/day7_day8_pet_profile_test.dart

# Authentication, Google Sign-In & Account Deletion
flutter test test/day4_signup_auth_test.dart

# Care Card Activity Logging & Category Navigation
flutter test test/aesthetic_care_card_navigation_test.dart
```

---

## 📂 Key Directory Layout

- `lib/models/`: Immutable data models with Firestore serialization (`PetModel`, `TreatmentModel`, `VaccinationModel`, `MedicalDocumentModel`, `UserModel`).
- `lib/screens/`:
  - `admin/`: `AdminScreen` with network metrics, hub tags, add-branch dialog, and system audit log.
  - `auth/`: `LoginScreen` & `SignupScreen` supporting Email/Password, role chips, Google Sign-In, and onboarding sheet.
  - `owner/`: `OwnerHomeScreen`, `AddPetScreen`, and `ProfileScreen` with role switching and account deletion danger zone.
  - `pet/`: `PetProfileScreen` (desktop-constrained, hero bento card), `VaccinationsScreen`, and `DocumentsScreen`.
  - `vet/`: `VetSearchScreen` (multi-branch pet discovery), `VetFollowupsScreen` (cross-clinic worklist & messaging), and `AddTreatmentScreen` (Quick Protocol Presets).
  - `splash/`: Initial route resolver and animated splash flow.
- `lib/services/`:
  - `admin_service.dart`: Network stats, branch creation, and audit logging.
  - `auth_service.dart`: Multi-role Google/Email authentication, role switching, and self-service account deletion.
  - `medical_records_service.dart`: Cross-branch record aggregation, reactive pet store (`petsNotifier`), and 0ms instant cached loader.
  - `storage_service.dart`: File picker and Firebase Storage integration.
- `lib/widgets/`: `AestheticCareCard`, `PetAvatarView` (circular mascot clipping with halo glow), `LimelightNavBar` (role-adaptive navigation), `CustomCard`, and `AuthGate`.
