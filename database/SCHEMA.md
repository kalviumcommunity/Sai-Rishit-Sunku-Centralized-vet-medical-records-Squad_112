# VetCare Centralized Database Schema (Day 1)

This document specifies the exact Firestore database structure, field names, data types, and cross-branch conventions for the VetCare application. It serves as the single source of truth between the Database and Frontend/UI teams.

---

## Architecture Overview

VetCare is designed so that **a pet's medical records follow the pet across all clinic branches**. 
- Collections are organized at the **root level** to allow multi-branch indexing and queries.
- Records reference `branchId` (where the service occurred) and `vetId` (who performed it), enabling auditability while maintaining seamless cross-clinic pet history.

```mermaid
erDiagram
    USERS ||--o{ PETS : "owns (role=owner)"
    USERS ||--o{ TREATMENTS : "performs (role=vet)"
    USERS ||--o{ VACCINATIONS : "administers (role=vet)"
    USERS ||--o{ MEDICAL_DOCUMENTS : "uploads (role=vet/admin)"
    BRANCHES ||--o{ USERS : "assigned to (vets)"
    BRANCHES ||--o{ TREATMENTS : "conducted at"
    BRANCHES ||--o{ VACCINATIONS : "conducted at"
    BRANCHES ||--o{ MEDICAL_DOCUMENTS : "issued at"
    PETS ||--o{ TREATMENTS : "receives"
    PETS ||--o{ VACCINATIONS : "receives"
    PETS ||--o{ MEDICAL_DOCUMENTS : "has"

    USERS {
        string uid PK
        string name
        string email
        string role
        string branchId
        timestamp createdAt
    }

    PETS {
        string id PK
        string name
        string species
        string breed
        string gender
        timestamp dateOfBirth
        string microchipId
        string ownerId FK
        string photoUrl
        timestamp createdAt
    }

    TREATMENTS {
        string id PK
        string petId FK
        string diagnosis
        string medication
        string notes
        timestamp treatmentDate
        timestamp followUpDate
        string status
        string vetId FK
        string branchId FK
        timestamp createdAt
    }

    VACCINATIONS {
        string id PK
        string petId FK
        string vaccineName
        timestamp dateGiven
        timestamp nextDueDate
        string vetId FK
        string branchId FK
        string notes
        timestamp createdAt
    }

    BRANCHES {
        string id PK
        string name
        string address
        string phone
        boolean isHub
        timestamp createdAt
    }

    MEDICAL_DOCUMENTS {
        string id PK
        string petId FK
        string fileName
        string fileUrl
        string uploadedBy FK
        string branchId FK
        timestamp createdAt
    }
```

---

## Collections Specification

### 1. `users`
Stores profile data for pet owners, clinic veterinarians, and network administrators. Document ID is the Firebase Auth `uid`.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | `String` | No | User's full display name |
| `email` | `string` | `String` | No | Login email address |
| `role` | `string` | `String` | No | Enum: `'owner'`, `'vet'`, `'admin'` |
| `branchId` | `string` | `String?` | **Yes** | Clinic branch where the vet works. Null for `'owner'` or global `'admin'`. |
| `createdAt` | `timestamp` | `DateTime` | No | Account registration timestamp (`FieldValue.serverTimestamp()`) |

#### Auth Provider Parity (Email/Password & Google Sign-In)
- **Unified Document Structure**: The `users` collection structure is **identical** regardless of whether the user authenticated via Email/Password or Google Sign-In (`google.com`).
- **UID as Single Source of Truth**: Document ID is strictly `request.auth.uid`. There is no auxiliary collection or separate schema branch (e.g., no `google_users` or conditional fields like `isGoogleUser`).
- **Security & Privilege Escalation Protection**:
  - `read`: Users can read only their own document (`request.auth.uid == userId`).
  - `update`: While users can update their profile information, they **cannot modify their `role` field** (`request.resource.data.role == resource.data.role`). This prevents client-side privilege escalation (e.g. an owner elevating themselves to admin or vet).

---

### 2. `pets`
Stores patient profiles. Medical history follows this entity regardless of which branch is visited.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | `String` | No | Pet's name (e.g., "Milo") |
| `species` | `string` | `String` | No | Animal species (e.g., "Dog", "Cat", "Bird") |
| `breed` | `string` | `String` | No | Breed designation (e.g., "Golden Retriever") |
| `gender` | `string` | `String` | No | Enum: `'male'`, `'female'`, `'neutered_male'`, `'spayed_female'` |
| `dateOfBirth` | `timestamp` | `DateTime` | No | Used to display age (e.g., "3 Years Old") |
| `microchipId` | `string` | `String` | No | **[Updated]** Global ISO microchip / tag identifier for cross-branch lookup |
| `ownerId` | `string` | `String` | No | UID of the pet owner (`users/{uid}`) |
| `photoUrl` | `string` | `String?` | **Yes** | Cloud Storage download URL. Null falls back to default avatar icon |
| `createdAt` | `timestamp` | `DateTime` | No | Timestamp of pet registration |

---

### 3. `treatments`
Clinical consultation records, treatments, and scheduled follow-ups.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `petId` | `string` | `String` | No | Document ID of the patient pet |
| `diagnosis` | `string` | `String` | No | Chief complaint / clinical diagnosis |
| `medication` | `string` | `String` | No | Prescribed drugs, dosage, and frequency |
| `notes` | `string` | `String` | No | Attending vet's clinical observations |
| `treatmentDate` | `timestamp` | `DateTime` | No | Date and time consultation took place |
| `followUpDate` | `timestamp` | `DateTime?` | **Yes** | Scheduled next check-in (powers "Vet Follow-ups" screen). Null if none |
| `status` | `string` | `String` | No | **[Updated]** Enum: `'active'`, `'resolved'`. Controls status chips in UI |
| `vetId` | `string` | `String` | No | Attending veterinarian's user ID |
| `branchId` | `string` | `String` | No | Branch where the consultation occurred |
| `createdAt` | `timestamp` | `DateTime` | No | Record creation timestamp |

---

### 4. `vaccinations`
Immunization history and booster tracking.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `petId` | `string` | `String` | No | Document ID of the vaccinated pet |
| `vaccineName` | `string` | `String` | No | Vaccine title (e.g., "Rabies 3-Year", "DHPP Booster") |
| `dateGiven` | `timestamp` | `DateTime` | No | Date administered |
| `nextDueDate` | `timestamp` | `DateTime` | No | Expiration / booster due date (powers "Vaccines Up to Date" logic) |
| `vetId` | `string` | `String` | No | Attending veterinarian's user ID |
| `branchId` | `string` | `String` | No | Clinic branch where administered |
| `notes` | `string` | `String` | No | Batch / lot notes or adverse reaction remarks (can be empty string) |
| `createdAt` | `timestamp` | `DateTime` | No | Record creation timestamp |

---

### 5. `branches`
Physical vet clinic locations in the network.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | `String` | No | Branch title (e.g., "Central Vet Hospital - Downtown") |
| `address` | `string` | `String` | No | Street address and postal info |
| `phone` | `string` | `String` | No | Official contact number |
| `isHub` | `boolean` | `bool` | No | **[Updated]** `true` for central emergency/hub clinic, `false` for satellite clinics |
| `createdAt` | `timestamp` | `DateTime` | No | Registration timestamp |

---

### 6. `medical_documents`
Digital lab reports, radiograph (X-Ray) scans, prescriptions, and external records stored in Cloud Storage.

| Field Name | Firestore Type | Dart Type | Nullable | Description / UI Mapping |
| :--- | :--- | :--- | :--- | :--- |
| `petId` | `string` | `String` | No | Document ID of the pet |
| `fileName` | `string` | `String` | No | Display name (e.g., "Complete Blood Count Panel.pdf") |
| `fileUrl` | `string` | `String` | No | Download URL from Firebase Storage |
| `uploadedBy` | `string` | `String` | No | UID of user who uploaded the file |
| `branchId` | `string` | `String` | No | Clinic branch where document originated |
| `createdAt` | `timestamp` | `DateTime` | No | Timestamp of upload |

---

## Flagged Recommendations for Teammate Review

Before locking in the schema permanently, here are 4 high-value additions based on the current Flutter UI screens:

1. **Denormalized `vetName` & `branchName` in `treatments` & `vaccinations`**
   - *Reasoning:* The Flutter screens (`pet_profile_screen.dart`, `vaccinations_screen.dart`, `documents_screen.dart`) display human-readable strings like *"Clinic: Downtown Branch"* and *"Attending Veterinarian: Dr. John Doe"*. Without denormalization, the UI has to perform 2 extra asynchronous Firestore reads per item in a list just to show names. Storing `branchName` and `vetName` snapshots alongside `branchId` and `vetId` cuts Firestore reads and keeps list rendering snappy.
2. **`fileType` or `documentType` in `medical_documents`**
   - *Reasoning:* In `documents_screen.dart`, the UI differentiates icons between PDF reports (`Icons.picture_as_pdf`) and radiology scans (`Icons.image_outlined`). Adding an explicit field `documentType: 'lab_report' | 'xray' | 'prescription' | 'other'` or `mimeType: string` prevents brittle client-side file extension guessing.
3. **`phone` in `users` (especially for pet owners)**
   - *Reasoning:* In `vet_search_screen.dart`, the search prompt says: *"Search any registered pet by microchip ID, phone number, or tag across branches."* Having `phone` on `users` is essential for reception desk lookups when an owner arrives without remembering their microchip number.
4. **`createdAt` on `branches`**
   - *Reasoning:* Added `createdAt: timestamp` to `branches` for consistency with all other 5 collections.
