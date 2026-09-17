# VetCare Demo Data & Cross-Branch Verification Guide (Day 11 & Day 12)

This document contains the exact realistic demo dataset and the step-by-step repeatable verification protocol demonstrating that **medical records follow the pet across clinic branches instead of staying siloed at one branch**.

---

## 1. Exact Demo Dataset

### A. Branches (`branches`)
| Document ID | `name` | `address` | `phone` | `isHub` | `createdAt` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `branch_koramangala` | `VetCare Central - Koramangala` | `80 Feet Rd, 4th Block, Koramangala, Bengaluru, Karnataka 560034` | `+91 80 2553 1001` | `true` | `2026-08-01T09:00:00.000Z` |
| `branch_whitefield` | `VetCare Satellite - Whitefield` | `ITPL Main Rd, near Hope Farm Junction, Whitefield, Bengaluru, Karnataka 560066` | `+91 80 4125 3002` | `false` | `2026-08-15T09:00:00.000Z` |

### B. Users (`users`)
| Document ID | `name` | `email` | `role` | `branchId` | `createdAt` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `user_rishi_owner` | `Rishi` | `rishi@vetcare.com` | `owner` | `null` | `2026-09-01T10:00:00.000Z` |
| `user_dr_sharma` | `Dr. Sharma` | `dr.sharma@vetcare.com` | `vet` | `branch_koramangala` | `2026-08-05T08:30:00.000Z` |
| `user_dr_patel` | `Dr. Patel` | `dr.patel@vetcare.com` | `vet` | `branch_whitefield` | `2026-08-20T08:30:00.000Z` |

### C. Pets (`pets`)
| Document ID | `name` | `nameLower` | `species` | `breed` | `gender` | `dateOfBirth` | `microchipId` | `ownerId` | `photoUrl` | `weightKg` | `createdAt` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `pet_bruno_001` | `Bruno` | `bruno` | `Dog` | `Golden Retriever` | `male` | `2022-04-10T00:00:00.000Z` | `#VT-8820` | `user_rishi_owner` | `https://images.unsplash.com/...` | `31.5` | `2026-09-02T11:00:00.000Z` |

### D. Treatments (`treatments`)
| Document ID | `petId` | `diagnosis` | `medication` | `notes` | `treatmentDate` | `followUpDate` | `status` | `vetId` | `branchId` | `vetName` | `branchName` | `createdAt` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `treatment_bruno_001` | `pet_bruno_001` | `Canine Atopic Dermatitis & Ear Erythema` | `Apoquel 16mg SID x 14d, Otomax Ear Drops BID x 7d` | `Patient presented with severe pruritus, pedal licking, and bilateral pinnal erythema. Prescribed anti-inflammatory protocol.` | `2026-09-10T11:30:00.000Z` | `2026-09-24T11:30:00.000Z` | `active` | `user_dr_sharma` | `branch_koramangala` | `Dr. Sharma` | `VetCare Central - Koramangala` | `2026-09-10T11:45:00.000Z` |

### E. Vaccinations (`vaccinations`)
| Document ID | `petId` | `vaccineName` | `dateGiven` | `nextDueDate` | `vetId` | `branchId` | `notes` | `createdAt` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `vaccination_bruno_001` | `pet_bruno_001` | `Rabies 3-Year (Defensor 3)` | `2026-04-15T10:00:00.000Z` | `2029-04-15T10:00:00.000Z` | `user_dr_sharma` | `branch_koramangala` | `Administered right hind subcutaneous. Batch #RB-9941.` | `2026-04-15T10:15:00.000Z` |

---

## 2. Firebase Console Verification Checklist (Day 11)

Verify each document in the [Firebase Console](https://console.firebase.google.com/project/vet-care-f5161/firestore):

- [ ] **`branches/branch_koramangala`**:
  - `name`: string `"VetCare Central - Koramangala"`
  - `isHub`: boolean `true` (Confirm boolean type, not string)
- [ ] **`branches/branch_whitefield`**:
  - `name`: string `"VetCare Satellite - Whitefield"`
  - `isHub`: boolean `false`
- [ ] **`users/user_rishi_owner`**:
  - `role`: string `"owner"`
  - `branchId`: null (No branch assignment for pet owners)
- [ ] **`users/user_dr_sharma`**:
  - `role`: string `"vet"`
  - `branchId`: string `"branch_koramangala"`
- [ ] **`users/user_dr_patel`**:
  - `role`: string `"vet"`
  - `branchId`: string `"branch_whitefield"`
- [ ] **`pets/pet_bruno_001`**:
  - `microchipId`: string `"#VT-8820"` (Present, not empty)
  - `nameLower`: string `"bruno"` (Present for prefix search)
  - `ownerId`: string `"user_rishi_owner"`
- [ ] **`treatments/treatment_bruno_001`**:
  - `status`: string `"active"` (Valid enum: `'active' | 'resolved'`)
  - `vetId`: string `"user_dr_sharma"`
  - `branchId`: string `"branch_koramangala"`
  - `vetName`: string `"Dr. Sharma"`
  - `branchName`: string `"VetCare Central - Koramangala"`
  - `createdAt`: timestamp (Valid Firestore timestamp)

---

## 3. Repeatable Demo Test Case (Day 12)

### Test Persona
* **Doctor**: Dr. Patel
* **Assigned Branch**: Whitefield Branch (`isHub: false`)
* **Context**: Dr. Patel has never previously met owner Rishi or treated Bruno.

---

### Step-by-Step Execution:
1. **Log In as Dr. Patel (Whitefield Branch)**:
   - Navigate to `/login` or Vet Search screen.
   - User profile shows: `Name: Dr. Patel`, `Branch: VetCare Satellite - Whitefield`.

2. **Execute Cross-Branch Search**:
   - **Method A (Microchip ID)**: Type `#VT-8820` into search box.
   - **Method B (Patient Name)**: Type `Bruno` into search box.
   - Query executes:
     `db.collection('pets').where('microchipId', '==', '#VT-8820')`
     or
     `db.collection('pets').where('nameLower', '>=', 'bruno').where('nameLower', '<=', 'bruno\uf8ff')`
   - **Expected Result**: Bruno appears with Golden Retriever mascot avatar and `Owner: Rishi`.

3. **Open Bruno's Unified Medical Record**:
   - Click Bruno's card to navigate to `/pets/pet_bruno_001`.
   - Treatment query executes:
     `db.collection('treatments').where('petId', '==', 'pet_bruno_001')`

4. **Verify Cross-Branch Attribution**:
   - The UI displays:
     - **Diagnosis**: *Canine Atopic Dermatitis & Ear Erythema*
     - **Attending Vet**: *Dr. Sharma*
     - **Clinic Location**: *VetCare Central - Koramangala*
     - **Status Badge**: *Active* (with follow-up due date)
     - **Medication**: *Apoquel 16mg SID x 14d, Otomax Ear Drops BID x 7d*
   - **Core Proof**: Dr. Patel at Whitefield instantly sees the complete diagnosis and prescription issued by Dr. Sharma at the Koramangala hub.

5. **Verify Security Boundary (Tamper Prevention)**:
   - Dr. Patel attempts to edit or delete Dr. Sharma's record.
   - Security rule evaluates:
     `allow update: if (isVet() && resource.data.vetId == request.auth.uid) || isAdmin()`
   - Result: `user_dr_patel != user_dr_sharma` ➔ **DENIED (`PERMISSION_DENIED`)**.
   - Dr. Patel can only add an *addendum* or *new follow-up consultation* under their own ID.

---

## 4. Automated Verification Commands

```powershell
# 1. Run the database seeder
node database/seed.mjs

# 2. Run the cross-branch verification test
node database/test_cross_branch_query.mjs
```
