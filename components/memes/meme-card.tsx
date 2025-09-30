'use client'

import { useState } from 'react'
import Image from 'next/image'
import { Card, CardContent, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { TimeAgo } from '@/components/ui/time-ago'
import { Heart, MessageCircle, Share2, MoveHorizontal as MoreHorizontal, Eye, EyeOff, Flag } from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { MemePost } from '@/lib/validations'
import { useAuth } from '@/hooks/use-auth'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

interface MemeCardProps {
  post: MemePost & {
    author: {
      name: string | null
      image: string | null
      username?: string
    }
    isLiked?: boolean
  }
  onLike?: (postId: string) => void
  onComment?: (postId: string) => void
  onShare?: (postId: string) => void
  onDelete?: (postId: string) => void
}

export function MemeCard({
  post,
  onLike,
  onComment,
  onShare,
  onDelete
}: MemeCardProps) {
  const { user } = useAuth()
  const [showNsfw, setShowNsfw] = useState(false)
  const [imageLoading, setImageLoading] = useState(true)

  const handleLike = () => {
    if (!user) {
      toast.error('Please sign in to like posts')
      return
    }
    onLike?.(post.id)
  }

  const handleComment = () => {
    if (!user) {
      toast.error('Please sign in to comment')
      return
    }
    onComment?.(post.id)
  }

  const handleShare = async () => {
    const url = `${window.location.origin}/meme/${post.id}`

    if (navigator.share) {
      try {
        await navigator.share({
          title: post.title || 'Check out this meme!',
          url,
        })
        return
      } catch (error) {
        // Fallback to clipboard
      }
    }

    try {
      await navigator.clipboard.writeText(url)
      toast.success('Link copied to clipboard!')
    } catch (error) {
      toast.error('Failed to copy link')
    }
  }


  const canDelete = user && (user.id === post.author_id || user.role === 'ADMIN')

  return (
    <Card className="w-full max-w-md mx-auto overflow-hidden">
      <CardContent className="p-0">
        {/* Header with author info */}
        <div className="flex items-center justify-between p-4 pb-2">
          <div className="flex items-center space-x-3">
            <Avatar className="h-8 w-8">
              <AvatarImage
                src={post.author.image || undefined}
                alt={post.author.name || 'User'}
              />
              <AvatarFallback>
                {(post.author.name || post.author.username || 'U')[0].toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="flex flex-col">
              <span className="text-sm font-medium">
                {post.author.username || post.author.name || 'Anonymous'}
              </span>
              <TimeAgo
                date={post.created_at}
                className="text-xs text-muted-foreground"
              />
            </div>
          </div>

          <div className="flex items-center space-x-2">
            {post.nsfw && (
              <Badge variant="destructive" className="text-xs">
                NSFW
              </Badge>
            )}

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                  <MoreHorizontal className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={() => toast.info('Report feature coming soon')}>
                  <Flag className="mr-2 h-4 w-4" />
                  Report
                </DropdownMenuItem>
                {canDelete && (
                  <DropdownMenuItem
                    onClick={() => onDelete?.(post.id)}
                    className="text-red-600"
                  >
                    Delete
                  </DropdownMenuItem>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>

        {/* Title */}
        {post.title && (
          <div className="px-4 pb-2">
            <p className="text-sm">{post.title}</p>
          </div>
        )}

        {/* Media Content */}
        <div className="relative bg-gray-100 dark:bg-gray-800">
          {post.nsfw && !showNsfw ? (
            <div className="flex flex-col items-center justify-center py-24 px-4 text-center">
              <EyeOff className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">NSFW Content</h3>
              <p className="text-sm text-muted-foreground mb-4">
                This content may not be suitable for all audiences
              </p>
              <Button
                variant="outline"
                onClick={() => setShowNsfw(true)}
                className="flex items-center space-x-2"
              >
                <Eye className="h-4 w-4" />
                <span>Show Content</span>
              </Button>
            </div>
          ) : (
            <>
              {post.media_type === 'VIDEO' ? (
                <video
                  controls
                  className="w-full max-h-96 object-contain"
                  poster={post.media_url}
                >
                  <source src={post.media_url} type="video/mp4" />
                  Your browser does not support the video tag.
                </video>
              ) : (
                <div className="relative">
                  <Image
                    src={post.media_url}
                    alt={post.title || 'Meme'}
                    width={400}
                    height={400}
                    className={cn(
                      "w-full max-h-96 object-contain transition-opacity duration-200",
                      imageLoading ? "opacity-0" : "opacity-100"
                    )}
                    onLoad={() => setImageLoading(false)}
                    onError={() => setImageLoading(false)}
                  />
                  {imageLoading && (
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </div>
      </CardContent>

      {/* Actions */}
      <CardFooter className="px-4 py-3">
        <div className="flex items-center justify-between w-full">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              size="sm"
              onClick={handleLike}
              className={cn(
                "flex items-center space-x-2 px-3",
                post.isLiked && "text-red-500 hover:text-red-600"
              )}
            >
              <Heart className={cn("h-5 w-5", post.isLiked && "fill-current")} />
              <span className="text-sm font-medium">{post.like_count}</span>
            </Button>

            <Button
              variant="ghost"
              size="sm"
              onClick={handleComment}
              className="flex items-center space-x-2 px-3"
            >
              <MessageCircle className="h-5 w-5" />
              <span className="text-sm font-medium">{post.comment_count}</span>
            </Button>
          </div>

          <Button
            variant="ghost"
            size="sm"
            onClick={handleShare}
            className="flex items-center space-x-2 px-3"
          >
            <Share2 className="h-5 w-5" />
            <span className="text-sm">Share</span>
          </Button>
        </div>
      </CardFooter>
    </Card>
  )
}