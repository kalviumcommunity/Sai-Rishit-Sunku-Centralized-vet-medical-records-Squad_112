'use client';

import { useState } from 'react';
import Link from 'next/link';
import { PawPrint, List, X, Plus } from '@phosphor-icons/react';
import { useAuth } from '@/components/auth/AuthProvider';

export function TopNav() {
  const { user } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="lg:hidden h-16 border-b border-stone-200 bg-white px-4 flex items-center justify-between sticky top-0 z-30">
      <div className="flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-lg bg-teal-600 flex items-center justify-center text-white">
          <PawPrint size={18} weight="fill" />
        </div>
        <span className="font-bold text-stone-900 tracking-tight">VetCare</span>
      </div>

      <div className="flex items-center gap-2">
        <Link
          href="/pets/new"
          className="p-2 rounded-lg bg-teal-50 text-teal-700 hover:bg-teal-100 transition-colors"
          title="Add Pet"
        >
          <Plus size={18} weight="bold" />
        </Link>
        <Link
          href="/profile"
          className="w-8 h-8 rounded-full bg-teal-100 text-teal-800 flex items-center justify-center font-bold text-xs"
        >
          {user?.name ? user.name.slice(0, 1).toUpperCase() : 'U'}
        </Link>
      </div>
    </header>
  );
}
