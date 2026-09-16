'use client';

import Link from 'next/link';
import { useAuth } from '@/components/auth/AuthProvider';
import { usePets } from '@/hooks/usePets';
import { PetCard } from '@/components/dashboard/PetCard';
import { StatsCard } from '@/components/dashboard/StatsCard';
import { EmptyState } from '@/components/shared/EmptyState';
import { PetCardSkeleton } from '@/components/shared/LoadingSkeleton';
import {
  PawPrint,
  Syringe,
  CalendarCheck,
  Plus,
  MagnifyingGlass,
  FileText,
  ShieldCheck,
} from '@phosphor-icons/react';

export default function HomePage() {
  const { user } = useAuth();
  const { pets, loading } = usePets();

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  const isVet = user?.role === 'vet';
  const isAdmin = user?.role === 'admin';

  return (
    <div className="space-y-8">
      {/* Header section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
            {getGreeting()}, {user?.name?.split(' ')[0] || 'there'}!
          </h1>
          <p className="mt-1 text-sm text-stone-500">
            {isVet
              ? 'Clinic clinical portal - manage patient treatments and follow-ups.'
              : isAdmin
              ? 'System administrative control center - managing branches and staff.'
              : 'Keep track of your beloved pets, vaccination schedules, and health records.'}
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          {isVet && (
            <Link
              href="/search"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white border border-stone-200 text-stone-700 hover:bg-stone-50 text-sm font-semibold shadow-2xs transition-colors"
            >
              <MagnifyingGlass size={16} weight="bold" />
              Search Patients
            </Link>
          )}

          <Link
            href="/pets/new"
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all hover:shadow cursor-pointer"
          >
            <Plus size={16} weight="bold" />
            {isVet ? 'Register Patient' : 'Add New Pet'}
          </Link>
        </div>
      </div>

      {/* Stats summary row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          label={isVet ? 'Active Patients' : 'My Pets'}
          value={loading ? '...' : pets.length}
          subtitle={pets.length === 1 ? '1 pet registered' : `${pets.length} pets registered`}
          icon={<PawPrint size={24} weight="duotone" />}
          iconBg="bg-teal-50"
          iconColor="text-teal-600"
        />

        <StatsCard
          label="Vaccinations"
          value="Healthy"
          subtitle="All records synced"
          icon={<Syringe size={24} weight="duotone" />}
          iconBg="bg-emerald-50"
          iconColor="text-emerald-600"
        />

        <StatsCard
          label="Follow-ups"
          value={isVet ? 'Review' : 'Active'}
          subtitle={isVet ? 'Check schedule' : 'Care schedule'}
          icon={<CalendarCheck size={24} weight="duotone" />}
          iconBg="bg-amber-50"
          iconColor="text-amber-600"
        />

        <StatsCard
          label={isVet ? 'Branch Care' : 'Account'}
          value={user?.role?.toUpperCase() || 'OWNER'}
          subtitle="Verified Access"
          icon={<ShieldCheck size={24} weight="duotone" />}
          iconBg="bg-stone-100"
          iconColor="text-stone-700"
        />
      </div>

      {/* Pets section */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-bold text-stone-900 tracking-tight">
              {isVet ? 'Patient Profiles' : 'Your Pets'}
            </h2>
            <p className="text-xs text-stone-500">
              {isVet
                ? 'Recent registered patients in the system'
                : 'Click any pet to view complete medical chart and clinical history'}
            </p>
          </div>

          {pets.length > 0 && (
            <Link
              href="/pets"
              className="text-xs font-semibold text-teal-700 hover:text-teal-800 transition-colors"
            >
              View all ({pets.length})
            </Link>
          )}
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            <PetCardSkeleton />
            <PetCardSkeleton />
            <PetCardSkeleton />
          </div>
        ) : pets.length === 0 ? (
          <EmptyState
            title="No pets added yet"
            description="Register your first furry friend to manage vaccination reminders, checkups, and medical documents."
            actionLabel="Register Pet"
            actionHref="/pets/new"
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {pets.map((pet) => (
              <PetCard key={pet.id} pet={pet} />
            ))}
          </div>
        )}
      </div>

      {/* Quick Care Action Banner */}
      <div className="rounded-2xl border border-teal-200/80 bg-gradient-to-r from-teal-500/10 via-emerald-500/5 to-transparent p-6 sm:p-8 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
        <div className="max-w-xl">
          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-teal-600 text-white mb-3">
            VetCare Network
          </div>
          <h3 className="text-xl font-bold text-stone-900">
            Multi-branch synchronized veterinary care
          </h3>
          <p className="mt-1 text-sm text-stone-600 leading-relaxed">
            All treatment records, vaccination logs, and lab results are securely synchronized across our clinic branches so your pet always gets seamless care anywhere.
          </p>
        </div>

        <div className="flex flex-wrap gap-3">
          <Link
            href="/pets/new"
            className="px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-sm shadow-sm transition-all cursor-pointer inline-flex items-center gap-2"
          >
            <Plus size={16} weight="bold" />
            Add Pet
          </Link>
        </div>
      </div>
    </div>
  );
}