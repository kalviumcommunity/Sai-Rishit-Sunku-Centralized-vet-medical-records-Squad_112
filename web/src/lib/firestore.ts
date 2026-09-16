import {
  collection,
  collectionGroup,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  onSnapshot,
  Timestamp,
  type DocumentData,
} from 'firebase/firestore';
import { db } from './firebase';
import { parseFirestoreDate } from './utils';
import type { Pet, Treatment, Vaccination, MedicalDocument, Branch, User } from '@/types';

// --- PETS ---

export function parsePet(id: string, data: DocumentData): Pet {
  return {
    id,
    name: data.name ?? '',
    species: data.species ?? '',
    breed: data.breed ?? '',
    age: data.age ?? 0,
    weight: data.weight ?? 0,
    ownerId: data.ownerId ?? '',
    branchId: data.branchId ?? '',
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getAllPets(): Promise<Pet[]> {
  const q = query(collection(db, 'pets'), orderBy('createdAt', 'desc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parsePet(d.id, d.data()));
}

export async function getPetsByOwner(ownerId: string): Promise<Pet[]> {
  const q = query(collection(db, 'pets'), where('ownerId', '==', ownerId), orderBy('createdAt', 'desc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parsePet(d.id, d.data()));
}

export async function getPetById(petId: string): Promise<Pet | null> {
  const snap = await getDoc(doc(db, 'pets', petId));
  return snap.exists() ? parsePet(snap.id, snap.data()) : null;
}

export async function searchPetsByName(searchTerm: string): Promise<Pet[]> {
  const q = query(collection(db, 'pets'), orderBy('name'));
  const snap = await getDocs(q);
  const term = searchTerm.toLowerCase();
  return snap.docs
    .map((d) => parsePet(d.id, d.data()))
    .filter((p) => p.name.toLowerCase().includes(term) || (p.breed && p.breed.toLowerCase().includes(term)) || (p.species && p.species.toLowerCase().includes(term)));
}

export async function addPet(pet: Omit<Pet, 'id' | 'createdAt'>): Promise<string> {
  const docRef = await addDoc(collection(db, 'pets'), {
    ...pet,
    createdAt: Timestamp.now(),
  });
  return docRef.id;
}

export async function updatePet(petId: string, data: Partial<Pet>): Promise<void> {
  const updateData: any = { ...data };
  delete updateData.id;
  delete updateData.createdAt;
  await updateDoc(doc(db, 'pets', petId), updateData);
}

export async function deletePet(petId: string): Promise<void> {
  await deleteDoc(doc(db, 'pets', petId));
}

export function subscribeToOwnerPets(ownerId: string, callback: (pets: Pet[]) => void) {
  const q = query(collection(db, 'pets'), where('ownerId', '==', ownerId), orderBy('createdAt', 'desc'));
  return onSnapshot(q, (snap) => {
    callback(snap.docs.map((d) => parsePet(d.id, d.data())));
  });
}

export function subscribeToPets(callback: (pets: Pet[]) => void) {
  const q = query(collection(db, 'pets'), orderBy('createdAt', 'desc'));
  return onSnapshot(q, (snap) => {
    callback(snap.docs.map((d) => parsePet(d.id, d.data())));
  });
}

// --- TREATMENTS ---

export function parseTreatment(id: string, data: DocumentData): Treatment {
  return {
    id,
    petId: data.petId ?? '',
    type: data.type ?? '',
    description: data.description ?? '',
    date: parseFirestoreDate(data.date),
    followUpDate: parseFirestoreDate(data.followUpDate),
    vetId: data.vetId ?? '',
    branchId: data.branchId ?? '',
    notes: data.notes ?? '',
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getTreatmentsByPet(petId: string): Promise<Treatment[]> {
  const q = query(collection(db, 'pets', petId, 'treatments'), orderBy('date', 'desc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parseTreatment(d.id, d.data()));
}

export function subscribeToTreatments(petId: string, callback: (treatments: Treatment[]) => void) {
  const q = query(collection(db, 'pets', petId, 'treatments'), orderBy('date', 'desc'));
  return onSnapshot(q, (snap) => {
    callback(snap.docs.map((d) => parseTreatment(d.id, d.data())));
  });
}

export async function addTreatment(petId: string, treatment: Omit<Treatment, 'id' | 'createdAt'>): Promise<string> {
  const docRef = await addDoc(collection(db, 'pets', petId, 'treatments'), {
    ...treatment,
    date: Timestamp.fromDate(treatment.date),
    followUpDate: Timestamp.fromDate(treatment.followUpDate),
    createdAt: Timestamp.now(),
  });
  return docRef.id;
}

export async function deleteTreatment(petId: string, treatmentId: string): Promise<void> {
  await deleteDoc(doc(db, 'pets', petId, 'treatments', treatmentId));
}

export async function getAllFollowUps(): Promise<Treatment[]> {
  const q = query(collectionGroup(db, 'treatments'), orderBy('followUpDate', 'asc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parseTreatment(d.id, d.data()));
}

// --- VACCINATIONS ---

export function parseVaccination(id: string, data: DocumentData): Vaccination {
  return {
    id,
    petId: data.petId ?? '',
    vaccineName: data.vaccineName ?? '',
    dateGiven: parseFirestoreDate(data.dateGiven),
    nextDueDate: parseFirestoreDate(data.nextDueDate),
    vetId: data.vetId ?? '',
    branchId: data.branchId ?? '',
    notes: data.notes ?? '',
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getVaccinationsByPet(petId: string): Promise<Vaccination[]> {
  const q = query(collection(db, 'pets', petId, 'vaccinations'), orderBy('dateGiven', 'desc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parseVaccination(d.id, d.data()));
}

export function subscribeToVaccinations(petId: string, callback: (vaccs: Vaccination[]) => void) {
  const q = query(collection(db, 'pets', petId, 'vaccinations'), orderBy('dateGiven', 'desc'));
  return onSnapshot(q, (snap) => {
    callback(snap.docs.map((d) => parseVaccination(d.id, d.data())));
  });
}

export async function addVaccination(petId: string, vacc: Omit<Vaccination, 'id' | 'createdAt'>): Promise<string> {
  const docRef = await addDoc(collection(db, 'pets', petId, 'vaccinations'), {
    ...vacc,
    dateGiven: Timestamp.fromDate(vacc.dateGiven),
    nextDueDate: Timestamp.fromDate(vacc.nextDueDate),
    createdAt: Timestamp.now(),
  });
  return docRef.id;
}

export async function deleteVaccination(petId: string, vaccId: string): Promise<void> {
  await deleteDoc(doc(db, 'pets', petId, 'vaccinations', vaccId));
}

// --- DOCUMENTS ---

export function parseDocument(id: string, data: DocumentData): MedicalDocument {
  return {
    id,
    petId: data.petId ?? '',
    fileName: data.fileName ?? '',
    fileUrl: data.fileUrl ?? '',
    uploadedBy: data.uploadedBy ?? '',
    branchId: data.branchId ?? '',
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getDocumentsByPet(petId: string): Promise<MedicalDocument[]> {
  const q = query(collection(db, 'pets', petId, 'documents'), orderBy('createdAt', 'desc'));
  const snap = await getDocs(q);
  return snap.docs.map((d) => parseDocument(d.id, d.data()));
}

export function subscribeToDocuments(petId: string, callback: (docs: MedicalDocument[]) => void) {
  const q = query(collection(db, 'pets', petId, 'documents'), orderBy('createdAt', 'desc'));
  return onSnapshot(q, (snap) => {
    callback(snap.docs.map((d) => parseDocument(d.id, d.data())));
  });
}

export async function addDocument(petId: string, docData: Omit<MedicalDocument, 'id' | 'createdAt'>): Promise<string> {
  const docRef = await addDoc(collection(db, 'pets', petId, 'documents'), {
    ...docData,
    createdAt: Timestamp.now(),
  });
  return docRef.id;
}

export async function deleteDocumentRecord(petId: string, docId: string): Promise<void> {
  await deleteDoc(doc(db, 'pets', petId, 'documents', docId));
}

// --- BRANCHES ---

export function parseBranch(id: string, data: DocumentData): Branch {
  return {
    id,
    name: data.name ?? '',
    address: data.address ?? '',
    phone: data.phone ?? '',
    isHub: data.isHub ?? false,
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getBranches(): Promise<Branch[]> {
  const snap = await getDocs(collection(db, 'branches'));
  return snap.docs.map((d) => parseBranch(d.id, d.data()));
}

export async function addBranch(branch: Omit<Branch, 'id' | 'createdAt'>): Promise<string> {
  const docRef = await addDoc(collection(db, 'branches'), {
    ...branch,
    createdAt: Timestamp.now(),
  });
  return docRef.id;
}

export async function updateBranch(branchId: string, data: Partial<Branch>): Promise<void> {
  await updateDoc(doc(db, 'branches', branchId), data);
}

export async function deleteBranch(branchId: string): Promise<void> {
  await deleteDoc(doc(db, 'branches', branchId));
}

// --- USERS ---

export function parseUser(id: string, data: DocumentData): User {
  return {
    id,
    name: data.name ?? '',
    email: data.email ?? '',
    role: data.role ?? 'owner',
    branchId: data.branchId ?? null,
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

export async function getAllUsers(): Promise<User[]> {
  const snap = await getDocs(collection(db, 'users'));
  return snap.docs.map((d) => parseUser(d.id, d.data()));
}

export async function updateUserRole(userId: string, role: 'owner' | 'vet' | 'admin', branchId?: string | null): Promise<void> {
  await updateDoc(doc(db, 'users', userId), {
    role,
    ...(branchId !== undefined ? { branchId } : {}),
  });
}
