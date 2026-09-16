'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/components/auth/AuthProvider';
import { usePets } from '@/hooks/usePets';
import { addTreatment } from '@/lib/firestore';
import {
  Stethoscope,
  ArrowLeft,
  CalendarBlank,
  Buildings,
} from '@phosphor-icons/react';

function TreatmentFormContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const preselectedPetId = searchParams.get('petId') || '';
  const { user } = useAuth();
  const { pets, loading: loadingPets } = usePets();

  const [selectedPetId, setSelectedPetId] = useState(preselectedPetId);
  const [type, setType] = useState('Routine Checkup');
  const [description, setDescription] = useState('');
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [hasFollowUp, setHasFollowUp] = useState(false);
  const [followUpDate, setFollowUpDate] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (preselectedPetId) setSelectedPetId(preselectedPetId);
    else if (pets.length > 0 && !selectedPetId) setSelectedPetId(pets[0].id);
  }, [preselectedPetId, pets]);

  const treatmentTypes = [
    'Routine Checkup',
    'Diagnostic & Bloodwork',
    'Dental Cleaning',
    'Surgical Procedure',
    'Dermatology & Skin',
    'Emergency Treatment',
    'Physical Rehabilitation',
    'General Medication',
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPetId || !description || !date) {
      alert('Please fill out all required fields');
      return;
    }

    setSubmitting(true);
    try {
      await addTreatment(selectedPetId, {
        petId: selectedPetId,
        type,
        description,
        date: new Date(date),
        followUpDate: hasFollowUp && followUpDate ? new Date(followUpDate) : new Date(date),
        vetId: user?.id || '',
        branchId: user?.branchId || 'main',
        notes,
      });
      router.push(`/pets/${selectedPetId}`);
    } catch (err: any) {
      alert('Failed to log treatment: ' + (err?.message || 'Unknown error'));
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <Link
          href={selectedPetId ? `/pets/${selectedPetId}` : '/home'}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-stone-500 hover:text-stone-900 transition-colors"
        >
          <ArrowLeft size={16} />
          Back to patient chart
        </Link>
      </div>

      <div className="rounded-3xl border border-stone-200/90 bg-white p-6 sm:p-8 shadow-xs">
        <div className="flex items-center gap-3.5 pb-6 border-b border-stone-100">
          <div className="w-12 h-12 rounded-2xl bg-teal-50 border border-teal-200 flex items-center justify-center text-teal-700">
            <Stethoscope size={24} weight="duotone" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-stone-900">Add Clinical Treatment</h1>
            <p className="text-xs text-stone-500 mt-0.5">
              Record diagnoses, procedures, and upcoming care instructions.
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-5">
          {/* Pet selector */}
          <div>
            <label className="block text-xs font-semibold text-stone-700 mb-1.5">
              Patient / Pet *
            </label>
            <select
              value={selectedPetId}
              onChange={(e) => setSelectedPetId(e.target.value)}
              required
              disabled={loadingPets}
              className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 bg-white"
            >
              <option value="">-- Select Patient --</option>
              {pets.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name} ({p.species} - {p.breed})
                </option>
              ))}
            </select>
          </div>

          {/* Procedure Type */}
          <div>
            <label className="block text-xs font-semibold text-stone-700 mb-1.5">
              Clinical Type *
            </label>
            <select
              value={type}
              onChange={(e) => setType(e.target.value)}
              className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 bg-white"
            >
              {treatmentTypes.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>

          {/* Clinical summary */}
          <div>
            <label className="block text-xs font-semibold text-stone-700 mb-1.5">
              Procedure / Diagnosis Summary *
            </label>
            <input
              type="text"
              placeholder="e.g. Ear infection treatment with Otomax drops"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
            />
          </div>

          {/* Dates */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1.5">
                Treatment Date *
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                required
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-semibold text-stone-700">
                  Follow-up Date
                </label>
                <label className="flex items-center gap-1.5 text-xs text-stone-500 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={hasFollowUp}
                    onChange={(e) => setHasFollowUp(e.target.checked)}
                    className="rounded border-stone-300 text-teal-600 focus:ring-teal-500"
                  />
                  Schedule
                </label>
              </div>
              <input
                type="date"
                disabled={!hasFollowUp}
                value={followUpDate}
                onChange={(e) => setFollowUpDate(e.target.value)}
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 disabled:bg-stone-50 disabled:text-stone-300"
              />
            </div>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-xs font-semibold text-stone-700 mb-1.5">
              Doctor's Examination Notes & Prescriptions
            </label>
            <textarea
              rows={4}
              placeholder="Clinical observation, dosage instructions, or owner care guidelines..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 resize-none"
            />
          </div>

          {/* Submit */}
          <div className="pt-4 border-t border-stone-100 flex items-center justify-end gap-3">
            <Link
              href={selectedPetId ? `/pets/${selectedPetId}` : '/home'}
              className="px-5 py-2.5 rounded-xl text-sm font-medium text-stone-600 hover:bg-stone-100 transition-colors"
            >
              Cancel
            </Link>
            <button
              type="submit"
              disabled={submitting}
              className="px-6 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all disabled:opacity-50 cursor-pointer"
            >
              {submitting ? 'Recording...' : 'Save Clinical Record'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function AddTreatmentPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-stone-400">Loading form...</div>}>
      <TreatmentFormContent />
    </Suspense>
  );
}
