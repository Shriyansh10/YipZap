'use client'

import { useState, useEffect } from 'react'

interface FormatDateProps {
  dateString: string
  options?: Intl.DateTimeFormatOptions
  className?: string
}

export function FormatDate({
  dateString,
  options = {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  },
  className
}: FormatDateProps) {
  const [formattedDate, setFormattedDate] = useState<string>('')
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)

    const formatDate = (dateStr: string) => {
      const date = new Date(dateStr)
      return date.toLocaleDateString('en-US', options)
    }

    setFormattedDate(formatDate(dateString))
  }, [dateString, options])

  // Avoid hydration mismatch by not rendering date until mounted
  if (!mounted) {
    return <span className={className}>&nbsp;</span>
  }

  return <span className={className}>{formattedDate}</span>
}