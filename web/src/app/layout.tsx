import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { AuthProvider } from '@/components/auth/AuthProvider';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-sans',
});

export const metadata: Metadata = {
  title: 'VetCare — Veterinary Medical Records',
  description: 'Centralized veterinary medical records across clinic branches. Manage pet health records, vaccinations, treatments, and documents.',
  keywords: ['veterinary', 'pet health', 'medical records', 'vaccinations', 'vet clinic'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang='en' className={inter.variable}>
      <body className='min-h-screen bg-background font-sans antialiased'>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
