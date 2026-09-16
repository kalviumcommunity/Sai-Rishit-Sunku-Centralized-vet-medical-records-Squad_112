'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { addPet } from '@/lib/firestore';
import { useAuth } from '@/components/auth/AuthProvider';
import {
  PawPrint,
  ArrowLeft,
  Dog,
  Cat,
  Bird,
  Rabbit,
  Sparkle,
} from '@phosphor-icons/react';

export default function AddPetPage() {
  const router = useRouter();
  const { user } = useAuth();

  const [name, setName] = useState('');
  const [species, setSpecies] = useState('Dog');
  const [breed, setBreed] = useState('');
  const [age, setAge] = useState<number | ''>('');
  const [weight, setWeight] = useState<number | ''>('');
  const [submitting, setSubmitting] = useState(false);

  const speciesOptions = [
    { label: 'Dog', icon: Dog },
    { label: 'Cat', icon: Cat },
    { label: 'Bird', icon: Bird },
    { label: 'Rabbit', icon: Rabbit },
    { label: 'Other', icon: PawPrint },
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || age === '' || weight === '') {
      alert('Please fill out all required fields');
      return;
    }

    setSubmitting(true);
    try {
      const petId = await addPet({
        name,
        species,
        breed: breed.trim() || species,
        age: Number(age),
        weight: Number(weight),
        ownerId: user?.id || '',
        branchId: user?.branchId || 'main',
      });
      router.push(`/pets/${petId}`);
    } catch (err: any) {
      alert('Failed to register pet: ' + (err?.message || 'Unknown error'));
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <Link
          href="/pets"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-stone-500 hover:text-stone-900 transition-colors"
        >
          <ArrowLeft size={16} />
          Back to all pets
        </Link>
      </div>

      <div className="rounded-3xl border border-stone-200/90 bg-white p-6 sm:p-8 shadow-xs">
        <div className="flex items-center gap-3.5 pb-6 border-b border-stone-100">
          <div className="w-12 h-12 rounded-2xl bg-teal-50 border border-teal-200 flex items-center justify-center text-teal-700">
            <PawPrint size={24} weight="duotone" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-stone-900">Register New Pet</h1>
            <p className="text-xs text-stone-500 mt-0.5">
              Enter your companion's details to establish their central health record.
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-5">
          {/* Species Selector */}
          <div>
            <label className="block text-xs font-bold text-stone-700 uppercase tracking-wider mb-2">
              Species Type *
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-2.5">
              {speciesOptions.map((opt) => {
                const Icon = opt.icon;
                const isSelected = species === opt.label;
                return (
                  <button
                    key={opt.label}
                    type="button"
                    onClick={() => setSpecies(opt.label)}
                    className={`p-3 rounded-2xl border flex flex-col items-center justify-center gap-2 transition-all cursor-pointer ${
                      isSelected
                        ? 'border-teal-600 bg-teal-50/70 text-teal-900 font-bold shadow-2xs'
                        : 'border-stone-200 bg-white text-stone-600 hover:bg-stone-50'
                    }`}
                  >
                    <Icon size={24} weight={isSelected ? 'fill' : 'duotone'} />
                    <span className="text-xs">{opt.label}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Name & Breed */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1.5">
                Pet Name *
              </label>
              <input
                type="text"
                placeholder="e.g. Bella, Milo, Charlie"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1.5">
                Breed / Variety
              </label>
              <input
                type="text"
                placeholder="e.g. Golden Retriever, Persian, Siamese"
                value={breed}
                onChange={(e) => setBreed(e.target.value)}
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
              />
            </div>
          </div>

          {/* Age & Weight */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1.5">
                Age (in years) *
              </label>
              <input
                type="number"
                min="0"
                max="40"
                step="0.5"
                placeholder="e.g. 3"
                value={age}
                onChange={(e) => setAge(e.target.value === '' ? '' : Number(e.target.value))}
                required
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1.5">
                Weight (in kilograms) *
              </label>
              <input
                type="number"
                min="0.1"
                max="200"
                step="0.1"
                placeholder="e.g. 12.5"
                value={weight}
                onChange={(e) => setWeight(e.target.value === '' ? '' : Number(e.target.value))}
                required
                className="w-full px-4 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
              />
            </div>
          </div>

          {/* Submit */}
          <div className="pt-4 border-t border-stone-100 flex items-center justify-end gap-3">
            <Link
              href="/pets"
              className="px-5 py-2.5 rounded-xl text-sm font-medium text-stone-600 hover:bg-stone-100 transition-colors"
            >
              Cancel
            </Link>
            <button
              type="submit"
              disabled={submitting}
              className="px-6 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all disabled:opacity-50 cursor-pointer"
            >
              {submitting ? 'Creating Profile...' : 'Complete Registration'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
