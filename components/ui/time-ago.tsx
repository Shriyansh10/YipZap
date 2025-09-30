'use client'

import { useEffect, useState } from 'react'

interface TimeAgoProps {
  date: string | Date
  className?: string
}

export function TimeAgo({ date, className }: TimeAgoProps) {
  const [timeAgo, setTimeAgo] = useState('')

  useEffect(() => {
    const updateTimeAgo = () => {
      const now = new Date()
      const then = new Date(date)
      const seconds = Math.floor((now.getTime() - then.getTime()) / 1000)

      let interval = seconds / 31536000
      if (interval > 1) {
        setTimeAgo(Math.floor(interval) + 'y ago')
        return
      }

      interval = seconds / 2592000
      if (interval > 1) {
        setTimeAgo(Math.floor(interval) + 'mo ago')
        return
      }

      interval = seconds / 86400
      if (interval > 1) {
        setTimeAgo(Math.floor(interval) + 'd ago')
        return
      }

      interval = seconds / 3600
      if (interval > 1) {
        setTimeAgo(Math.floor(interval) + 'h ago')
        return
      }

      interval = seconds / 60
      if (interval > 1) {
        setTimeAgo(Math.floor(interval) + 'm ago')
        return
      }

      setTimeAgo('Just now')
    }

    updateTimeAgo()
    const timer = setInterval(updateTimeAgo, 60000)
    return () => clearInterval(timer)
  }, [date])

  return <span className={className}>{timeAgo}</span>
}