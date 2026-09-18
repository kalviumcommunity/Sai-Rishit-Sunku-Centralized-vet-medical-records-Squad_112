# VetCare — Centralized Veterinary Medical Records

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Storage%20%7C%20Auth-FFCA28?logo=firebase)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-42%2F42%20Passing%20(100%25)-success)](https://github.com)
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

### 🐾 Day 1–6: Foundations, Auth & Pet Management
- **Role-Based Authentication**: Seamless Owner and Veterinarian logins with persistent sessions (`AuthGate`) and role-based routing.
- **Home Dashboard & Hero Care Card**: Double-bezel container architecture, animated activity switcher (Food, Play, Care, Health), and reactive pet carousel with mascot illustrations.
- **Add Pet with Interactive Photo / Avatar Picker**: Pet registration with automatic microchip generation, species toggle pills, reactive state updates (`petsNotifier`), and image upload (device files or custom mascot avatars).

### 📋 Day 7–8: Unified Pet Profile & Immunization Tracker
- **Unified Pet Profile (Core Feature Screen)**:
  - White card with circular avatar, orange ring border, and microchip tag.
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

### 💊 Day 11–12: Treatment Protocol Presets & Document Storage
- **Add Treatment Form with Quick Protocol Presets (Day 11)**:
  - Header with back navigation, pet quick-info card, and `"Checked In"` status pill.
  - **Quick Protocol Presets**: One-tap chips for common clinical workflows that auto-fill Diagnosis & Medication fields:
    - `Ear Flush & Drops`
    - `Annual Booster`
    - `Allergy Flare-up`
    - `Minor Wound Flush`
    - `Dental Scale & Polish`
  - Automated attachment of `petId`, `vetId`, `branchId`, server timestamp, and immutable `status: 'active'`.
- **Medical Documents Screen & Firebase Storage (Day 12)**:
  - Bone icon header and softened security banner (`"Stored securely on VetCare Medical Cloud"`).
  - Dashed 15MB file upload dropzone supporting PDF, JPG, and PNG files.
  - Firebase Storage integration with Firestore metadata persistence (`medical_documents` collection).
  - In-app external document viewing via `url_launcher`.

---

## 🏗️ Repository Structure

```text
vetcare/
├── frontend/                     # Flutter Mobile & Web Application
│   ├── lib/
│   │   ├── models/              # Immutable Data Models (Pet, Treatment, Vaccine, Document, User)
│   │   ├── screens/             # UI Screens
│   │   │   ├── auth/            # Login & Registration Flows
│   │   │   ├── owner/           # Owner Dashboard & Add Pet Form
│   │   │   ├── pet/             # Pet Profile, Vaccinations & Documents Screens
│   │   │   └── vet/             # Vet Search, Follow-ups Worklist & Add Treatment
│   │   ├── services/            # Business Logic & Data Layer
│   │   │   ├── auth_service.dart
│   │   │   ├── medical_records_service.dart # Cross-Branch Record Aggregation & Reactive Store
│   │   │   └── storage_service.dart         # Firebase Storage & Document Metadata
│   │   ├── utils/               # AppTheme, Colors, Typography & Routing
│   │   └── widgets/             # Reusable Design Components (Care Card, Mascots, Nav Bar)
│   ├── test/                    # 42 Automated Unit and Widget Tests
│   └── pubspec.yaml
├── database/                    # Firestore & Firebase Storage Configurations
│   ├── firestore.rules          # Granular Role-Based Security Rules
│   ├── firestore.indexes.json   # Composite Indexes for Cross-Branch Queries
│   ├── storage.rules            # 15MB & File-Type Scoped Storage Rules
│   └── README.md
└── README.md                    # Root Documentation
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
   *(Or run using PowerShell helper: `.\run.ps1`)*

3. **Run the Test Suite:**
   ```powershell
   flutter test
   ```
   *Expected output: All 42 tests passing.*

---

## 🧪 Testing & Quality Assurance

The codebase includes an exhaustive test suite covering data modeling, business calculations, UI rendering, and navigation:

| Test Suite | Focus Areas | Status |
|---|---|:---:|
| `day11_day12_treatment_and_documents_test.dart` | Quick Protocol Presets, Treatment creation, Document screen UI & Storage limits | ✅ Passed |
| `day9_day10_vet_flow_test.dart` | Search tabs, client-side filters, branch badge proof, follow-up queues | ✅ Passed |
| `day7_day8_pet_profile_test.dart` | Unified Cloud Record calculations, status tags, immunization ratios | ✅ Passed |
| `day5_add_pet_test.dart` | Pet form validation, species selector pills, past-date checks | ✅ Passed |
| `day4_signup_auth_test.dart` | Auth persistence, role mapping, owner & vet profile handling | ✅ Passed |
| `main_navigation_shell_test.dart` | Limelight navigation bar tab switching and deep linking | ✅ Passed |
| `treatment_and_vaccination_model_test.dart` | Serialization round-trips, validity periods, overdue checks | ✅ Passed |
| `pet_model_test.dart` & `user_model_test.dart` | Model immutability, `copyWith`, and Firestore Timestamp conversions | ✅ Passed |

---

## 🔒 Security & Rules Architecture

- **Role Separation**: `role == 'vet'` vs `role == 'owner'` enforced at the Firestore rule level.
- **Branch Scope**: Vets operate within assigned clinic branches while retaining read access across the network for clinical continuity.
- **Storage Protection**: Uploads restricted to authenticated users, enforced 15MB size limit, and validated image/document MIME types (`image/*`, `application/pdf`).
