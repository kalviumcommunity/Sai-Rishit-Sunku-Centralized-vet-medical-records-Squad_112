'use client';

import { useState } from 'react';
import { useAuth } from '@/components/auth/AuthProvider';
import { signOutUser } from '@/lib/auth';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatDate } from '@/lib/utils';
import {
  User as UserIcon,
  Envelope,
  ShieldCheck,
  Buildings,
  SignOut,
  Sparkle,
  DeviceMobile,
  CheckCircle,
} from '@phosphor-icons/react';

export default function ProfilePage() {
  const { user, firebaseUser } = useAuth();
  const [updating, setUpdating] = useState(false);

  const handleSignOut = async () => {
    await signOutUser();
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
          Account Profile
        </h1>
        <p className="mt-1 text-sm text-stone-500">
          Manage your account credentials, security preferences, and clinic affiliation.
        </p>
      </div>

      {/* Profile Card */}
      <div className="rounded-3xl border border-stone-200/90 bg-white p-6 sm:p-8 shadow-xs">
        <div className="flex flex-col sm:flex-row items-start sm:items-center gap-5 pb-6 border-b border-stone-100">
          <div className="w-20 h-20 rounded-2xl bg-teal-100 border border-teal-200 text-teal-800 font-bold text-2xl flex items-center justify-center shadow-2xs">
            {user?.name ? user.name.slice(0, 2).toUpperCase() : 'VC'}
          </div>
          <div>
            <div className="flex items-center gap-3">
              <h2 className="text-xl font-bold text-stone-900">
                {user?.name || 'VetCare Member'}
              </h2>
              <StatusBadge
                label={user?.role?.toUpperCase() || 'OWNER'}
                status={
                  user?.role === 'admin'
                    ? 'error'
                    : user?.role === 'vet'
                    ? 'info'
                    : 'neutral'
                }
              />
            </div>
            <p className="text-sm text-stone-500 mt-0.5">{user?.email}</p>
          </div>
        </div>

        {/* Details Grid */}
        <div className="mt-6 space-y-4 text-sm">
          <div className="flex items-center justify-between py-3 border-b border-stone-100">
            <div className="flex items-center gap-3 text-stone-600">
              <Envelope size={18} className="text-stone-400" />
              <span>Registered Email</span>
            </div>
            <span className="font-semibold text-stone-900 font-mono text-xs">
              {user?.email}
            </span>
          </div>

          <div className="flex items-center justify-between py-3 border-b border-stone-100">
            <div className="flex items-center gap-3 text-stone-600">
              <ShieldCheck size={18} className="text-stone-400" />
              <span>Account Role</span>
            </div>
            <span className="font-semibold capitalize text-stone-900">
              {user?.role} Access
            </span>
          </div>

          {user?.branchId && (
            <div className="flex items-center justify-between py-3 border-b border-stone-100">
              <div className="flex items-center gap-3 text-stone-600">
                <Buildings size={18} className="text-stone-400" />
                <span>Assigned Branch</span>
              </div>
              <span className="font-semibold text-stone-900">
                {user.branchId}
              </span>
            </div>
          )}

          <div className="flex items-center justify-between py-3 border-b border-stone-100">
            <div className="flex items-center gap-3 text-stone-600">
              <CheckCircle size={18} className="text-emerald-500" />
              <span>Authentication Status</span>
            </div>
            <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200/60">
              Firebase Synced
            </span>
          </div>
        </div>

        {/* Action button */}
        <div className="mt-8 pt-6 border-t border-stone-100 flex items-center justify-between">
          <span className="text-xs text-stone-400">
            Platform Version 2.0 - VetCare Web Pro
          </span>

          <button
            type="button"
            onClick={handleSignOut}
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 text-xs font-semibold transition-colors cursor-pointer"
          >
            <SignOut size={16} />
            Sign Out
          </button>
        </div>
      </div>
    </div>
  );
}