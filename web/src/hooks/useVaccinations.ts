'use client';

import { useState, useEffect } from 'react';
import { Vaccination } from '@/types';
import { subscribeToVaccinations, addVaccination, deleteVaccination } from '@/lib/firestore';

export function useVaccinations(petId: string | undefined) {
  const [vaccinations, setVaccinations] = useState<Vaccination[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!petId) {
      setVaccinations([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const unsubscribe = subscribeToVaccinations(petId, (data) => {
      setVaccinations(data);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [petId]);

  const createVaccination = async (data: Omit<Vaccination, 'id' | 'createdAt'>) => {
    if (!petId) throw new Error('Pet ID is required');
    return await addVaccination(petId, data);
  };

  const removeVaccination = async (vaccId: string) => {
    if (!petId) throw new Error('Pet ID is required');
    await deleteVaccination(petId, vaccId);
  };

  return { vaccinations, loading, error, createVaccination, removeVaccination };
}
