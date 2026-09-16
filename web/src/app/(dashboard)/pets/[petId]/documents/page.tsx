'use client';

import { useEffect, useState, useRef } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { getPetById } from '@/lib/firestore';
import { useDocuments } from '@/hooks/useDocuments';
import { useAuth } from '@/components/auth/AuthProvider';
import { Pet } from '@/types';
import { EmptyState } from '@/components/shared/EmptyState';
import { formatDate } from '@/lib/utils';
import {
  PawPrint,
  Syringe,
  FileText,
  ClockCounterClockwise,
  ArrowLeft,
  UploadSimple,
  DownloadSimple,
  Trash,
  FilePdf,
  Image as ImageIcon,
  CheckCircle,
} from '@phosphor-icons/react';

export default function DocumentsPage() {
  const params = useParams();
  const petId = params.petId as string;
  const { user } = useAuth();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [pet, setPet] = useState<Pet | null>(null);
  const [loadingPet, setLoadingPet] = useState(true);

  const { documents, loading, uploading, uploadAndSave, removeDocument } = useDocuments(petId);

  useEffect(() => {
    async function load() {
      if (!petId) return;
      try {
        const data = await getPetById(petId);
        setPet(data);
      } finally {
        setLoadingPet(false);
      }
    }
    load();
  }, [petId]);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      await uploadAndSave(file, user?.name || 'Staff', user?.branchId || 'main');
      if (fileInputRef.current) fileInputRef.current.value = '';
    } catch (err: any) {
      alert('Upload failed: ' + (err?.message || 'Unknown error'));
    }
  };

  const handleDelete = async (docId: string) => {
    if (!confirm('Are you sure you want to delete this document?')) return;
    try {
      await removeDocument(docId);
    } catch (err) {
      alert('Failed to delete document');
    }
  };

  const getFileIcon = (fileName: string) => {
    const ext = fileName.split('.').pop()?.toLowerCase();
    if (ext === 'pdf') return <FilePdf size={24} weight="duotone" className="text-rose-600" />;
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].includes(ext || ''))
      return <ImageIcon size={24} weight="duotone" className="text-teal-600" />;
    return <FileText size={24} weight="duotone" className="text-stone-600" />;
  };

  return (
    <div className="space-y-8">
      <div>
        <Link
          href={`/pets/${petId}`}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-stone-500 hover:text-stone-900 transition-colors"
        >
          <ArrowLeft size={16} />
          Back to {pet?.name || 'Pet'} Profile
        </Link>
      </div>

      {/* Tabs Header */}
      <div className="rounded-3xl border border-stone-200/90 bg-white p-6 shadow-xs">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-teal-50 border border-teal-200 flex items-center justify-center text-teal-700 shrink-0">
              <FileText size={28} weight="duotone" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-stone-900">
                {pet?.name ? `${pet.name}'s Medical Documents` : 'Medical Records'}
              </h1>
              <p className="text-xs text-stone-500 mt-0.5">
                Lab reports, X-rays, bloodwork, and official clinic discharge summaries.
              </p>
            </div>
          </div>

          <div>
            <input
              type="file"
              ref={fileInputRef}
              onChange={handleFileUpload}
              className="hidden"
              accept=".pdf,.png,.jpg,.jpeg"
            />
            <button
              type="button"
              disabled={uploading}
              onClick={() => fileInputRef.current?.click()}
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-xs font-semibold shadow-sm transition-all cursor-pointer disabled:opacity-50"
            >
              <UploadSimple size={16} weight="bold" />
              {uploading ? 'Uploading...' : 'Upload Document'}
            </button>
          </div>
        </div>

        {/* Sub-nav tabs */}
        <div className="mt-6 flex items-center gap-2 border-b border-stone-100">
          <Link
            href={`/pets/${petId}`}
            className="pb-3 px-3 text-sm font-medium text-stone-500 hover:text-stone-900 flex items-center gap-2 transition-colors"
          >
            <ClockCounterClockwise size={18} />
            Medical History
          </Link>
          <Link
            href={`/pets/${petId}/vaccinations`}
            className="pb-3 px-3 text-sm font-medium text-stone-500 hover:text-stone-900 flex items-center gap-2 transition-colors"
          >
            <Syringe size={18} />
            Vaccinations
          </Link>
          <Link
            href={`/pets/${petId}/documents`}
            className="pb-3 px-3 text-sm font-semibold text-teal-700 border-b-2 border-teal-600 flex items-center gap-2"
          >
            <FileText size={18} />
            Documents
          </Link>
        </div>
      </div>

      {/* Upload Banner / Dropzone prompt */}
      <div
        onClick={() => fileInputRef.current?.click()}
        className="rounded-2xl border-2 border-dashed border-stone-200 hover:border-teal-400 bg-stone-50/50 hover:bg-teal-50/30 p-8 text-center cursor-pointer transition-colors"
      >
        <div className="w-12 h-12 rounded-xl bg-white border border-stone-200 shadow-2xs flex items-center justify-center text-teal-600 mx-auto mb-3">
          <UploadSimple size={22} />
        </div>
        <p className="text-sm font-semibold text-stone-800">
          {uploading ? 'Uploading to cloud storage...' : 'Click to select or upload a document'}
        </p>
        <p className="text-xs text-stone-400 mt-1">
          Supports PDF, JPEG, and PNG files up to 10MB
        </p>
      </div>

      {/* Documents List */}
      {loading ? (
        <div className="p-8 text-center text-sm text-stone-400">Loading documents...</div>
      ) : documents.length === 0 ? (
        <EmptyState
          icon={<FileText size={28} weight="duotone" />}
          title="No documents attached"
          description="Upload blood panels, ultrasound results, or vaccine certificates for this patient."
          actionLabel="Upload First File"
          onAction={() => fileInputRef.current?.click()}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="rounded-2xl border border-stone-200/90 bg-white p-4 shadow-2xs hover:shadow-xs transition-all flex items-center justify-between gap-4"
            >
              <div className="flex items-center gap-3.5 min-w-0">
                <div className="w-11 h-11 rounded-xl bg-stone-50 border border-stone-100 flex items-center justify-center shrink-0">
                  {getFileIcon(doc.fileName)}
                </div>
                <div className="min-w-0">
                  <h4 className="font-semibold text-stone-900 text-sm truncate" title={doc.fileName}>
                    {doc.fileName}
                  </h4>
                  <p className="text-xs text-stone-400 mt-0.5">
                    Uploaded {formatDate(doc.createdAt)}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-1.5 shrink-0">
                <a
                  href={doc.fileUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="p-2 text-stone-500 hover:text-teal-700 hover:bg-teal-50 rounded-xl transition-colors"
                  title="Open / Download"
                >
                  <DownloadSimple size={18} weight="bold" />
                </a>
                <button
                  type="button"
                  onClick={() => handleDelete(doc.id)}
                  className="p-2 text-stone-300 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-colors cursor-pointer"
                  title="Delete Document"
                >
                  <Trash size={18} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}