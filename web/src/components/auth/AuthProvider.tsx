'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { type User as FirebaseUser } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '@/lib/firebase';
import { onAuthChange } from '@/lib/auth';
import { parseFirestoreDate } from '@/lib/utils';
import type { User } from '@/types';

interface AuthContextType {
  firebaseUser: FirebaseUser | null;
  user: User | null;
  loading: boolean;
  setUser: (user: User | null) => void;
}

const AuthContext = createContext<AuthContextType>({
  firebaseUser: null,
  user: null,
  loading: true,
  setUser: () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthChange(async (fbUser) => {
      setFirebaseUser(fbUser);
      if (fbUser) {
        try {
          const userDoc = await getDoc(doc(db, 'users', fbUser.uid));
          if (userDoc.exists()) {
            const data = userDoc.data();
            setUser({
              id: userDoc.id,
              name: (data.name as string) ?? '',
              email: (data.email as string) ?? '',
              role: (data.role as User['role']) ?? 'owner',
              branchId: (data.branchId as string) ?? null,
              createdAt: parseFirestoreDate(data.createdAt),
            });
          } else {
            setUser({
              id: fbUser.uid,
              name: fbUser.displayName ?? 'Pet Owner',
              email: fbUser.email ?? '',
              role: 'owner',
              branchId: null,
              createdAt: new Date(),
            });
          }
        } catch {
          setUser({
            id: fbUser.uid,
            name: fbUser.displayName ?? 'Pet Owner',
            email: fbUser.email ?? '',
            role: 'owner',
            branchId: null,
            createdAt: new Date(),
          });
        }
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ firebaseUser, user, loading, setUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
