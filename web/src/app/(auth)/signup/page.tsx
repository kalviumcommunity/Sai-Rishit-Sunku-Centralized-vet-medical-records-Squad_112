'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { PawPrint, Eye, EyeSlash, Envelope, Lock, User, Buildings, ArrowRight, CheckCircle } from '@phosphor-icons/react';
import { registerWithEmail, getInitialRoute } from '@/lib/auth';
import { useAuth } from '@/components/auth/AuthProvider';

const roles = [
  { value: 'owner' as const, label: 'Pet Owner', description: 'Manage your pets\u0027 health records', icon: PawPrint },
  { value: 'vet' as const, label: 'Veterinarian', description: 'Access clinical tools and search', icon: Buildings },
];

export default function SignupPage() {
  const router = useRouter();
  const { setUser } = useAuth();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [role, setRole] = useState<'owner' | 'vet'>('owner');
  const [branchId, setBranchId] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSignup(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !email.trim() || !password.trim()) {
      setError('Please fill in all required fields.');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters.');
      return;
    }
    if (role === 'vet' && !branchId.trim()) {
      setError('Veterinarians must provide a Branch ID.');
      return;
    }

    setIsLoading(true);
    setError('');
    try {
      const user = await registerWithEmail(
        email.trim(),
        password.trim(),
        name.trim(),
        role,
        role === 'vet' ? branchId.trim() : undefined
      );
      setUser(user);
      router.push(getInitialRoute(user.role));
    } catch (err: unknown) {
      const firebaseError = err as { code?: string; message?: string };
      switch (firebaseError.code) {
        case 'auth/email-already-in-use':
          setError('An account with this email already exists.');
          break;
        case 'auth/weak-password':
          setError('Password is too weak. Use at least 6 characters.');
          break;
        case 'auth/invalid-email':
          setError('Invalid email address format.');
          break;
        default:
          setError(firebaseError.message ?? 'Registration failed.');
      }
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-6 sm:p-12">
      <div className="w-full max-w-[480px] space-y-8">
        {/* Logo */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
            <PawPrint size={22} weight="fill" className="text-primary" />
          </div>
          <span className="text-text-primary text-xl font-bold tracking-tight">VetCare</span>
        </div>

        {/* Header */}
        <div className="space-y-2">
          <h2 className="text-3xl font-bold tracking-tight text-text-primary">Create your account</h2>
          <p className="text-text-secondary text-[15px]">Join VetCare to manage pet health records</p>
        </div>

        {/* Error */}
        {error && (
          <div className="bg-destructive/8 border border-destructive/20 rounded-lg px-4 py-3">
            <p className="text-destructive text-sm">{error}</p>
          </div>
        )}

        <form onSubmit={handleSignup} className="space-y-5">
          {/* Role picker */}
          <div className="space-y-2">
            <label className="text-sm font-medium text-text-primary">I am a</label>
            <div className="grid grid-cols-2 gap-3">
              {roles.map((r) => {
                const Icon = r.icon;
                const selected = role === r.value;
                return (
                  <button
                    key={r.value}
                    type="button"
                    onClick={() => setRole(r.value)}
                    className={`relative p-4 rounded-xl border-2 text-left transition-all ${
                      selected
                        ? 'border-primary bg-primary-50 shadow-sm'
                        : 'border-border bg-surface hover:border-border/80'
                    }`}
                  >
                    {selected && (
                      <CheckCircle size={18} weight="fill" className="absolute top-3 right-3 text-primary" />
                    )}
                    <Icon size={24} weight={selected ? 'fill' : 'regular'} className={selected ? 'text-primary' : 'text-text-secondary'} />
                    <p className={`mt-2 text-sm font-semibold ${selected ? 'text-primary-dark' : 'text-text-primary'}`}>
                      {r.label}
                    </p>
                    <p className="text-xs text-text-muted mt-0.5">{r.description}</p>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Name */}
          <div className="space-y-2">
            <label htmlFor="name" className="text-sm font-medium text-text-primary">Full name</label>
            <div className="relative">
              <User size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
              <input id="name" type="text" value={name} onChange={(e) => setName(e.target.value)}
                placeholder="Dr. Smith" className="w-full h-12 pl-11 pr-4 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" disabled={isLoading} />
            </div>
          </div>

          {/* Email */}
          <div className="space-y-2">
            <label htmlFor="signup-email" className="text-sm font-medium text-text-primary">Email address</label>
            <div className="relative">
              <Envelope size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
              <input id="signup-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)}
                placeholder="name@clinic.com" className="w-full h-12 pl-11 pr-4 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" disabled={isLoading} autoComplete="email" />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-2">
            <label htmlFor="signup-password" className="text-sm font-medium text-text-primary">Password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
              <input id="signup-password" type={showPassword ? 'text' : 'password'} value={password} onChange={(e) => setPassword(e.target.value)}
                placeholder="At least 6 characters" className="w-full h-12 pl-11 pr-12 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" disabled={isLoading} autoComplete="new-password" />
              <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-text-muted hover:text-text-secondary" tabIndex={-1}>
                {showPassword ? <EyeSlash size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          {/* Branch ID (vet only) */}
          {role === 'vet' && (
            <div className="space-y-2">
              <label htmlFor="branch" className="text-sm font-medium text-text-primary">Clinic Branch ID</label>
              <div className="relative">
                <Buildings size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
                <input id="branch" type="text" value={branchId} onChange={(e) => setBranchId(e.target.value)}
                  placeholder="e.g. branch_main" className="w-full h-12 pl-11 pr-4 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" disabled={isLoading} />
              </div>
            </div>
          )}

          {/* Submit */}
          <button type="submit" disabled={isLoading}
            className="w-full h-12 bg-primary hover:bg-primary-dark text-white rounded-lg font-semibold text-sm flex items-center justify-center gap-2 transition-all active:scale-[0.98] disabled:opacity-60 disabled:cursor-not-allowed">
            {isLoading ? (
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>Create account <ArrowRight size={16} weight="bold" /></>
            )}
          </button>
        </form>

        <p className="text-center text-sm text-text-secondary">
          Already have an account?{' '}
          <Link href="/login" className="font-semibold text-primary hover:text-primary-dark transition-colors">
            Sign in
          </Link>
        </p>
      </div>
    </div>
  );
}
