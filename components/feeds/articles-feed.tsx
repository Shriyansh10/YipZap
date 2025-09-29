'use client'

import { useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { CalendarDays, Clock, User, CirclePlus as PlusCircle } from 'lucide-react'
import { useAuth } from '@/hooks/use-auth'

const mockArticles = [
  {
    id: '1',
    title: 'The Evolution of Meme Culture: From Ancient Greece to TikTok',
    slug: 'evolution-of-meme-culture',
    cover_image_url: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=800',
    content: 'Memes have been around much longer than the internet...',
    published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    author: {
      name: 'Dr. Meme Scholar',
      image: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200',
    }
  },
  {
    id: '2',
    title: 'Understanding Internet Humor: A Psychological Perspective',
    slug: 'understanding-internet-humor',
    cover_image_url: 'https://images.pexels.com/photos/4439901/pexels-photo-4439901.jpeg?auto=compress&cs=tinysrgb&w=800',
    content: 'What makes something funny online? Let\'s dive deep...',
    published: true,
    created_at: new Date(Date.now() - 86400000).toISOString(),
    updated_at: new Date(Date.now() - 86400000).toISOString(),
    author: {
      name: 'Prof. Humor Studies',
      image: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
    }
  },
  {
    id: '3',
    title: 'The Business of Memes: How Viral Content Shapes Marketing',
    slug: 'business-of-memes',
    cover_image_url: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800',
    content: 'Brands are leveraging meme culture to connect with audiences...',
    published: true,
    created_at: new Date(Date.now() - 172800000).toISOString(),
    updated_at: new Date(Date.now() - 172800000).toISOString(),
    author: {
      name: 'Marketing Maven',
      image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=200',
    }
  }
]

export function ArticlesFeed() {
  const { user } = useAuth()
  const [isLoading, setIsLoading] = useState(false)

  const isAdmin = user?.role === 'ADMIN'

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const estimateReadTime = (content: string) => {
    const wordsPerMinute = 200
    const wordCount = content.split(' ').length
    return Math.ceil(wordCount / wordsPerMinute)
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-6 space-y-8">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="space-y-2">
          <h1 className="text-3xl font-bold">Articles</h1>
          <p className="text-muted-foreground">
            Deep dives into meme culture, internet trends, and digital humor
          </p>
        </div>

        {isAdmin && (
          <Button asChild>
            <Link href="/admin/articles/new" className="flex items-center space-x-2">
              <PlusCircle className="h-4 w-4" />
              <span>New Article</span>
            </Link>
          </Button>
        )}
      </div>

      {/* Content */}
      {isLoading ? (
        <div className="grid gap-6 md:grid-cols-2">
          {[1, 2, 3, 4].map((i) => (
            <Card key={i} className="overflow-hidden">
              <CardHeader className="p-0">
                <Skeleton className="h-48 w-full" />
              </CardHeader>
              <CardContent className="p-6 space-y-4">
                <Skeleton className="h-6 w-3/4" />
                <div className="flex items-center space-x-4">
                  <Skeleton className="h-4 w-8 rounded-full" />
                  <Skeleton className="h-4 w-20" />
                  <Skeleton className="h-4 w-16" />
                </div>
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-2/3" />
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-2">
          {mockArticles.map((article) => (
            <Card
              key={article.id}
              className="overflow-hidden hover:shadow-lg transition-shadow duration-200"
            >
              <CardHeader className="p-0">
                <Link href={`/articles/${article.slug}`}>
                  <div className="relative aspect-video">
                    <Image
                      src={article.cover_image_url}
                      alt={article.title}
                      fill
                      className="object-cover transition-transform duration-200 hover:scale-105"
                    />
                  </div>
                </Link>
              </CardHeader>

              <CardContent className="p-6 space-y-4">
                <div className="space-y-2">
                  <Link
                    href={`/articles/${article.slug}`}
                    className="hover:text-blue-600 transition-colors"
                  >
                    <h2 className="text-xl font-semibold line-clamp-2">
                      {article.title}
                    </h2>
                  </Link>

                  <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                    <div className="flex items-center space-x-1">
                      <User className="h-4 w-4" />
                      <span>{article.author.name}</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <CalendarDays className="h-4 w-4" />
                      <span>{formatDate(article.created_at)}</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Clock className="h-4 w-4" />
                      <span>{estimateReadTime(article.content)} min read</span>
                    </div>
                  </div>
                </div>

                <p className="text-muted-foreground line-clamp-3">
                  {article.content.substring(0, 150)}...
                </p>

                <div className="flex items-center justify-between">
                  <Badge variant="secondary">Published</Badge>
                  <Link
                    href={`/articles/${article.slug}`}
                    className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                  >
                    Read More →
                  </Link>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Empty State */}
      {!isLoading && mockArticles.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">📰</div>
          <h3 className="text-lg font-semibold mb-2">No articles yet</h3>
          <p className="text-muted-foreground mb-4">
            Stay tuned for insightful articles about meme culture and internet trends!
          </p>
          {isAdmin && (
            <Button asChild>
              <Link href="/admin/articles/new">
                Write the First Article
              </Link>
            </Button>
          )}
        </div>
      )}

      {/* Load More */}
      {!isLoading && mockArticles.length > 0 && (
        <div className="flex justify-center pt-8">
          <Button variant="outline" size="lg">
            Load More Articles
          </Button>
        </div>
      )}
    </div>
  )
}