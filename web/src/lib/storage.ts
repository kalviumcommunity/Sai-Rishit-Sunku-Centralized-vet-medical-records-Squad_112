import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';
import { storage } from './firebase';

export async function uploadPetDocument(
  petId: string,
  file: File,
  onProgress?: (progress: number) => void
): Promise<{ downloadUrl: string; fileName: string }> {
  const timestamp = Date.now();
  const sanitizedName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
  const storagePath = `pets/${petId}/documents/${timestamp}_${sanitizedName}`;
  const storageRef = ref(storage, storagePath);

  const snapshot = await uploadBytes(storageRef, file);
  const downloadUrl = await getDownloadURL(snapshot.ref);

  return {
    downloadUrl,
    fileName: file.name,
  };
}

export async function deleteStorageFile(url: string): Promise<void> {
  try {
    const fileRef = ref(storage, url);
    await deleteObject(fileRef);
  } catch (error) {
    console.warn('Failed to delete file from storage:', error);
  }
}
