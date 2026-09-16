'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getAllFollowUps, getAllPets } from '@/lib/firestore';
import { Treatment, Pet } from '@/types';
import { StatusBadge, StatusType } from '@/components/shared/StatusBadge';
import { EmptyState } from '@/components/shared/EmptyState';
import { formatDate } from '@/lib/utils';
import {
  CalendarCheck,
  PawPrint,
  Clock,
  CheckCircle,
  Warning,
  ArrowRight,
} from '@phosphor-icons/react';

export default function FollowUpsPage() {
  const [followUps, setFollowUps] = useState<Treatment[]>([]);
  const [petsMap, setPetsMap] = useState<Record<string, Pet>>({});
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'upcoming' | 'overdue'>('all');

  useEffect(() => {
    async function load() {
      try {
        const [treatments, pets] = await Promise.all([
          getAllFollowUps(),
          getAllPets(),
        ]);

        const map: Record<string, Pet> = {};
        pets.forEach((p) => {
          map[p.id] = p;
        });

        const withFollowUp = treatments.filter((t) => t.followUpDate);
        setFollowUps(withFollowUp);
        setPetsMap(map);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const getFollowUpStatus = (date: Date): { label: string; status: StatusType } => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const target = new Date(date);
    target.setHours(0, 0, 0, 0);

    const diffDays = Math.ceil((target.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return { label: `Overdue by ${Math.abs(diffDays)}d`, status: 'error' };
    } else if (diffDays === 0) {
      return { label: 'Due Today', status: 'warning' };
    } else if (diffDays <= 7) {
      return { label: `Due in ${diffDays}d`, status: 'warning' };
    }
    return { label: `In ${diffDays}d`, status: 'info' };
  };

  const filtered = followUps.filter((item) => {
    if (!item.followUpDate) return false;
    const status = getFollowUpStatus(item.followUpDate);
    if (filter === 'upcoming') return status.status !== 'error';
    if (filter === 'overdue') return status.status === 'error';
    return true;
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
            Clinical Follow-ups
          </h1>
          <p className="mt-1 text-sm text-stone-500">
            Review re-examinations, stitch removals, and ongoing recovery checks.
          </p>
        </div>

        {/* Filter buttons */}
        <div className="flex items-center gap-1.5 p-1 bg-stone-100 rounded-xl border border-stone-200/70">
          <button
            type="button"
            onClick={() => setFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === 'all'
                ? 'bg-white text-stone-900 shadow-xs'
                : 'text-stone-600 hover:text-stone-900'
            }`}
          >
            All ({followUps.length})
          </button>
          <button
            type="button"
            onClick={() => setFilter('upcoming')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === 'upcoming'
                ? 'bg-white text-teal-700 shadow-xs'
                : 'text-stone-600 hover:text-stone-900'
            }`}
          >
            Upcoming
          </button>
          <button
            type="button"
            onClick={() => setFilter('overdue')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === 'overdue'
                ? 'bg-white text-rose-700 shadow-xs'
                : 'text-stone-600 hover:text-stone-900'
            }`}
          >
            Overdue
          </button>
        </div>
      </div>

      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">
          Loading follow-up schedule...
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={<CalendarCheck size={28} weight="duotone" />}
          title="No follow-ups found"
          description="All patient checkups and follow-ups are currently cleared."
        />
      ) : (
        <div className="space-y-3">
          {filtered.map((item) => {
            const pet = petsMap[item.petId];
            const status = item.followUpDate ? getFollowUpStatus(item.followUpDate) : { label: 'Scheduled', status: 'info' as StatusType };

            return (
              <div
                key={item.id}
                className="rounded-2xl border border-stone-200/90 bg-white p-5 shadow-2xs hover:shadow-xs transition-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-teal-50 border border-teal-200 text-teal-700 flex items-center justify-center shrink-0">
                    <PawPrint size={24} weight="duotone" />
                  </div>

                  <div>
                    <div className="flex items-center gap-3">
                      <h3 className="font-bold text-stone-900 text-base">
                        {pet?.name || 'Patient'}
                      </h3>
                      <StatusBadge label={status.label} status={status.status} />
                    </div>

                    <p className="text-xs font-semibold text-teal-800 mt-0.5">
                      {item.type} - {item.description}
                    </p>

                    <p className="text-xs text-stone-500 mt-1">
                      Scheduled date:{' '}
                      <span className="font-semibold text-stone-700">
                        {item.followUpDate ? formatDate(item.followUpDate) : 'N/A'}
                      </span>{' '}
                      - Original procedure: {formatDate(item.date)}
                    </p>

                    {item.notes && (
                      <p className="text-xs text-stone-600 bg-stone-50 p-2 rounded-lg mt-2 border border-stone-100 max-w-xl">
                        {item.notes}
                      </p>
                    )}
                  </div>
                </div>

                {pet && (
                  <Link
                    href={`/pets/${pet.id}`}
                    className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold text-teal-700 bg-teal-50 hover:bg-teal-100 border border-teal-200/60 transition-colors self-end sm:self-center shrink-0"
                  >
                    View Chart
                    <ArrowRight size={14} weight="bold" />
                  </Link>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}