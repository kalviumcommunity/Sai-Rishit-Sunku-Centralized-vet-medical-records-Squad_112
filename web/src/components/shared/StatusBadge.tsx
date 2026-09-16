'use client';

import { cn } from '@/lib/utils';

export type StatusType = 'success' | 'warning' | 'error' | 'info' | 'neutral';

interface StatusBadgeProps {
  status?: StatusType;
  label: string;
  variant?: 'subtle' | 'solid' | 'outline';
  dot?: boolean;
  className?: string;
}

export function StatusBadge({
  status = 'info',
  label,
  variant = 'subtle',
  dot = true,
  className,
}: StatusBadgeProps) {
  const statusStyles: Record<StatusType, { subtle: string; solid: string; outline: string; dot: string }> = {
    success: {
      subtle: 'bg-emerald-50 text-emerald-700 border-emerald-200/60',
      solid: 'bg-emerald-600 text-white border-transparent',
      outline: 'bg-transparent text-emerald-700 border-emerald-300',
      dot: 'bg-emerald-500',
    },
    warning: {
      subtle: 'bg-amber-50 text-amber-700 border-amber-200/60',
      solid: 'bg-amber-600 text-white border-transparent',
      outline: 'bg-transparent text-amber-700 border-amber-300',
      dot: 'bg-amber-500',
    },
    error: {
      subtle: 'bg-rose-50 text-rose-700 border-rose-200/60',
      solid: 'bg-rose-600 text-white border-transparent',
      outline: 'bg-transparent text-rose-700 border-rose-300',
      dot: 'bg-rose-500',
    },
    info: {
      subtle: 'bg-teal-50 text-teal-700 border-teal-200/60',
      solid: 'bg-teal-600 text-white border-transparent',
      outline: 'bg-transparent text-teal-700 border-teal-300',
      dot: 'bg-teal-500',
    },
    neutral: {
      subtle: 'bg-stone-100 text-stone-700 border-stone-200',
      solid: 'bg-stone-700 text-white border-transparent',
      outline: 'bg-transparent text-stone-600 border-stone-300',
      dot: 'bg-stone-400',
    },
  };

  const style = statusStyles[status];

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium border transition-colors',
        style[variant],
        className
      )}
    >
      {dot && <span className={cn('w-1.5 h-1.5 rounded-full', style.dot)} />}
      {label}
    </span>
  );
}
