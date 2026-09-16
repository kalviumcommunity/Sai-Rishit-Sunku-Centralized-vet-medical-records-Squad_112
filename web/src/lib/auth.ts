import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  signOut as firebaseSignOut,
  updateProfile,
  onAuthStateChanged,
  type User as FirebaseUser,
} from 'firebase/auth';
import {
  doc,
  getDoc,
  setDoc,
  Timestamp,
} from 'firebase/firestore';
import { auth, db } from './firebase';
import { parseFirestoreDate } from './utils';
import type { User } from '@/types';

const googleProvider = new GoogleAuthProvider();
googleProvider.addScope('email');
googleProvider.addScope('profile');

/** Parse a Firestore user document into our User type */
function parseUserDoc(id: string, data: Record<string, unknown>): User {
  return {
    id,
    name: (data.name as string) ?? '',
    email: (data.email as string) ?? '',
    role: (data.role as User['role']) ?? 'owner',
    branchId: (data.branchId as string) ?? null,
    createdAt: parseFirestoreDate(data.createdAt),
  };
}

/** Sign in with email and password */
export async function signInWithEmail(email: string, password: string): Promise<User> {
  const credential = await signInWithEmailAndPassword(auth, email, password);
  const user = credential.user;
  return await fetchOrCreateUserProfile(user);
}

/** Sign in with Google */
export async function signInWithGoogle(): Promise<User | null> {
  try {
    const credential = await signInWithPopup(auth, googleProvider);
    const user = credential.user;
    return await fetchOrCreateUserProfile(user);
  } catch (error: unknown) {
    const firebaseError = error as { code?: string };
    if (firebaseError.code === 'auth/popup-closed-by-user') {
      return null; // User cancelled
    }
    throw error;
  }
}

/** Register with email and password */
export async function registerWithEmail(
  email: string,
  password: string,
  name: string,
  role: User['role'],
  branchId?: string
): Promise<User> {
  const credential = await createUserWithEmailAndPassword(auth, email, password);
  const user = credential.user;

  try {
    await updateProfile(user, { displayName: name });
  } catch {
    console.warn('Could not update display name');
  }

  const effectiveBranchId = role === 'owner' ? null : branchId?.trim() || null;

  const newUser: User = {
    id: user.uid,
    name,
    email,
    role,
    branchId: effectiveBranchId,
    createdAt: new Date(),
  };

  try {
    await setDoc(doc(db, 'users', user.uid), {
      name: newUser.name,
      email: newUser.email,
      role: newUser.role,
      branchId: newUser.branchId,
      createdAt: Timestamp.fromDate(newUser.createdAt),
    });
  } catch {
    console.warn('Firestore user profile creation notice (non-blocking)');
  }

  return newUser;
}

/** Fetch user profile from Firestore, or create a default one */
async function fetchOrCreateUserProfile(firebaseUser: FirebaseUser): Promise<User> {
  try {
    const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid));
    if (userDoc.exists()) {
      return parseUserDoc(userDoc.id, userDoc.data());
    }

    // Create default profile for Google sign-in users
    const newUser: User = {
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Pet Owner',
      email: firebaseUser.email ?? '',
      role: 'owner',
      branchId: null,
      createdAt: new Date(),
    };

    await setDoc(doc(db, 'users', firebaseUser.uid), {
      name: newUser.name,
      email: newUser.email,
      role: newUser.role,
      branchId: newUser.branchId,
      createdAt: Timestamp.fromDate(newUser.createdAt),
    });

    return newUser;
  } catch {
    return {
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Pet Owner',
      email: firebaseUser.email ?? '',
      role: 'owner',
      branchId: null,
      createdAt: new Date(),
    };
  }
}

/** Sign out */
export async function signOutUser(): Promise<void> {
  await firebaseSignOut(auth);
}

/** Determine initial route based on user role */
export function getInitialRoute(role: User['role']): string {
  switch (role) {
    case 'vet': return '/search';
    case 'admin': return '/admin';
    case 'owner':
    default: return '/home';
  }
}

/** Subscribe to auth state changes */
export function onAuthChange(callback: (user: FirebaseUser | null) => void) {
  return onAuthStateChanged(auth, callback);
}
