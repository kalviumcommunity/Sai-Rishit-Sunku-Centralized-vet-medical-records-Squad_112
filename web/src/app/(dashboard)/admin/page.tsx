'use client';

import { useState, useEffect } from 'react';
import { getAllUsers, updateUserRole, getBranches, addBranch, deleteBranch } from '@/lib/firestore';
import { User, Branch } from '@/types';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatDate } from '@/lib/utils';
import {
  ShieldCheck,
  Buildings,
  Users,
  Plus,
  Trash,
  Check,
  X,
  Phone,
  MapPin,
} from '@phosphor-icons/react';

export default function AdminPage() {
  const [tab, setTab] = useState<'users' | 'branches'>('users');
  const [users, setUsers] = useState<User[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);

  // New Branch modal state
  const [showAddBranch, setShowAddBranch] = useState(false);
  const [branchName, setBranchName] = useState('');
  const [branchAddress, setBranchAddress] = useState('');
  const [branchPhone, setBranchPhone] = useState('');
  const [branchIsHub, setBranchIsHub] = useState(false);
  const [savingBranch, setSavingBranch] = useState(false);

  useEffect(() => {
    async function load() {
      try {
        const [usersData, branchesData] = await Promise.all([
          getAllUsers(),
          getBranches(),
        ]);
        setUsers(usersData);
        setBranches(branchesData);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const handleRoleChange = async (userId: string, newRole: 'owner' | 'vet' | 'admin') => {
    try {
      await updateUserRole(userId, newRole);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, role: newRole } : u))
      );
    } catch (err) {
      alert('Failed to update role');
    }
  };

  const handleAddBranchSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!branchName) return;
    setSavingBranch(true);
    try {
      const id = await addBranch({
        name: branchName,
        address: branchAddress,
        phone: branchPhone,
        isHub: branchIsHub,
      });
      setBranches((prev) => [
        ...prev,
        {
          id,
          name: branchName,
          address: branchAddress,
          phone: branchPhone,
          isHub: branchIsHub,
          createdAt: new Date(),
        },
      ]);
      setShowAddBranch(false);
      setBranchName('');
      setBranchAddress('');
      setBranchPhone('');
      setBranchIsHub(false);
    } catch (err) {
      alert('Failed to add branch');
    } finally {
      setSavingBranch(false);
    }
  };

  const handleDeleteBranch = async (branchId: string) => {
    if (!confirm('Are you sure you want to remove this branch?')) return;
    try {
      await deleteBranch(branchId);
      setBranches((prev) => prev.filter((b) => b.id !== branchId));
    } catch (err) {
      alert('Failed to delete branch');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900">
            System Administration
          </h1>
          <p className="mt-1 text-sm text-stone-500">
            Control user access roles, doctor privileges, and physical clinic locations.
          </p>
        </div>

        {tab === 'branches' && (
          <button
            type="button"
            onClick={() => setShowAddBranch(true)}
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-xs font-semibold shadow-sm transition-all cursor-pointer"
          >
            <Plus size={16} weight="bold" />
            Add New Branch
          </button>
        )}
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2 border-b border-stone-200">
        <button
          type="button"
          onClick={() => setTab('users')}
          className={`pb-3 px-3 text-sm font-semibold flex items-center gap-2 transition-all cursor-pointer ${
            tab === 'users'
              ? 'text-teal-700 border-b-2 border-teal-600'
              : 'text-stone-500 hover:text-stone-900'
          }`}
        >
          <Users size={18} />
          User Management ({users.length})
        </button>

        <button
          type="button"
          onClick={() => setTab('branches')}
          className={`pb-3 px-3 text-sm font-semibold flex items-center gap-2 transition-all cursor-pointer ${
            tab === 'branches'
              ? 'text-teal-700 border-b-2 border-teal-600'
              : 'text-stone-500 hover:text-stone-900'
          }`}
        >
          <Buildings size={18} />
          Clinic Branches ({branches.length})
        </button>
      </div>

      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">
          Loading administration console...
        </div>
      ) : tab === 'users' ? (
        /* Users Table */
        <div className="rounded-2xl border border-stone-200/90 bg-white overflow-hidden shadow-xs">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-stone-50/80 border-b border-stone-200 text-xs font-semibold text-stone-500 uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-5">User</th>
                  <th className="py-3 px-5">Email</th>
                  <th className="py-3 px-5">Role Permission</th>
                  <th className="py-3 px-5">Joined</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {users.map((u) => (
                  <tr key={u.id} className="hover:bg-stone-50/50 transition-colors">
                    <td className="py-3.5 px-5 font-semibold text-stone-900">
                      {u.name || 'Unnamed'}
                    </td>
                    <td className="py-3.5 px-5 text-stone-600 font-mono text-xs">
                      {u.email}
                    </td>
                    <td className="py-3.5 px-5">
                      <select
                        value={u.role}
                        onChange={(e) =>
                          handleRoleChange(
                            u.id,
                            e.target.value as 'owner' | 'vet' | 'admin'
                          )
                        }
                        className="px-2.5 py-1 rounded-lg border border-stone-200 text-xs font-semibold bg-white text-stone-800 focus:outline-none focus:ring-2 focus:ring-teal-500/20"
                      >
                        <option value="owner">Pet Owner</option>
                        <option value="vet">Veterinarian</option>
                        <option value="admin">Administrator</option>
                      </select>
                    </td>
                    <td className="py-3.5 px-5 text-xs text-stone-400">
                      {formatDate(u.createdAt)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        /* Branches List */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {branches.map((b) => (
            <div
              key={b.id}
              className="rounded-2xl border border-stone-200/90 bg-white p-5 shadow-xs flex flex-col justify-between"
            >
              <div>
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl bg-teal-50 border border-teal-200 text-teal-700 flex items-center justify-center shrink-0">
                      <Buildings size={24} weight="duotone" />
                    </div>
                    <div>
                      <h3 className="font-bold text-stone-900 text-base leading-tight">
                        {b.name}
                      </h3>
                      <div className="mt-1">
                        <StatusBadge
                          label={b.isHub ? 'Hub Hospital' : 'Satellite Clinic'}
                          status={b.isHub ? 'success' : 'neutral'}
                        />
                      </div>
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={() => handleDeleteBranch(b.id)}
                    className="p-1.5 text-stone-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors cursor-pointer"
                    title="Remove branch"
                  >
                    <Trash size={16} />
                  </button>
                </div>

                <div className="mt-4 pt-3 border-t border-stone-100 space-y-1.5 text-xs text-stone-600">
                  {b.address && (
                    <div className="flex items-center gap-2">
                      <MapPin size={15} className="text-stone-400 shrink-0" />
                      <span>{b.address}</span>
                    </div>
                  )}
                  {b.phone && (
                    <div className="flex items-center gap-2">
                      <Phone size={15} className="text-stone-400 shrink-0" />
                      <span>{b.phone}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Branch Modal */}
      {showAddBranch && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl border border-stone-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between pb-4 border-b border-stone-100">
              <h2 className="text-lg font-bold text-stone-900">Add Clinic Branch</h2>
              <button
                onClick={() => setShowAddBranch(false)}
                className="p-1.5 text-stone-400 hover:text-stone-700 rounded-lg"
              >
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleAddBranchSubmit} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-stone-700 mb-1">
                  Branch Name *
                </label>
                <input
                  type="text"
                  placeholder="e.g. North City Vet Center"
                  value={branchName}
                  onChange={(e) => setBranchName(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-stone-700 mb-1">
                  Physical Address
                </label>
                <input
                  type="text"
                  placeholder="e.g. 104 Willow St, Suite B"
                  value={branchAddress}
                  onChange={(e) => setBranchAddress(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-stone-700 mb-1">
                  Phone Number
                </label>
                <input
                  type="tel"
                  placeholder="e.g. +1 (555) 019-2834"
                  value={branchPhone}
                  onChange={(e) => setBranchPhone(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-600"
                />
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="isHubCheckbox"
                  checked={branchIsHub}
                  onChange={(e) => setBranchIsHub(e.target.checked)}
                  className="rounded border-stone-300 text-teal-600 focus:ring-teal-500"
                />
                <label htmlFor="isHubCheckbox" className="text-xs text-stone-700 font-medium">
                  Designate as Central Hub / 24hr Emergency Hospital
                </label>
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-stone-100">
                <button
                  type="button"
                  onClick={() => setShowAddBranch(false)}
                  className="px-4 py-2.5 rounded-xl text-sm font-medium text-stone-600 hover:bg-stone-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={savingBranch}
                  className="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-semibold shadow-sm transition-all disabled:opacity-50 cursor-pointer"
                >
                  {savingBranch ? 'Adding...' : 'Add Branch'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
