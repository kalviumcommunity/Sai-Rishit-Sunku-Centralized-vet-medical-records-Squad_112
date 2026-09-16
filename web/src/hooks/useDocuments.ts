'use client';

import { useState, useEffect } from 'react';
import { MedicalDocument } from '@/types';
import { subscribeToDocuments, addDocument, deleteDocumentRecord } from '@/lib/firestore';
import { uploadPetDocument } from '@/lib/storage';

export function useDocuments(petId: string | undefined) {
  const [documents, setDocuments] = useState<MedicalDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!petId) {
      setDocuments([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const unsubscribe = subscribeToDocuments(petId, (data) => {
      setDocuments(data);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [petId]);

  const uploadAndSave = async (file: File, uploadedBy: string, branchId: string) => {
    if (!petId) throw new Error('Pet ID is required');
    setUploading(true);
    try {
      const { downloadUrl, fileName } = await uploadPetDocument(petId, file);
      await addDocument(petId, {
        petId,
        fileName,
        fileUrl: downloadUrl,
        uploadedBy,
        branchId,
      });
    } finally {
      setUploading(false);
    }
  };

  const removeDocument = async (docId: string) => {
    if (!petId) throw new Error('Pet ID is required');
    await deleteDocumentRecord(petId, docId);
  };

  return { documents, loading, uploading, error, uploadAndSave, removeDocument };
}
