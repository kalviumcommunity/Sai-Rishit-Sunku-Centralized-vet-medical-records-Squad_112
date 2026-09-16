'use client';

import { useState, useEffect } from 'react';
import { Treatment } from '@/types';
import { subscribeToTreatments, addTreatment, deleteTreatment } from '@/lib/firestore';

export function useTreatments(petId: string | undefined) {
  const [treatments, setTreatments] = useState<Treatment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!petId) {
      setTreatments([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const unsubscribe = subscribeToTreatments(petId, (data) => {
      setTreatments(data);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [petId]);

  const createTreatment = async (data: Omit<Treatment, 'id' | 'createdAt'>) => {
    if (!petId) throw new Error('Pet ID is required');
    return await addTreatment(petId, data);
  };

  const removeTreatment = async (treatmentId: string) => {
    if (!petId) throw new Error('Pet ID is required');
    await deleteTreatment(petId, treatmentId);
  };

  return { treatments, loading, error, createTreatment, removeTreatment };
}
