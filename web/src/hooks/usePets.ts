'use client';

import { useState, useEffect } from 'react';
import { Pet } from '@/types';
import { useAuth } from '@/components/auth/AuthProvider';
import { subscribeToOwnerPets, subscribeToPets, addPet, updatePet, deletePet } from '@/lib/firestore';

export function usePets() {
  const { user } = useAuth();
  const [pets, setPets] = useState<Pet[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) {
      setPets([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    let unsubscribe: () => void;

    try {
      if (user.role === 'owner') {
        unsubscribe = subscribeToOwnerPets(user.id, (data) => {
          setPets(data);
          setLoading(false);
        });
      } else {
        unsubscribe = subscribeToPets((data) => {
          setPets(data);
          setLoading(false);
        });
      }
    } catch (err: any) {
      setError(err?.message ?? 'Failed to load pets');
      setLoading(false);
    }

    return () => {
      if (unsubscribe) unsubscribe();
    };
  }, [user]);

  const createPet = async (petData: Omit<Pet, 'id' | 'createdAt'>) => {
    return await addPet(petData);
  };

  const editPet = async (petId: string, petData: Partial<Pet>) => {
    await updatePet(petId, petData);
  };

  const removePet = async (petId: string) => {
    await deletePet(petId);
  };

  return { pets, loading, error, addPet: createPet, editPet, removePet };
}
