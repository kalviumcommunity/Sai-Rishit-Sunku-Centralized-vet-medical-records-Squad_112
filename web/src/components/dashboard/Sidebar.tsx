'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  PawPrint,
  House,
  MagnifyingGlass,
  CalendarCheck,
  PlusCircle,
  Gear,
  SignOut,
  User,
  ShieldCheck,
  Stethoscope,
} from '@phosphor-icons/react';
import { useAuth } from '@/components/auth/AuthProvider';
import { signOutUser } from '@/lib/auth';
import { cn } from '@/lib/utils';
import { StatusBadge } from '@/components/shared/StatusBadge';

export function Sidebar() {
  const pathname = usePathname();
  const { user } = useAuth();

  const handleSignOut = async () => {
    await signOutUser();
  };

  const navItems = [
    {
      label: 'Dashboard',
      href: '/home',
      icon: House,
      roles: ['owner', 'vet', 'admin'],
    },
    {
      label: 'My Pets',
      href: '/pets',
      icon: PawPrint,
      roles: ['owner'],
    },
    {
      label: 'Search Records',
      href: '/search',
      icon: MagnifyingGlass,
      roles: ['vet', 'admin'],
    },
    {
      label: 'Follow-ups',
      href: '/followups',
      icon: CalendarCheck,
      roles: ['vet'],
    },
    {
      label: 'Register Pet',
      href: '/pets/new',
      icon: PlusCircle,
      roles: ['owner', 'vet', 'admin'],
    },
    {
      label: 'Admin Console',
      href: '/admin',
      icon: ShieldCheck,
      roles: ['admin'],
    },
    {
      label: 'My Profile',
      href: '/profile',
      icon: User,
      roles: ['owner', 'vet', 'admin'],
    },
  ];

  const filteredNav = navItems.filter(
    (item) => !user || item.roles.includes(user.role)
  );

  return (
    <aside className="w-64 border-r border-stone-200/80 bg-white flex flex-col justify-between h-screen sticky top-0">
      {/* Brand Header */}
      <div>
        <div className="h-16 px-6 flex items-center gap-3 border-b border-stone-100">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-teal-600 to-emerald-500 flex items-center justify-center text-white shadow-sm shadow-teal-700/20">
            <PawPrint size={22} weight="fill" />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-stone-900 tracking-tight text-lg leading-none">
                VetCare
              </span>
              <span className="text-[10px] font-semibold text-teal-700 bg-teal-50 px-1.5 py-0.5 rounded border border-teal-200/60">
                PRO
              </span>
            </div>
            <p className="text-[11px] text-stone-400 mt-0.5 leading-none">Pet Healthcare System</p>
          </div>
        </div>

        {/* Navigation links */}
        <nav className="p-4 space-y-1.5">
          {filteredNav.map((item) => {
            const isActive =
              pathname === item.href ||
              (item.href !== '/home' && pathname.startsWith(item.href));
            const Icon = item.icon;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all group',
                  isActive
                    ? 'bg-teal-50 text-teal-900 font-semibold shadow-xs'
                    : 'text-stone-600 hover:text-stone-900 hover:bg-stone-50'
                )}
              >
                <Icon
                  size={20}
                  weight={isActive ? 'fill' : 'regular'}
                  className={cn(
                    'transition-colors',
                    isActive
                      ? 'text-teal-600'
                      : 'text-stone-400 group-hover:text-stone-600'
                  )}
                />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>
      </div>

      {/* User Footer */}
      <div className="p-4 border-t border-stone-100 bg-stone-50/50">
        <div className="flex items-center justify-between gap-3 mb-3">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-full bg-teal-100 border border-teal-200 text-teal-800 flex items-center justify-center font-semibold text-xs shrink-0">
              {user?.name ? user.name.slice(0, 2).toUpperCase() : 'VC'}
            </div>
            <div className="min-w-0">
              <p className="text-xs font-semibold text-stone-900 truncate">
                {user?.name || 'User'}
              </p>
              <div className="flex items-center gap-1 mt-0.5">
                <StatusBadge
                  status={
                    user?.role === 'admin'
                      ? 'error'
                      : user?.role === 'vet'
                      ? 'info'
                      : 'neutral'
                  }
                  label={user?.role?.toUpperCase() || 'OWNER'}
                  dot={false}
                  className="px-1.5 py-0 text-[10px]"
                />
              </div>
            </div>
          </div>
        </div>

        <button
          onClick={handleSignOut}
          type="button"
          className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-lg text-xs font-medium text-stone-600 hover:text-rose-600 hover:bg-rose-50 transition-colors border border-stone-200/80 hover:border-rose-200 cursor-pointer"
        >
          <SignOut size={16} />
          Sign Out
        </button>
      </div>
    </aside>
  );
}
