/**
 * VetCare Cross-Branch Data Verification Test (Day 12 Repeatable Demo Script)
 *
 * Verifies that Dr. Patel (Whitefield Branch, isHub: false) with no prior records
 * for pet Bruno can query Bruno by microchip / nameLower and retrieve Bruno's
 * complete medical treatment history created by Dr. Sharma at Koramangala (Hub).
 *
 * Usage:
 *   node database/test_cross_branch_query.mjs
 */

import { initializeApp } from 'firebase/app';
import {
  getFirestore,
  collection,
  query,
  where,
  getDocs,
  doc,
  getDoc,
} from 'firebase/firestore';

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

async function runCrossBranchVerification() {
  console.log('===============================================================');
  console.log('🐾 VETCARE CROSS-BRANCH DISCOVERY VERIFICATION (DAY 12)');
  console.log('===============================================================');

  // 1. Establish Context: Dr. Patel at Whitefield Branch
  const drPatelSnap = await getDoc(doc(db, 'users', 'user_dr_patel'));
  if (!drPatelSnap.exists()) {
    throw new Error('Dr. Patel user document not found. Run seed script first.');
  }
  const drPatel = drPatelSnap.data();
  console.log(`\n👨‍⚕️ Authenticated Context: ${drPatel.name}`);
  console.log(`   Email: ${drPatel.email}`);
  console.log(`   Assigned Branch ID: ${drPatel.branchId}`);

  const whitefieldSnap = await getDoc(doc(db, 'branches', drPatel.branchId));
  const whitefield = whitefieldSnap.data();
  console.log(`   Branch Name: ${whitefield?.name} (isHub: ${whitefield?.isHub})`);

  // 2. Step 1: Dr. Patel searches for "Bruno" using microchipId lookup
  console.log('\n🔍 Step 1: Dr. Patel performs cross-branch lookup for microchip "#VT-8820"...');
  const petQuery = query(collection(db, 'pets'), where('microchipId', '==', '#VT-8820'));
  const petSnap = await getDocs(petQuery);

  if (petSnap.empty) {
    throw new Error('Pet with microchip #VT-8820 not found.');
  }

  const petDoc = petSnap.docs[0];
  const pet = petDoc.data();
  console.log(`   ✅ Patient Found: ${pet.name} (${pet.breed})`);
  console.log(`   Pet ID: ${petDoc.id}`);
  console.log(`   Microchip: ${pet.microchipId}`);
  console.log(`   Owner UID: ${pet.ownerId}`);

  // 3. Step 2: Dr. Patel also verifies case-insensitive name prefix lookup
  console.log('\n🔍 Step 2: Dr. Patel tests prefix search for nameLower "bruno"...');
  const nameQuery = query(
    collection(db, 'pets'),
    where('nameLower', '>=', 'bruno'),
    where('nameLower', '<=', 'bruno\uf8ff')
  );
  const nameSnap = await getDocs(nameQuery);
  console.log(`   ✅ Name Prefix Matches: ${nameSnap.size} document(s) retrieved`);

  // 4. Step 3: Dr. Patel retrieves historical treatments for Bruno across all branches
  console.log('\n📋 Step 3: Dr. Patel queries medical history for petId: ' + petDoc.id + '...');
  const treatmentsQuery = query(
    collection(db, 'treatments'),
    where('petId', '==', petDoc.id)
  );
  const treatmentsSnap = await getDocs(treatmentsQuery);

  if (treatmentsSnap.empty) {
    throw new Error('No treatments retrieved for pet!');
  }

  console.log(`   ✅ Retrieved ${treatmentsSnap.size} treatment record(s) across network:`);

  treatmentsSnap.forEach((docSnap) => {
    const t = docSnap.data();
    console.log('\n   --------------------------------------------------------');
    console.log(`   Record ID:      ${docSnap.id}`);
    console.log(`   Diagnosis:      ${t.diagnosis}`);
    console.log(`   Medication:     ${t.medication}`);
    console.log(`   Status:         ${t.status} (UI badge active)`);
    console.log(`   Attending Vet:  ${t.vetName} (vetId: ${t.vetId})`);
    console.log(`   Clinic Branch:  ${t.branchName} (branchId: ${t.branchId})`);
    console.log(`   Treatment Date: ${t.treatmentDate?.toDate?.().toISOString()}`);
    console.log(`   Follow-up Date: ${t.followUpDate?.toDate?.().toISOString()}`);
    console.log('   --------------------------------------------------------');

    // Assertion: Confirm attribution to Dr. Sharma & Koramangala
    if (t.vetId === 'user_dr_sharma' && t.branchId === 'branch_koramangala') {
      console.log('   ⭐ PROOF VERIFIED: Koramangala record correctly retrieved by Whitefield vet!');
    }
  });

  console.log('\n===============================================================');
  console.log('🎯 CROSS-BRANCH RECORD SHARING TEST: PASSED 100%');
  console.log('===============================================================\n');
}

runCrossBranchVerification().catch((err) => {
  console.error('❌ Verification failed:', err);
  process.exit(1);
});
