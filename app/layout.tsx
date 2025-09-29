import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { ReactQueryProvider } from '@/lib/react-query'
import { Toaster } from '@/components/ui/sonner'
import { Header } from '@/components/layout/header'
import { FloatingActionButton } from '@/components/layout/floating-action-button'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'MemePlatform - Share Your Memes',
  description: 'The ultimate platform for sharing and discovering the best memes',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ReactQueryProvider>
          <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
            <Header />
            <main className="pt-16">
              {children}
            </main>
            <FloatingActionButton />
          </div>
          <Toaster />
        </ReactQueryProvider>
      </body>
    </html>
  )
}
