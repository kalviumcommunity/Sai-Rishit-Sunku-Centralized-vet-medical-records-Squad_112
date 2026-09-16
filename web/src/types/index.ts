// TypeScript interfaces matching Firestore data models from the Flutter app

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'owner' | 'vet' | 'admin';
  branchId?: string | null;
  createdAt: Date;
}

export interface Pet {
  id: string;
  name: string;
  species: string;
  breed: string;
  age: number;
  weight: number;
  ownerId: string;
  branchId: string;
  createdAt: Date;
}

export interface Treatment {
  id: string;
  petId: string;
  type: string;
  description: string;
  date: Date;
  followUpDate: Date;
  vetId: string;
  branchId: string;
  notes: string;
  createdAt: Date;
}

export interface Vaccination {
  id: string;
  petId: string;
  vaccineName: string;
  dateGiven: Date;
  nextDueDate: Date;
  vetId: string;
  branchId: string;
  notes: string;
  createdAt: Date;
}

export interface MedicalDocument {
  id: string;
  petId: string;
  fileName: string;
  fileUrl: string;
  uploadedBy: string;
  branchId: string;
  createdAt: Date;
}

export interface Branch {
  id: string;
  name: string;
  address: string;
  phone: string;
  isHub: boolean;
  createdAt: Date;
}

export type VaccinationStatus = 'up-to-date' | 'due-soon' | 'overdue';
