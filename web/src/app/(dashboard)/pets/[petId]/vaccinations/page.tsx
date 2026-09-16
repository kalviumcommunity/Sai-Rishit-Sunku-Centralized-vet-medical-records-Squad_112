'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { getPetById } from '@/lib/firestore';
import { useVaccinations } from '@/hooks/useVaccinations';
import { useAuth } from '@/components/auth/AuthProvider';
import { Pet } from '@/types';
import { StatusBadge, StatusType } from '@/components/shared/StatusBadge';
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
  CalendarCheck,
  CheckCircle,
  Warning,
  Clock,
  X,
} from '@phosphor-icons/react';

export default function VaccinationsPage() {
  const params = useParams();
  const petId = params.petId as string;
  const { user } = useAuth();

  const [pet, setPet] = useState<Pet | null>(null);
  const [loadingPet, setLoadingPet] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);

  // New vaccination form
  const [vaccineName, setVaccineName] = useState('');
  const [dateGiven, setDateGiven] = useState(new Date().toISOString().split('T')[0]);
  const [nextDueDate, setNextDueDate] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const { vaccinations, loading: loadingVaccs, createVaccination, removeVaccination } = useVaccinations(petId);

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

  const getVaccineStatus = (dueDate: Date): { label: string; status: StatusType; icon: any } => {
    const today = new Date();
    const diffTime = dueDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return { label: 'Overdue', status: 'error', icon: Warning };
    } else if (diffDays <= 30) {
      return { label: `Due in ${diffDays}d`, status: 'warning', icon: Clock };
    }
    return { label: 'Up to date', status: 'success', icon: CheckCircle };
  };

  const handleAddVaccination = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!vaccineName || !dateGiven || !nextDueDate) {
      alert('Please fill out all required fields');
      return;
    }

    setSubmitting(true);
    try {
      await createVaccination({
        petId,
        vaccineName,
        dateGiven: new Date(dateGiven),
        nextDueDate: new Date(nextDueDate),
        notes,
        vetId: user?.id || '',
        branchId: user?.branchId || '',
      });
      setVaccineName('');
      setNotes('');
      setShowAddModal(false);
    } catch (err) {
      alert('Failed to save vaccination');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Remove this vaccination log?')) return;
    try {
      await removeVaccination(id);
    } catch (err) {
      alert('Failed to delete vaccination');
    }
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
              <Syringe size={28} weight="duotone" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-stone-900">
                {pet?.name ? `${pet.name}'s Immunization Registry` : 'Vaccinations'}
              </h1>
              <p className="text-xs text-stone-500 mt-0.5">
                Official vaccination history, booster alerts, and preventive care tracking.
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={() => setShowAddModal(true)}
            className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-xs font-semibold shadow-sm transition-all cursor-pointer"
          >
            <Plus size={16} weight="bold" />
            Log Vaccination
          </button>
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
            className="pb-3 px-3 text-sm font-semibold text-teal-700 border-b-2 border-teal-600 flex items-center gap-2"
          >
            <Syringe size={18} />
            Vaccinations
          </Link>
          <Link
            href={`/pets/${petId}/documents`}
            className="pb-3 px-3 text-sm font-medium text-stone-500 hover:text-stone-900 flex items-center gap-2 transition-colors"
          >
            <FileText size={18} />
            Documents
          </Link>
        </div>
      </div>

      {/* Vaccination List */}
      {loadingVaccs ? (
        <div className="p-8 text-center text-sm text-stone-400">Loading vaccinations...</div>
      ) : vaccinations.length === 0 ? (
        <EmptyState
          icon={<Syringe size={28} weight="duotone" />}
          title="No vaccinations recorded"
          description="Keep your pet protected by recording core and lifestyle vaccinations."
          actionLabel="Log First Vaccine"
          onAction={() => setShowAddModal(true)}
        />
      ) : (
        <div className="space-y-3">
          {vaccinations.map((vac) => {
            const status = getVaccineStatus(vac.nextDueDate);
            const StatusIcon = status.icon;

            return (
              <div
                key={vac.id}
                className="rounded-2xl border border-stone-200/90 bg-white p-5 shadow-2xs hover:shadow-xs transition-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
              >
                <div className="flex items-start gap-4">
                  <div
                    className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 border ${
                      status.status === 'success'
                        ? 'bg-emerald-50 text-emerald-600 border-emerald-200'
                        : status.status === 'warning'
                        ? 'bg-amber-50 text-amber-600 border-amber-200'
                        : 'bg-rose-50 text-rose-600 border-rose-200'
                    }`}
                  >
                    <StatusIcon size={24} weight="bold" />
                  </div>
                  <div>
                    <div className="flex items-center gap-3">
                      <h3 className="font-bold text-stone-900 text-base">
                        {vac.vaccineName}
                      </h3>
                      <StatusBadge
                        label={status.label}
                        status={status.status}
                      />
                    </div>
                    <p className="text-xs text-stone-500 mt-1">
                      Administered on <span className="font-medium text-stone-700">{formatDate(vac.dateGiven)}</span> • Next Booster due: <span className="font-medium text-stone-700">{formatDate(vac.nextDueDate)}</span>
                    </p>
                    {vac.notes && (
                      <p className="text-xs text-stone-600 bg-stone-50 p-2 rounded-lg mt-2 border border-stone-100">
                        {vac.notes}
                      </p>
                    )}
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => handleDelete(vac.id)}
                  className="p-2 text-stone-300 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-colors cursor-pointer self-end sm:self-center"
                  title="Remove entry"
                >
                  <Trash size={18} />
                </button>
              </div>
            );
          })}
        </div>
      )}

      {/* Add Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl border border-stone-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between pb-4 border-b border-stone-100">
              <h2 className="text-lg font-bold text-stone-900">Log Vaccination</h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="p-1.5 text-stone-400 hover:text-stone-700 rounded-lg"
              >
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleAddVaccination} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-stone-700 mb-1">
                  Vaccine Name *
                </label>
                <input
                  type="text"
                  placeholder="e.g. Rabies, DHPP, FVRCP, Bordetella"
                  value={vaccineName}
                  onChange={(e) => setVaccineName(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-stone-700 mb-1">
                    Date Administered *
                  </label>
                  <input
                    type="date"
                    value={dateGiven}
                    onChange={(e) => setDateGiven(e.target.value)}
                    required
                    className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-stone-700 mb-1">
                    Next Booster Due *
                  </label>
                  <input
                    type="date"
                    value={nextDueDate}
                    onChange={(e) => setNextDueDate(e.target.value)}
                    required
                    className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-stone-700 mb-1">
                  Notes / Batch / Manufacturer
                </label>
                <textarea
                  rows={2}
                  placeholder="Optional batch number, manufacturer, or adverse reaction notes"
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 resize-none"
                />
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-stone-100">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2.5 rounded-xl text-sm font-medium text-stone-600 hover:bg-stone-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all disabled:opacity-50"
                >
                  {submitting ? 'Saving...' : 'Save Record'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}