/**
 * VetCare Centralized Database Seeder (Day 11 & Day 12)
 *
 * Populates realistic demo dataset:
 * - Branches: Koramangala (Hub) & Whitefield (Satellite)
 * - Users: Rishi (Owner), Dr. Sharma (Koramangala Vet), Dr. Patel (Whitefield Vet)
 * - Pet: Bruno (Golden Retriever, #VT-8820)
 * - Clinical Record: Treatment by Dr. Sharma at Koramangala
 * - Immunization: Rabies 3-Year by Dr. Sharma at Koramangala
 *
 * Usage:
 *   node database/seed.mjs
 */

import { initializeApp } from 'firebase/app';
import { getFirestore, doc, setDoc, Timestamp } from 'firebase/firestore';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// VetCare Firebase configuration
const firebaseConfig = {
  apiKey: 'AIzaSyCGnxijmTZCJnK9emL_ZRCaPil2VZCNVK4',
  authDomain: 'vet-care-f5161.firebaseapp.com',
  projectId: 'vet-care-f5161',
  storageBucket: 'vet-care-f5161.firebasestorage.app',
  messagingSenderId: '415999574653',
  appId: '1:415999574653:web:3185ab65bca6861b9e6714',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const seedDataPath = path.join(__dirname, 'seed_data.json');
const seedData = JSON.parse(fs.readFileSync(seedDataPath, 'utf-8'));

function parseTimestamp(val) {
  if (!val) return null;
  return Timestamp.fromDate(new Date(val));
}

async function seed() {
  console.log('🌱 Starting VetCare Firestore seeding...');

  // 1. Seed Branches
  for (const [id, data] of Object.entries(seedData.branches)) {
    console.log(` -> Seeding branch: ${id} (${data.name}) [isHub: ${data.isHub}]`);
    await setDoc(doc(db, 'branches', id), {
      ...data,
      createdAt: parseTimestamp(data.createdAt),
    });
  }

  // 2. Seed Users
  for (const [id, data] of Object.entries(seedData.users)) {
    console.log(` -> Seeding user: ${id} (${data.name} - ${data.role})`);
    await setDoc(doc(db, 'users', id), {
      ...data,
      createdAt: parseTimestamp(data.createdAt),
    });
  }

  // 3. Seed Pets
  for (const [id, data] of Object.entries(seedData.pets)) {
    console.log(` -> Seeding pet: ${id} (${data.name} - ${data.microchipId})`);
    await setDoc(doc(db, 'pets', id), {
      ...data,
      dateOfBirth: parseTimestamp(data.dateOfBirth),
      createdAt: parseTimestamp(data.createdAt),
    });
  }

  // 4. Seed Treatments
  for (const [id, data] of Object.entries(seedData.treatments)) {
    console.log(` -> Seeding treatment: ${id} (${data.diagnosis} [status: ${data.status}])`);
    await setDoc(doc(db, 'treatments', id), {
      ...data,
      treatmentDate: parseTimestamp(data.treatmentDate),
      followUpDate: parseTimestamp(data.followUpDate),
      createdAt: parseTimestamp(data.createdAt),
    });
  }

  // 5. Seed Vaccinations
  for (const [id, data] of Object.entries(seedData.vaccinations)) {
    console.log(` -> Seeding vaccination: ${id} (${data.vaccineName})`);
    await setDoc(doc(db, 'vaccinations', id), {
      ...data,
      dateGiven: parseTimestamp(data.dateGiven),
      nextDueDate: parseTimestamp(data.nextDueDate),
      createdAt: parseTimestamp(data.createdAt),
    });
  }

  // 6. Seed Medical Documents
  if (seedData.medical_documents) {
    for (const [id, data] of Object.entries(seedData.medical_documents)) {
      console.log(` -> Seeding medical document: ${id} (${data.fileName})`);
      await setDoc(doc(db, 'medical_documents', id), {
        ...data,
        createdAt: parseTimestamp(data.createdAt),
      });
    }
  }

  console.log('✅ Seeding complete! All collections populated with full schema.');
}

seed().catch((err) => {
  console.error('❌ Seeding error:', err);
  process.exit(1);
});
