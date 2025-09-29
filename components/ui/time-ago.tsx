'use client'

import { useState, useEffect } from 'react'

interface TimeAgoProps {
  dateString: string
  className?: string
}

export function TimeAgo({ dateString, className }: TimeAgoProps) {
  const [timeAgo, setTimeAgo] = useState<string>('')
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)

    const formatTimeAgo = (dateStr: string) => {
      const date = new Date(dateStr)
      const now = new Date()
      const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000)

      if (diffInSeconds < 60) return 'just now'
      if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
      if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
      if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`
      return date.toLocaleDateString()
    }

    const updateTime = () => {
      setTimeAgo(formatTimeAgo(dateString))
    }

    updateTime()

    // Update every minute for accurate time display
    const interval = setInterval(updateTime, 60000)

    return () => clearInterval(interval)
  }, [dateString])

  // Avoid hydration mismatch by not rendering time until mounted
  if (!mounted) {
    return <span className={className}>&nbsp;</span>
  }

  return <span className={className}>{timeAgo}</span>
}