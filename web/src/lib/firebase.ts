import { initializeApp, getApps } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: 'AIzaSyCGnxijmTZCJnK9emL_ZRCaPil2VZCNVK4',
  authDomain: 'vet-care-f5161.firebaseapp.com',
  projectId: 'vet-care-f5161',
  storageBucket: 'vet-care-f5161.firebasestorage.app',
  messagingSenderId: '415999574653',
  appId: '1:415999574653:web:3185ab65bca6861b9e6714',
  measurementId: 'G-58DEG6DZSN',
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export default app;
