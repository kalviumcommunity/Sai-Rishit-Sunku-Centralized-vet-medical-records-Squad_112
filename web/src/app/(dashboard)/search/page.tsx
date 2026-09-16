'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getAllPets, getBranches } from '@/lib/firestore';
import { Pet, Branch } from '@/types';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { EmptyState } from '@/components/shared/EmptyState';
import { formatDate } from '@/lib/utils';
import {
  MagnifyingGlass,
  PawPrint,
  ArrowRight,
  Buildings,
  Stethoscope,
} from '@phosphor-icons/react';

export default function VetSearchPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [allPets, setAllPets] = useState<Pet[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const [petsData, branchesData] = await Promise.all([
          getAllPets(),
          getBranches(),
        ]);
        setAllPets(petsData);
        setBranches(branchesData);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  const getBranchName = (branchId: string) => {
    const b = branches.find((item) => item.id === branchId);
    return b ? b.name : 'Central Clinic';
  };

  const filtered = allPets.filter((pet) => {
    if (!searchTerm) return true;
    const q = searchTerm.toLowerCase();
    return (
      pet.name.toLowerCase().includes(q) ||
      pet.breed.toLowerCase().includes(q) ||
      pet.species.toLowerCase().includes(q) ||
      pet.id.toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
          Cross-Branch Patient Search
        </h1>
        <p className="mt-1 text-sm text-stone-500">
          Search and access medical records across all clinic branches and care centers.
        </p>
      </div>

      {/* Search Input */}
      <div className="relative">
        <MagnifyingGlass
          size={20}
          className="absolute left-4 top-1/2 -translate-y-1/2 text-teal-600"
        />
        <input
          type="text"
          placeholder="Search by patient name, chip ID, species, or breed across network..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-12 pr-4 py-3.5 rounded-2xl border border-stone-200 bg-white text-stone-900 text-sm shadow-xs placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 transition-all"
        />
      </div>

      {/* Network Stats Bar */}
      <div className="flex items-center gap-4 text-xs text-stone-500 bg-white p-3 rounded-xl border border-stone-200/80">
        <div className="flex items-center gap-1.5 font-medium text-stone-700">
          <Buildings size={16} className="text-teal-600" />
          <span>Network Coverage: {branches.length || 2} Branches</span>
        </div>
        <span className="text-stone-300">-</span>
        <span>{allPets.length} Central Patient Records</span>
        <span className="text-stone-300">-</span>
        <span className="text-teal-700 font-semibold">Real-time sync</span>
      </div>

      {/* Results List */}
      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">
          Loading network directory...
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={<MagnifyingGlass size={28} weight="duotone" />}
          title="No patients found"
          description={`No pet matches "${searchTerm}". Please verify the spelling or search using another keyword.`}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((pet) => (
            <div
              key={pet.id}
              className="rounded-2xl border border-stone-200/90 bg-white p-5 shadow-xs hover:border-teal-400 transition-all flex flex-col justify-between"
            >
              <div>
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl bg-teal-50 border border-teal-200 flex items-center justify-center text-teal-700 shrink-0">
                      <PawPrint size={24} weight="duotone" />
                    </div>
                    <div>
                      <h3 className="font-bold text-stone-900 text-base leading-tight">
                        {pet.name}
                      </h3>
                      <p className="text-xs text-stone-500 mt-0.5">
                        {pet.breed} - {pet.species}
                      </p>
                    </div>
                  </div>

                  <StatusBadge
                    label={pet.species}
                    status="neutral"
                    dot={false}
                  />
                </div>

                <div className="mt-4 pt-3 border-t border-stone-100 flex items-center justify-between text-xs">
                  <span className="text-stone-400">Home Branch</span>
                  <span className="font-semibold text-stone-700">
                    {getBranchName(pet.branchId)}
                  </span>
                </div>

                <div className="mt-1 flex items-center justify-between text-xs">
                  <span className="text-stone-400">Registered</span>
                  <span className="text-stone-600">
                    {formatDate(pet.createdAt)}
                  </span>
                </div>
              </div>

              <div className="mt-5 pt-3 border-t border-stone-100 flex items-center justify-between gap-2">
                <Link
                  href={`/treatments/new?petId=${pet.id}`}
                  className="p-2 rounded-xl text-xs font-semibold text-emerald-700 bg-emerald-50 hover:bg-emerald-100 transition-colors flex items-center gap-1.5"
                >
                  <Stethoscope size={16} />
                  Treat
                </Link>

                <Link
                  href={`/pets/${pet.id}`}
                  className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-semibold text-teal-700 bg-teal-50 hover:bg-teal-100 border border-teal-200/60 transition-colors"
                >
                  Open Chart
                  <ArrowRight size={14} weight="bold" />
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}