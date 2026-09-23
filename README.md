# VetCare — Centralized Veterinary Medical Records

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Storage%20%7C%20Auth-FFCA28?logo=firebase)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-57%2F57%20Passing%20(100%25)-success)](https://github.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()

**VetCare** is a cross-platform mobile and web application built with Flutter and Firebase designed to eliminate medical data silos across veterinary clinic networks. Instead of a pet's medical records being locked to a single clinic location, VetCare provides a **Unified Cloud Record** that travels with the pet across all branches.

---

## 🌟 Core Product Thesis: Cross-Branch Proof

When a pet is treated at a downtown clinic and later visits a suburban satellite branch:
1. **Zero Duplicate Work**: Attending vets instantly view prior treatments, active prescriptions, and immunization schedules created by other branches.
2. **Dynamic Branch Count**: Pet profiles and vet search cards display a real-time count badge proving data synchronization across metro branches (e.g., *"Unified Cloud Record — Synced across 2 metro branches"*).
3. **Immutable Clinical Trail**: Treatments auto-attach the attending vet's ID, branch ID, and server timestamps, preventing clinical history tampering.

---

## 🚀 Completed Milestones & Feature Walkthrough

### 🐾 Day 1–6: Foundations, Role-Aware Auth & Pet Management
- **Role-Aware Authentication (Email & Google Sign-In)**:
  - Supports Pet Owner and Veterinarian account creation with persistent sessions (`AuthGate`).
  - Google Sign-In with explicit role selection and clinic branch assignment (`VetCare Central - Koramangala`, `Whitefield Satellite`, `Downtown`, etc.).
  - Onboarding bottom sheet (`"Select Your Account Type"`) for first-time Google sign-ins without a pre-selected role.
  - In-app role switching (`"Switch to Veterinarian Mode"` / `"Switch to Pet Owner Mode"`) directly from the Profile screen with real-time Firestore sync.
- **Home Dashboard & Hero Care Card**: Double-bezel container architecture, animated activity switcher (Food, Play, Care, Health), and reactive pet switcher carousel.
- **Add Pet with Interactive Photo / Avatar Picker**: Pet registration with automatic microchip generation, species toggle pills, reactive state updates (`petsNotifier`), and image upload (device files or custom mascot avatars).

### 📋 Day 7–8: Unified Pet Profile & Immunization Tracker
- **Unified Pet Profile (Core Feature Screen)**:
  - Responsive agency-grade card with circular avatar clipping, halo ring border, and microchip tag.
  - Three info chips (Age, Weight, Gender) with responsive wrap layout.
  - Cross-branch status banner dynamically computing distinct clinic branch counts.
  - Medical history list with rule-based status tags: `"Resolved"` (treatments past follow-up), `"[X] Year Valid"` (vaccines based on validity duration), and `"Completed"` (wellness visits).
- **Dedicated Vaccinations Tab**:
  - Live immunization summary calculation (e.g., *"3 of 4 Ready"*).
  - Categorized timeline tracking overdue, due soon, and active booster shots.
  - Modal bottom sheet to administer and record new vaccinations across clinic branches.

### 🩺 Day 9–10: Vet Discovery & Cross-Branch Worklist
- **Vet Search Pets**:
  - Segmented control with 3 tabs (`All Pets`, `Recent`, `My Branch`).
  - Real-time client-side search by pet name, breed, microchip, or owner.
  - Distinct branch count badge on result cards proving cross-branch record existence.
  - Universal Hospital Sync adherence stat banner.
- **Vet Today's Follow-ups**:
  - Cross-branch clinical worklist tracking upcoming patient follow-ups.
  - Filter chips: `All`, `Urgent`, `Post-Surgery`, `Medication Review`.
  - Detailed origin clinic branch badge (`Branch: Westside Branch`, `Branch: Downtown Branch`) and consultation timing.
  - Interactive Owner Messaging sheet for real-time care communication.

### 💊 Day 11–12: Treatment Protocol Presets & Document Storage
- **Add Treatment Form with Quick Protocol Presets**:
  - Header with back navigation, pet quick-info card, and `"Checked In"` status pill.
  - **Quick Protocol Presets**: One-tap chips for common clinical workflows that auto-fill Diagnosis & Medication fields:
    - `Ear Flush & Drops`
    - `Annual Booster`
    - `Allergy Flare-up`
    - `Minor Wound Flush`
    - `Dental Scale & Polish`
  - Automated attachment of `petId`, `vetId`, `branchId`, server timestamp, and immutable `status: 'active'`.
- **Medical Documents Screen & Firebase Storage**:
  - Softened security banner (`"Stored securely on VetCare Medical Cloud"`).
  - Dashed 15MB file upload dropzone supporting PDF, JPG, and PNG files.
  - Firebase Storage integration with Firestore metadata persistence (`medical_documents` collection).
  - In-app external document viewing via `url_launcher`.

### 🏢 Day 13–15: Admin Hub, Analytics & Cross-Clinic Management
- **Admin Console & Network Dashboard (`AdminScreen`, `AdminService`)**:
  - 2x2 live metrics grid tracking network pets, verified treatments, active veterinarians, and branches.
  - Cosmetic replication status bar and clinic network hub tags.
  - Interactive dialog to add new clinic branches to the network.
  - Live audit log displaying cross-branch sync events, security logins, and medical record changes.
- **Touchless Lobby Check-in**:
  - Fast touchless lobby arrival pass generator creating working queue passes (`QP-#####`) with clinic branch and priority tags.

### 🎨 Agency-Grade UI & Responsive Desktop Layout
- **Max-Width Responsive Containers**:
  - Centered layout constraints (`Center(child: ConstrainedBox(...))`) across all screens preventing awkward horizontal stretching on desktop viewports (e.g. 1920×1080).
- **Pet Avatar Craft (`PetAvatarView`)**:
  - Custom circular mascot clipping (`ClipOval`) with pastel backdrop fills and ambient primary double-ring halo.
- **Limelight Navigation Bar**:
  - Role-adaptive navigation displaying owner items (Home, Records, Add Pet, Search, Profile) or clinical items (Worklist, Follow-ups, Add Treatment, Admin Hub, Profile).

### 🛡️ Privacy & Account Deletion (GDPR / Privacy Compliance)
- **Self-Service Account Deletion**:
  - Available for both Pet Owners and Veterinarians in the **Danger Zone** of the Profile screen.
  - Interactive safety confirmation dialog preventing accidental deletions.
  - Irrevocably purges the user profile from the Firestore database (`users/{uid}`) and deletes the Firebase Authentication user account.
  - Disconnects active Google Sign-In sessions and routes the user back to the login screen.

---

## 🏗️ Repository Structure

```text
vetcare/
├── frontend/                     # Flutter Mobile & Web Application
│   ├── lib/
│   │   ├── models/              # Immutable Data Models (Pet, Treatment, Vaccine, Document, User)
│   │   ├── screens/             # UI Screens
│   │   │   ├── admin/           # Multi-Clinic Admin Console & Audit Log
│   │   │   ├── auth/            # Role-Aware Login & Signup (Email & Google)
│   │   │   ├── owner/           # Owner Dashboard, Add Pet & Profile Screens
│   │   │   ├── pet/             # Pet Profile, Vaccinations & Documents Screens
│   │   │   ├── splash/          # Splash & Initial Route Resolver
│   │   │   └── vet/             # Vet Search, Follow-ups Worklist & Add Treatment
│   │   ├── services/            # Business Logic & Cloud Services
│   │   │   ├── admin_service.dart           # Admin Metrics, Branch Mgmt & Audit Logging
│   │   │   ├── auth_service.dart            # Multi-Role Auth, Google Sign-In & Account Deletion
│   │   │   ├── medical_records_service.dart # Cross-Branch EHR Aggregation & Reactive Store
│   │   │   └── storage_service.dart         # Firebase Storage & Document Metadata
│   │   ├── utils/               # AppTheme, Colors, Typography & Routing
│   │   └── widgets/             # Reusable Components (Care Card, Mascots, Limelight Nav, Avatars)
│   ├── test/                    # 57 Automated Unit, Integration & System Verification Tests
│   └── pubspec.yaml
├── database/                    # Firestore & Firebase Storage Configurations
│   ├── firestore.rules          # Granular Role-Based Security Rules
│   ├── firestore.indexes.json   # Composite Indexes for Cross-Branch Queries
│   ├── storage.rules            # 15MB & File-Type Scoped Storage Rules
│   └── README.md
└── README.md                    # Root Project Documentation
```

---

## ⚡ Quick Start

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+ recommended)
- Dart SDK (v3.3+)
- Google Chrome or an active Android/iOS emulator

### Installation & Launch

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kalviumcommunity/Sai-Rishit-Sunku-Centralized-vet-medical-records-Squad_112.git
   cd vetcare
   ```

2. **Run the Flutter application:**
   ```powershell
   cd frontend
   flutter pub get
   flutter run -d chrome
   ```
   *(Or run using the root PowerShell helper: `.\run.ps1`)*

3. **Run the Test Suite:**
   ```powershell
   flutter test
   ```
   *Expected output: All 57 tests passing.*

---

## 🧪 Testing & Quality Assurance

The codebase includes an exhaustive test suite covering data modeling, business calculations, UI rendering, security, and full multi-clinic user flows:

| Test Suite | Focus Areas | Tests | Status |
|---|---|:---:|:---:|
| `vetcare_full_system_verification_test.dart` | Complete Multi-Clinic Story, Touchless Check-in, Followups Sheet, Admin Hub | 6 | ✅ Passed |
| `day13_day14_day15_admin_and_e2e_test.dart` | Admin metrics grid, Audit Log, Form validation errors, End-to-End integration | 5 | ✅ Passed |
| `day11_day12_treatment_and_documents_test.dart` | Quick Protocol Presets, Treatment creation, Document UI & 15MB upload limits | 5 | ✅ Passed |
| `day9_day10_vet_flow_test.dart` | Search tabs, client-side filters, branch badge proof, follow-up queues | 6 | ✅ Passed |
| `day7_day8_pet_profile_test.dart` | Unified Cloud Record calculations, status tags, immunization ratios | 6 | ✅ Passed |
| `day5_add_pet_test.dart` | Pet form validation, species selector pills, past-date checks | 5 | ✅ Passed |
| `day4_signup_auth_test.dart` | Auth persistence, role mapping, Google sign-in, profile, delete account | 6 | ✅ Passed |
| `aesthetic_care_card_navigation_test.dart` | Care Card tabs (Food, Play, Care, Health), activity logging, interactive sheets | 1 | ✅ Passed |
| `main_navigation_shell_test.dart` | Limelight navigation bar tab switching, role-specific tabs & deep linking | 6 | ✅ Passed |
| `treatment_and_vaccination_model_test.dart` | Serialization round-trips, validity periods, overdue checks | 5 | ✅ Passed |
| `pet_model_test.dart` & `user_model_test.dart` | Model immutability, `copyWith`, and Firestore Timestamp conversions | 6 | ✅ Passed |
| **Total** | **Comprehensive Full System Coverage** | **57 / 57** | **✅ 100%** |

---

## 🔒 Security & Rules Architecture

- **Role Separation**: `role == 'vet'` vs `role == 'owner'` vs `role == 'admin'` enforced at the Firestore rule level.
- **Cross-Branch Audit Trail**: Treatments, vaccinations, and documents securely record authoring veterinarian and clinic branch IDs.
- **Storage Protection**: Uploads restricted to authenticated users with an enforced 15MB size limit and validated MIME types (`image/*`, `application/pdf`).
- **Data Cleanup**: Account deletion purges user profile documents from the database and revokes active authentication tokens.
