'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { MemeCard } from '@/components/memes/meme-card'
import { Skeleton } from '@/components/ui/skeleton'
import { RefreshCw, Sparkles } from 'lucide-react'

const mockFreshMemes = [
  {
    id: '4',
    author_id: 'user4',
    title: 'Just deployed to production on Friday',
    media_type: 'IMAGE' as const,
    media_url: 'https://images.pexels.com/photos/2148222/pexels-photo-2148222.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 3,
    comment_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    author: {
      name: 'FridayDeployer',
      image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'fridaydeployer'
    },
    isLiked: false,
  },
  {
    id: '5',
    author_id: 'user5',
    title: 'When you fix a bug but create 3 new ones',
    media_type: 'IMAGE' as const,
    media_url: 'https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 12,
    comment_count: 2,
    created_at: new Date(Date.now() - 600000).toISOString(),
    updated_at: new Date(Date.now() - 600000).toISOString(),
    author: {
      name: 'BugHunter',
      image: 'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'bughunter'
    },
    isLiked: true,
  },
  {
    id: '6',
    author_id: 'user6',
    title: 'My code at 3 AM vs 9 AM',
    media_type: 'GIF' as const,
    media_url: 'https://images.pexels.com/photos/1181677/pexels-photo-1181677.jpeg?auto=compress&cs=tinysrgb&w=800',
    storage_path: null,
    nsfw: false,
    like_count: 7,
    comment_count: 1,
    created_at: new Date(Date.now() - 1200000).toISOString(),
    updated_at: new Date(Date.now() - 1200000).toISOString(),
    author: {
      name: 'NightCoder',
      image: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
      username: 'nightcoder'
    },
    isLiked: false,
  }
]

export function FreshFeed() {
  const [isLoading, setIsLoading] = useState(false)
  const [isRefreshing, setIsRefreshing] = useState(false)

  const handleRefresh = () => {
    setIsRefreshing(true)

    // Simulate API call
    setTimeout(() => {
      setIsRefreshing(false)
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
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <Sparkles className="h-6 w-6 text-blue-600" />
          <h1 className="text-2xl font-bold">Fresh Memes</h1>
        </div>

        <Button
          variant="outline"
          size="sm"
          onClick={handleRefresh}
          disabled={isRefreshing}
          className="flex items-center space-x-2"
        >
          <RefreshCw className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} />
          <span>Refresh</span>
        </Button>
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
          {mockFreshMemes.map((meme) => (
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
              Load More Fresh Memes
            </Button>
          </div>
        </div>
      )}

      {/* Empty State */}
      {!isLoading && mockFreshMemes.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">🌱</div>
          <h3 className="text-lg font-semibold mb-2">No fresh memes yet</h3>
          <p className="text-muted-foreground mb-4">
            Check back soon for the latest memes from the community!
          </p>
          <Button>Post the First Meme</Button>
        </div>
      )}
    </div>
  )
}