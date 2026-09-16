'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePets } from '@/hooks/usePets';
import { PetCard } from '@/components/dashboard/PetCard';
import { EmptyState } from '@/components/shared/EmptyState';
import { PetCardSkeleton } from '@/components/shared/LoadingSkeleton';
import { Plus, MagnifyingGlass, Funnel } from '@phosphor-icons/react';

export default function PetsPage() {
  const { pets, loading } = usePets();
  const [search, setSearch] = useState('');
  const [selectedSpecies, setSelectedSpecies] = useState('all');

  const filteredPets = pets.filter((pet) => {
    const matchesSearch =
      pet.name.toLowerCase().includes(search.toLowerCase()) ||
      pet.breed.toLowerCase().includes(search.toLowerCase()) ||
      pet.species.toLowerCase().includes(search.toLowerCase());

    const matchesSpecies =
      selectedSpecies === 'all' ||
      pet.species.toLowerCase() === selectedSpecies.toLowerCase();

    return matchesSearch && matchesSpecies;
  });

  const speciesList = ['all', 'Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
            Registered Pets
          </h1>
          <p className="mt-1 text-sm text-stone-500">
            Manage your pets, update vital metrics, and view clinical histories.
          </p>
        </div>

        <Link
          href="/pets/new"
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all"
        >
          <Plus size={16} weight="bold" />
          Add New Pet
        </Link>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
        <div className="relative flex-1">
          <MagnifyingGlass
            size={18}
            className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400"
          />
          <input
            type="text"
            placeholder="Search by pet name, breed, or species..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-stone-200 bg-white text-sm text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600 transition-all"
          />
        </div>

        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
          {speciesList.map((species) => (
            <button
              key={species}
              type="button"
              onClick={() => setSelectedSpecies(species)}
              className={`px-3 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition-all cursor-pointer ${
                selectedSpecies === species
                  ? 'bg-teal-600 text-white shadow-2xs'
                  : 'bg-white border border-stone-200 text-stone-600 hover:bg-stone-50'
              }`}
            >
              {species === 'all' ? 'All Species' : species}
            </button>
          ))}
        </div>
      </div>

      {/* Pets Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <PetCardSkeleton />
          <PetCardSkeleton />
          <PetCardSkeleton />
        </div>
      ) : filteredPets.length === 0 ? (
        <EmptyState
          title={pets.length === 0 ? 'No pets yet' : 'No matching pets found'}
          description={
            pets.length === 0
              ? 'Get started by adding your first pet to the care registry.'
              : 'Try changing your search terms or filters.'
          }
          actionLabel={pets.length === 0 ? 'Add Pet' : undefined}
          actionHref={pets.length === 0 ? '/pets/new' : undefined}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredPets.map((pet) => (
            <PetCard key={pet.id} pet={pet} />
          ))}
        </div>
      )}
    </div>
  );
}
