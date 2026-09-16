'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { getPetById, deletePet } from '@/lib/firestore';
import { useTreatments } from '@/hooks/useTreatments';
import { useAuth } from '@/components/auth/AuthProvider';
import { Pet } from '@/types';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { EmptyState } from '@/components/shared/EmptyState';
import { formatDate } from '@/lib/utils';
import {
  PawPrint,
  Syringe,
  FileText,
  ClockCounterClockwise,
  Plus,
  Trash,
  ArrowLeft,
  CalendarBlank,
  Stethoscope,
} from '@phosphor-icons/react';

export default function PetDetailPage() {
  const params = useParams();
  const router = useRouter();
  const petId = params.petId as string;
  const { user } = useAuth();

  const [pet, setPet] = useState<Pet | null>(null);
  const [loadingPet, setLoadingPet] = useState(true);
  const [deleting, setDeleting] = useState(false);

  const { treatments, loading: loadingTreatments, removeTreatment } = useTreatments(petId);

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

  const handleDeletePet = async () => {
    if (!confirm(`Are you sure you want to remove ${pet?.name}? This action cannot be undone.`)) {
      return;
    }
    setDeleting(true);
    try {
      await deletePet(petId);
      router.push('/pets');
    } catch (err) {
      alert('Failed to delete pet.');
      setDeleting(false);
    }
  };

  const handleDeleteTreatment = async (treatmentId: string) => {
    if (!confirm('Remove this medical record?')) return;
    try {
      await removeTreatment(treatmentId);
    } catch (err) {
      alert('Failed to remove treatment record.');
    }
  };

  if (loadingPet) {
    return (
      <div className="py-12 text-center text-stone-500">
        <PawPrint size={32} className="mx-auto animate-bounce text-teal-600 mb-2" />
        <p className="text-sm">Loading pet medical record...</p>
      </div>
    );
  }

  if (!pet) {
    return (
      <EmptyState
        title="Pet not found"
        description="The requested pet profile does not exist or has been removed."
        actionLabel="Back to Pets"
        actionHref="/pets"
      />
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/pets"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-stone-500 hover:text-stone-900 transition-colors"
        >
          <ArrowLeft size={16} />
          Back to all pets
        </Link>
      </div>

      {/* Pet Header Card */}
      <div className="rounded-3xl border border-stone-200/90 bg-white p-6 sm:p-8 shadow-xs">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
          <div className="flex items-center gap-5">
            <div className="w-20 h-20 rounded-2xl bg-teal-50 border border-teal-200 flex items-center justify-center text-teal-700 shadow-2xs shrink-0">
              <PawPrint size={40} weight="duotone" />
            </div>
            <div>
              <div className="flex items-center gap-3">
                <h1 className="text-2xl sm:text-3xl font-bold text-stone-900 tracking-tight">
                  {pet.name}
                </h1>
                <StatusBadge label={pet.species} status="info" dot={false} />
              </div>
              <p className="mt-1 text-sm text-stone-500 font-medium">
                {pet.breed || 'Unknown breed'} • Registered on {formatDate(pet.createdAt)}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleDeletePet}
              disabled={deleting}
              className="p-2.5 rounded-xl text-stone-400 hover:text-rose-600 hover:bg-rose-50 border border-stone-200/80 transition-colors cursor-pointer"
              title="Delete Pet"
            >
              <Trash size={18} />
            </button>
          </div>
        </div>

        {/* Metrics Bar */}
        <div className="mt-6 pt-6 border-t border-stone-100 grid grid-cols-2 sm:grid-cols-4 gap-4 text-center">
          <div className="p-3 rounded-2xl bg-stone-50 border border-stone-100">
            <span className="text-[11px] font-semibold text-stone-400 uppercase tracking-wider block">
              Age
            </span>
            <span className="text-lg font-bold text-stone-900 mt-0.5 block">
              {pet.age} {pet.age === 1 ? 'Year' : 'Years'}
            </span>
          </div>

          <div className="p-3 rounded-2xl bg-stone-50 border border-stone-100">
            <span className="text-[11px] font-semibold text-stone-400 uppercase tracking-wider block">
              Weight
            </span>
            <span className="text-lg font-bold text-stone-900 mt-0.5 block">
              {pet.weight} kg
            </span>
          </div>

          <div className="p-3 rounded-2xl bg-stone-50 border border-stone-100">
            <span className="text-[11px] font-semibold text-stone-400 uppercase tracking-wider block">
              Species
            </span>
            <span className="text-lg font-bold text-stone-900 mt-0.5 block">
              {pet.species}
            </span>
          </div>

          <div className="p-3 rounded-2xl bg-stone-50 border border-stone-100">
            <span className="text-[11px] font-semibold text-stone-400 uppercase tracking-wider block">
              Treatments
            </span>
            <span className="text-lg font-bold text-teal-700 mt-0.5 block">
              {treatments.length} logged
            </span>
          </div>
        </div>

        {/* Sub-navigation Tabs */}
        <div className="mt-8 flex items-center gap-2 border-b border-stone-100 pb-0">
          <Link
            href={`/pets/${pet.id}`}
            className="pb-3 px-3 text-sm font-semibold text-teal-700 border-b-2 border-teal-600 flex items-center gap-2"
          >
            <ClockCounterClockwise size={18} />
            Medical History
          </Link>
          <Link
            href={`/pets/${pet.id}/vaccinations`}
            className="pb-3 px-3 text-sm font-medium text-stone-500 hover:text-stone-900 flex items-center gap-2 transition-colors"
          >
            <Syringe size={18} />
            Vaccinations
          </Link>
          <Link
            href={`/pets/${pet.id}/documents`}
            className="pb-3 px-3 text-sm font-medium text-stone-500 hover:text-stone-900 flex items-center gap-2 transition-colors"
          >
            <FileText size={18} />
            Documents
          </Link>
        </div>
      </div>

      {/* Medical History Section */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold text-stone-900 tracking-tight">
              Clinical Treatment History
            </h2>
            <p className="text-xs text-stone-500">
              Complete diagnostic history and notes logged by attending veterinarians.
            </p>
          </div>

          <Link
            href={`/treatments/new?petId=${pet.id}`}
            className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-xs font-semibold shadow-sm transition-all"
          >
            <Plus size={16} weight="bold" />
            Add Treatment Record
          </Link>
        </div>

        {loadingTreatments ? (
          <div className="p-8 text-center text-sm text-stone-400">
            Loading clinical entries...
          </div>
        ) : treatments.length === 0 ? (
          <EmptyState
            icon={<Stethoscope size={28} weight="duotone" />}
            title="No medical history yet"
            description="No clinical treatments or checkups have been logged for this pet."
            actionLabel="Add First Treatment"
            actionHref={`/treatments/new?petId=${pet.id}`}
          />
        ) : (
          <div className="space-y-3">
            {treatments.map((record) => (
              <div
                key={record.id}
                className="rounded-2xl border border-stone-200/90 bg-white p-5 shadow-2xs hover:shadow-xs transition-shadow"
              >
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-2">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2.5">
                      <span className="font-bold text-stone-900 text-base">
                        {record.type}
                      </span>
                      <StatusBadge
                        label={formatDate(record.date)}
                        status="neutral"
                        dot={false}
                      />
                    </div>
                    <p className="text-sm text-stone-600 leading-relaxed">
                      {record.description}
                    </p>
                  </div>

                  <div className="flex items-center gap-2 self-start">
                    <button
                      onClick={() => handleDeleteTreatment(record.id)}
                      className="p-1.5 text-stone-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors cursor-pointer"
                      title="Delete record"
                    >
                      <Trash size={16} />
                    </button>
                  </div>
                </div>

                {record.notes && (
                  <div className="mt-3.5 p-3 rounded-xl bg-stone-50 border border-stone-100 text-xs text-stone-600">
                    <span className="font-semibold text-stone-700 block mb-0.5">
                      Clinical Notes:
                    </span>
                    {record.notes}
                  </div>
                )}

                {record.followUpDate && (
                  <div className="mt-3 flex items-center gap-2 text-xs font-medium text-amber-700 bg-amber-50/80 px-3 py-1.5 rounded-lg border border-amber-200/50 w-fit">
                    <CalendarBlank size={15} />
                    Follow-up due: {formatDate(record.followUpDate)}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}