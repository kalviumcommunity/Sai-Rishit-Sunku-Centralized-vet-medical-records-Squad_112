'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { PawPrint, Eye, EyeSlash, Envelope, Lock, GoogleLogo, ArrowRight, Heart } from '@phosphor-icons/react';
import { signInWithEmail, signInWithGoogle, getInitialRoute } from '@/lib/auth';
import { useAuth } from '@/components/auth/AuthProvider';

export default function LoginPage() {
  const router = useRouter();
  const { setUser } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isGoogleLoading, setIsGoogleLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleEmailSignIn(e: React.FormEvent) {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      setError('Please enter both email and password.');
      return;
    }

    setIsLoading(true);
    setError('');
    try {
      const user = await signInWithEmail(email.trim(), password.trim());
      setUser(user);
      router.push(getInitialRoute(user.role));
    } catch (err: unknown) {
      const firebaseError = err as { code?: string; message?: string };
      switch (firebaseError.code) {
        case 'auth/user-not-found':
          setError('No account found with this email.');
          break;
        case 'auth/wrong-password':
        case 'auth/invalid-credential':
          setError('Incorrect password. Please try again.');
          break;
        case 'auth/invalid-email':
          setError('Invalid email address format.');
          break;
        case 'auth/user-disabled':
          setError('This account has been disabled.');
          break;
        case 'auth/too-many-requests':
          setError('Too many attempts. Please wait and try again.');
          break;
        default:
          setError(firebaseError.message ?? 'Sign-in failed.');
      }
    } finally {
      setIsLoading(false);
    }
  }

  async function handleGoogleSignIn() {
    setIsGoogleLoading(true);
    setError('');
    try {
      const user = await signInWithGoogle();
      if (user) {
        setUser(user);
        router.push(getInitialRoute(user.role));
      }
    } catch (err: unknown) {
      const firebaseError = err as { code?: string; message?: string };
      if (firebaseError.code === 'auth/popup-closed-by-user') {
        // User cancelled — do nothing
      } else {
        setError(firebaseError.message ?? 'Google sign-in failed.');
      }
    } finally {
      setIsGoogleLoading(false);
    }
  }

  const loading = isLoading || isGoogleLoading;

  return (
    <div className="min-h-screen bg-background flex">
      {/* Left panel — branding */}
      <div className="hidden lg:flex lg:w-[45%] bg-primary relative overflow-hidden flex-col justify-between p-12">
        {/* Decorative circles */}
        <div className="absolute -top-24 -right-24 w-96 h-96 rounded-full bg-white/5" />
        <div className="absolute -bottom-32 -left-32 w-[500px] h-[500px] rounded-full bg-white/5" />
        <div className="absolute top-1/2 right-12 w-48 h-48 rounded-full bg-white/8" />

        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 bg-white/15 rounded-xl flex items-center justify-center backdrop-blur-sm">
              <PawPrint size={22} weight="fill" className="text-white" />
            </div>
            <span className="text-white text-xl font-bold tracking-tight">VetCare</span>
          </div>
        </div>

        <div className="relative z-10 space-y-6">
          <h1 className="text-white text-4xl font-bold leading-tight tracking-tight">
            Every pet deserves<br />
            <span className="text-primary-light">exceptional care</span>
          </h1>
          <p className="text-white/70 text-lg leading-relaxed max-w-md">
            Centralized medical records across all your clinic branches. Vaccinations, treatments, documents — all in one place.
          </p>

          {/* Trust indicators */}
          <div className="flex items-center gap-6 pt-4">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center">
                <Heart size={16} weight="fill" className="text-white/80" />
              </div>
              <span className="text-white/60 text-sm">Multi-branch sync</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center">
                <Lock size={16} weight="fill" className="text-white/80" />
              </div>
              <span className="text-white/60 text-sm">Encrypted records</span>
            </div>
          </div>
        </div>

        <div className="relative z-10">
          <p className="text-white/40 text-sm">
            Trusted by veterinary professionals
          </p>
        </div>
      </div>

      {/* Right panel — login form */}
      <div className="flex-1 flex items-center justify-center p-6 sm:p-12">
        <div className="w-full max-w-[420px] space-y-8">
          {/* Mobile logo */}
          <div className="lg:hidden flex items-center gap-3 mb-4">
            <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
              <PawPrint size={22} weight="fill" className="text-primary" />
            </div>
            <span className="text-text-primary text-xl font-bold tracking-tight">VetCare</span>
          </div>

          {/* Header */}
          <div className="space-y-2">
            <h2 className="text-3xl font-bold tracking-tight text-text-primary">
              Welcome back
            </h2>
            <p className="text-text-secondary text-[15px]">
              Sign in to access your pet health records
            </p>
          </div>

          {/* Error message */}
          {error && (
            <div className="bg-destructive/8 border border-destructive/20 rounded-lg px-4 py-3 flex items-start gap-3">
              <div className="w-5 h-5 rounded-full bg-destructive/15 flex items-center justify-center flex-shrink-0 mt-0.5">
                <span className="text-destructive text-xs font-bold">!</span>
              </div>
              <p className="text-destructive text-sm leading-relaxed">{error}</p>
            </div>
          )}

          {/* Login form */}
          <form onSubmit={handleEmailSignIn} className="space-y-5">
            {/* Email */}
            <div className="space-y-2">
              <label htmlFor="email" className="text-sm font-medium text-text-primary">
                Email address
              </label>
              <div className="relative">
                <Envelope size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@clinic.com"
                  className="w-full h-12 pl-11 pr-4 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                  disabled={loading}
                  autoComplete="email"
                />
              </div>
            </div>

            {/* Password */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <label htmlFor="password" className="text-sm font-medium text-text-primary">
                  Password
                </label>
                <button
                  type="button"
                  className="text-xs font-medium text-primary hover:text-primary-dark transition-colors"
                  onClick={() => {/* Future: password reset */}}
                >
                  Forgot password?
                </button>
              </div>
              <div className="relative">
                <Lock size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  className="w-full h-12 pl-11 pr-12 bg-surface-muted border border-border rounded-lg text-text-primary text-sm placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                  disabled={loading}
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-text-muted hover:text-text-secondary transition-colors"
                  tabIndex={-1}
                >
                  {showPassword ? <EyeSlash size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {/* Sign in button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full h-12 bg-text-primary hover:bg-text-primary/90 text-white rounded-lg font-semibold text-sm flex items-center justify-center gap-2 transition-all active:scale-[0.98] disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>
                  Sign in
                  <ArrowRight size={16} weight="bold" />
                </>
              )}
            </button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-4">
            <div className="flex-1 h-px bg-border" />
            <span className="text-text-muted text-xs font-medium uppercase tracking-wider">or</span>
            <div className="flex-1 h-px bg-border" />
          </div>

          {/* Google sign-in */}
          <button
            onClick={handleGoogleSignIn}
            disabled={loading}
            className="w-full h-12 bg-surface border border-border hover:border-border/80 hover:bg-surface-muted rounded-lg font-medium text-sm text-text-primary flex items-center justify-center gap-3 transition-all active:scale-[0.98] disabled:opacity-60 disabled:cursor-not-allowed shadow-card"
          >
            {isGoogleLoading ? (
              <div className="w-5 h-5 border-2 border-text-muted/30 border-t-text-muted rounded-full animate-spin" />
            ) : (
              <>
                <GoogleLogo size={20} weight="bold" className="text-[#4285F4]" />
                Continue with Google
              </>
            )}
          </button>

          {/* Sign up link */}
          <p className="text-center text-sm text-text-secondary">
            Don&apos;t have an account?{' '}
            <Link
              href="/signup"
              className="font-semibold text-primary hover:text-primary-dark transition-colors"
            >
              Create account
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
