'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { MemeCard } from '@/components/memes/meme-card'
import { Skeleton } from '@/components/ui/skeleton'
import { Flame, Calendar } from 'lucide-react'
import { cn } from '@/lib/utils'

type TimeFrame = 'today' | 'week'

const mockMemes = [
  {
    id: '1',
    author_id: 'user1',
    title: 'When you finally understand recursion',
    media_type: 'IMAGE' as const,
    media_url: 'https://images.pexels.com/photos/4439901/pexels-photo-4439901.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 152,
    comment_count: 24,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    author: {
      name: 'CodeMaster',
      image: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'codemaster'
    },
    isLiked: false,
  },
  {
    id: '2',
    author_id: 'user2',
    title: 'Me explaining my code to my manager',
    media_type: 'IMAGE' as const,
    media_url: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 89,
    comment_count: 12,
    created_at: new Date(Date.now() - 3600000).toISOString(),
    updated_at: new Date(Date.now() - 3600000).toISOString(),
    author: {
      name: 'DevLife',
      image: 'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'devlife'
    },
    isLiked: true,
  },
  {
    id: '3',
    author_id: 'user3',
    title: 'When the test passes on the first try',
    media_type: 'IMAGE' as const,
    media_url: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 203,
    comment_count: 45,
    created_at: new Date(Date.now() - 7200000).toISOString(),
    updated_at: new Date(Date.now() - 7200000).toISOString(),
    author: {
      name: 'TestingQueen',
      image: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'testingqueen'
    },
    isLiked: false,
  }
]

export function TopFeed() {
  const [timeFrame, setTimeFrame] = useState<TimeFrame>('today')
  const [isLoading, setIsLoading] = useState(false)

  const handleTimeFrameChange = (newTimeFrame: TimeFrame) => {
    if (newTimeFrame === timeFrame) return

    setIsLoading(true)
    setTimeFrame(newTimeFrame)

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false)
    }, 1000)
  }

  const handleLike = (postId: string) => {
    console.log('Like post:', postId)
    // Will be implemented with actual API calls
  }

  const handleComment = (postId: string) => {
    console.log('Comment on post:', postId)
    // Will be implemented with actual API calls
  }

  const handleShare = (postId: string) => {
    console.log('Share post:', postId)
    // Will be implemented with actual API calls
  }

  const handleDelete = (postId: string) => {
    console.log('Delete post:', postId)
    // Will be implemented with actual API calls
  }

  return (
    <div className="max-w-2xl mx-auto px-4 py-6 space-y-6">
      {/* Time Frame Toggle */}
      <div className="flex items-center justify-center">
        <div className="flex items-center bg-white dark:bg-gray-800 rounded-lg p-1 shadow-sm border">
          <Button
            variant="ghost"
            size="sm"
            className={cn(
              'h-8 px-4 rounded-md transition-all',
              timeFrame === 'today'
                ? 'bg-blue-600 text-white shadow-sm hover:bg-blue-700'
                : 'text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100'
            )}
            onClick={() => handleTimeFrameChange('today')}
          >
            <Flame className="mr-2 h-4 w-4" />
            Today
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className={cn(
              'h-8 px-4 rounded-md transition-all',
              timeFrame === 'week'
                ? 'bg-blue-600 text-white shadow-sm hover:bg-blue-700'
                : 'text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100'
            )}
            onClick={() => handleTimeFrameChange('week')}
          >
            <Calendar className="mr-2 h-4 w-4" />
            Week
          </Button>
        </div>
      </div>

      {/* Content */}
      {isLoading ? (
        <div className="space-y-6">
          {[1, 2, 3].map((i) => (
            <div key={i} className="w-full max-w-md mx-auto">
              <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border p-4 space-y-4">
                <div className="flex items-center space-x-3">
                  <Skeleton className="h-8 w-8 rounded-full" />
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-24" />
                    <Skeleton className="h-3 w-16" />
                  </div>
                </div>
                <Skeleton className="h-64 w-full rounded" />
                <div className="flex justify-between">
                  <div className="flex space-x-4">
                    <Skeleton className="h-8 w-16" />
                    <Skeleton className="h-8 w-16" />
                  </div>
                  <Skeleton className="h-8 w-16" />
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-6">
          {mockMemes.map((meme) => (
            <MemeCard
              key={meme.id}
              post={meme}
              onLike={handleLike}
              onComment={handleComment}
              onShare={handleShare}
              onDelete={handleDelete}
            />
          ))}

          {/* Load More */}
          <div className="flex justify-center pt-8">
            <Button variant="outline" size="lg">
              Load More Memes
            </Button>
          </div>
        </div>
      )}

      {/* Empty State */}
      {!isLoading && mockMemes.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">😴</div>
          <h3 className="text-lg font-semibold mb-2">No memes yet</h3>
          <p className="text-muted-foreground mb-4">
            Be the first to share a meme {timeFrame === 'today' ? 'today' : 'this week'}!
          </p>
          <Button>Post a Meme</Button>
        </div>
      )}
    </div>
  )
}