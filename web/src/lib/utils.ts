import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { Timestamp } from 'firebase/firestore';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/** Parse Firestore Timestamp or various date formats into a JS Date */
export function parseFirestoreDate(value: unknown): Date {
  if (!value) return new Date();
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'number') return new Date(value);
  if (typeof value === 'string') return new Date(value);
  return new Date();
}

/** Format a date as a human-readable string */
export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  }).format(date);
}

/** Format a date with time */
export function formatDateTime(date: Date): string {
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
}

/** Calculate vaccination status based on nextDueDate */
export function getVaccinationStatus(nextDueDate: Date): 'up-to-date' | 'due-soon' | 'overdue' {
  const now = new Date();
  const daysUntilDue = Math.floor((nextDueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  if (daysUntilDue < 0) return 'overdue';
  if (daysUntilDue <= 30) return 'due-soon';
  return 'up-to-date';
}

/** Get species emoji for display */
export function getSpeciesIcon(species: string): string {
  switch (species.toLowerCase()) {
    case 'dog': return '🐕';
    case 'cat': return '🐈';
    case 'bird': return '🐦';
    case 'rabbit': return '🐇';
    case 'fish': return '🐟';
    case 'hamster': return '🐹';
    default: return '🐾';
  }
}
