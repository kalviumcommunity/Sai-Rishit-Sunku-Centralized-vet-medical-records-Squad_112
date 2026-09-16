'use client';

import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

interface StatsCardProps {
  label: string;
  value: string | number;
  subtitle?: string;
  icon: ReactNode;
  iconBg?: string;
  iconColor?: string;
  className?: string;
}

export function StatsCard({
  label,
  value,
  subtitle,
  icon,
  iconBg = 'bg-teal-50',
  iconColor = 'text-teal-600',
  className,
}: StatsCardProps) {
  return (
    <div
      className={cn(
        'rounded-2xl border border-stone-200/80 bg-white p-5 shadow-xs flex items-center justify-between gap-4',
        className
      )}
    >
      <div>
        <p className="text-xs font-semibold text-stone-500 uppercase tracking-wider">
          {label}
        </p>
        <p className="mt-1 text-2xl font-bold text-stone-900 tracking-tight">
          {value}
        </p>
        {subtitle && (
          <p className="mt-0.5 text-xs text-stone-400 font-medium">{subtitle}</p>
        )}
      </div>

      <div
        className={cn(
          'w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 border border-stone-100/60 shadow-2xs',
          iconBg,
          iconColor
        )}
      >
        {icon}
      </div>
    </div>
  );
}
