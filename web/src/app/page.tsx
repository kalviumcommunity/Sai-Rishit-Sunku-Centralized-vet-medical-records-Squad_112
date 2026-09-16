'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PawPrint } from '@phosphor-icons/react';
import { useAuth } from '@/components/auth/AuthProvider';
import { getInitialRoute } from '@/lib/auth';

export default function RootPage() {
  const router = useRouter();
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading) {
      if (user) {
        router.replace(getInitialRoute(user.role));
      } else {
        router.replace('/login');
      }
    }
  }, [user, loading, router]);

  return (
    <div className='min-h-screen bg-background flex items-center justify-center'>
      <div className='flex flex-col items-center gap-4'>
        <div className='w-14 h-14 bg-primary/10 rounded-2xl flex items-center justify-center animate-pulse'>
          <PawPrint size={28} weight='fill' className='text-primary' />
        </div>
        <p className='text-text-secondary text-sm font-medium'>Loading VetCare...</p>
      </div>
    </div>
  );
}
