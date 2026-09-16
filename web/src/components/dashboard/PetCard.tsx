'use client';

import Link from 'next/link';
import { Pet } from '@/types';
import {
  Dog,
  Cat,
  Bird,
  Rabbit,
  PawPrint,
  Syringe,
  FileText,
  ClockCounterClockwise,
  ArrowRight,
  Plus,
} from '@phosphor-icons/react';
import { useAuth } from '@/components/auth/AuthProvider';

interface PetCardProps {
  pet: Pet;
}

export function PetCard({ pet }: PetCardProps) {
  const { user } = useAuth();
  const isVetOrAdmin = user?.role === 'vet' || user?.role === 'admin';

  const getSpeciesIcon = (species: string) => {
    const s = species.toLowerCase();
    if (s.includes('dog') || s.includes('canine') || s.includes('puppy'))
      return <Dog size={28} weight="duotone" className="text-teal-700" />;
    if (s.includes('cat') || s.includes('feline') || s.includes('kitten'))
      return <Cat size={28} weight="duotone" className="text-amber-700" />;
    if (s.includes('bird') || s.includes('parrot'))
      return <Bird size={28} weight="duotone" className="text-sky-700" />;
    if (s.includes('rabbit') || s.includes('bunny'))
      return <Rabbit size={28} weight="duotone" className="text-purple-700" />;
    return <PawPrint size={28} weight="duotone" className="text-teal-700" />;
  };

  const getSpeciesBg = (species: string) => {
    const s = species.toLowerCase();
    if (s.includes('dog') || s.includes('canine')) return 'bg-teal-50 border-teal-200/80';
    if (s.includes('cat') || s.includes('feline')) return 'bg-amber-50 border-amber-200/80';
    if (s.includes('bird')) return 'bg-sky-50 border-sky-200/80';
    if (s.includes('rabbit')) return 'bg-purple-50 border-purple-200/80';
    return 'bg-teal-50 border-teal-200/80';
  };

  return (
    <div className="group rounded-2xl border border-stone-200/90 bg-white p-5 shadow-xs hover:shadow-md hover:border-teal-300 transition-all duration-200 flex flex-col justify-between">
      <div>
        {/* Header */}
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3.5">
            <div
              className={`w-14 h-14 rounded-2xl border flex items-center justify-center shadow-xs transition-transform group-hover:scale-105 ${getSpeciesBg(
                pet.species
              )}`}
            >
              {getSpeciesIcon(pet.species)}
            </div>
            <div>
              <h3 className="font-bold text-stone-900 text-lg group-hover:text-teal-700 transition-colors leading-tight">
                {pet.name}
              </h3>
              <p className="text-xs font-medium text-stone-500 mt-0.5">
                {pet.breed || pet.species}
              </p>
            </div>
          </div>

          <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-stone-100 text-stone-600 border border-stone-200/60">
            {pet.species}
          </span>
        </div>

        {/* Vital stats */}
        <div className="mt-4 pt-3.5 border-t border-stone-100 grid grid-cols-2 gap-2 text-xs">
          <div className="p-2.5 rounded-xl bg-stone-50 border border-stone-100">
            <span className="text-stone-400 block text-[10px] font-medium uppercase tracking-wider">
              Age
            </span>
            <span className="font-semibold text-stone-800 mt-0.5 block">
              {pet.age} {pet.age === 1 ? 'Year' : 'Years'}
            </span>
          </div>
          <div className="p-2.5 rounded-xl bg-stone-50 border border-stone-100">
            <span className="text-stone-400 block text-[10px] font-medium uppercase tracking-wider">
              Weight
            </span>
            <span className="font-semibold text-stone-800 mt-0.5 block">
              {pet.weight} kg
            </span>
          </div>
        </div>
      </div>

      {/* Action links */}
      <div className="mt-5 pt-3 border-t border-stone-100 flex items-center justify-between gap-2">
        <div className="flex items-center gap-1.5">
          <Link
            href={`/pets/${pet.id}/vaccinations`}
            className="p-2 rounded-lg text-stone-500 hover:text-teal-700 hover:bg-teal-50 transition-colors"
            title="Vaccinations"
          >
            <Syringe size={18} />
          </Link>
          <Link
            href={`/pets/${pet.id}/documents`}
            className="p-2 rounded-lg text-stone-500 hover:text-teal-700 hover:bg-teal-50 transition-colors"
            title="Documents"
          >
            <FileText size={18} />
          </Link>
          {isVetOrAdmin && (
            <Link
              href={`/treatments/new?petId=${pet.id}`}
              className="p-2 rounded-lg text-stone-500 hover:text-emerald-700 hover:bg-emerald-50 transition-colors"
              title="Add Treatment"
            >
              <Plus size={18} weight="bold" />
            </Link>
          )}
        </div>

        <Link
          href={`/pets/${pet.id}`}
          className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-semibold text-teal-700 bg-teal-50 hover:bg-teal-100 border border-teal-200/60 transition-colors"
        >
          View Chart
          <ArrowRight size={14} weight="bold" />
        </Link>
      </div>
    </div>
  );
}
