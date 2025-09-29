import { notFound } from 'next/navigation'
import Image from 'next/image'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { CalendarDays, Clock, ArrowLeft, CreditCard as Edit } from 'lucide-react'
import { ArticleContent } from '@/components/articles/article-content'

export async function generateStaticParams() {
  return [
    { slug: 'evolution-of-meme-culture' },
  ]
}

// Mock data - in real app this would come from database
const mockArticles: Record<string, any> = {
  'evolution-of-meme-culture': {
    id: '1',
    title: 'The Evolution of Meme Culture: From Ancient Greece to TikTok',
    slug: 'evolution-of-meme-culture',
    cover_image_url: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=1200',
    content: `# The Evolution of Meme Culture: From Ancient Greece to TikTok

Memes have been around much longer than the internet. In fact, the concept of ideas spreading from person to person has been a fundamental part of human culture since the dawn of civilization.

## What is a Meme?

The term "meme" was first coined by evolutionary biologist Richard Dawkins in his 1976 book "The Selfish Gene." He described memes as units of cultural transmission, analogous to genes in biological evolution.

> "A meme is an idea, behavior, or style that spreads by means of imitation from person to person within a culture and often carries symbolic meaning."

## Ancient Origins

Long before the internet, humans were creating and sharing what we would now recognize as memes:

- **Ancient Greek Graffiti**: Archaeological evidence shows that ancient Greeks wrote humorous messages and drew crude pictures on walls
- **Medieval Manuscripts**: Monks often drew funny doodles in the margins of religious texts
- **Political Cartoons**: These have been used for centuries to comment on current events

## The Internet Revolution

The internet didn't create memes, but it certainly revolutionized how they spread:

### Early Internet (1990s-2000s)
- Email forwards
- Forum signatures
- Flash animations

### Social Media Era (2000s-2010s)
- Facebook posts
- Twitter hashtags
- YouTube videos

### Modern Meme Culture (2010s-Present)
- Instagram stories
- TikTok videos
- Discord reactions

## The Psychology of Memes

Why do memes resonate so strongly with us?

1. **Relatability**: The best memes capture universal human experiences
2. **Humor**: Laughter is a powerful social bonding mechanism
3. **Identity**: Memes help us express who we are and what we believe
4. **Community**: Sharing memes creates a sense of belonging

## Memes as Cultural Commentary

Modern memes often serve as:
- Social critique
- Political commentary
- Generational markers
- Coping mechanisms

## The Future of Memes

As technology continues to evolve, so too will meme culture. We're already seeing:
- AI-generated memes
- VR/AR meme experiences
- Blockchain-based meme ownership (NFTs)

## Conclusion

From ancient cave paintings to TikTok dances, the human desire to share ideas through humor and imagery remains constant. Memes are not just entertainment—they're a fundamental form of human expression and cultural evolution.

*What's your favorite meme format? How do you think meme culture will evolve next?*`,
    published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    author: {
      name: 'Dr. Meme Scholar',
      image: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200',
    }
  }
}

export default function ArticlePage({ params }: { params: { slug: string } }) {
  const article = mockArticles[params.slug]

  if (!article) {
    notFound()
  }

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
    <div className="max-w-4xl mx-auto px-4 py-6">
      {/* Back button */}
      <div className="mb-8">
        <Button variant="ghost" asChild>
          <Link href="/articles" className="flex items-center space-x-2">
            <ArrowLeft className="h-4 w-4" />
            <span>Back to Articles</span>
          </Link>
        </Button>
      </div>

      <article className="space-y-8">
        {/* Header */}
        <header className="space-y-6">
          {/* Cover Image */}
          <div className="relative aspect-[2/1] overflow-hidden rounded-lg">
            <Image
              src={article.cover_image_url}
              alt={article.title}
              fill
              className="object-cover"
              priority
            />
          </div>

          <div className="space-y-4">
            <h1 className="text-4xl font-bold leading-tight">
              {article.title}
            </h1>

            {/* Author and metadata */}
            <div className="flex items-center justify-between flex-wrap gap-4">
              <div className="flex items-center space-x-4">
                <Avatar className="h-12 w-12">
                  <AvatarImage src={article.author.image} alt={article.author.name} />
                  <AvatarFallback>
                    {article.author.name.charAt(0)}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-semibold">{article.author.name}</p>
                  <div className="flex items-center space-x-4 text-sm text-muted-foreground">
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
              </div>

              <div className="flex items-center space-x-2">
                <Badge variant="secondary">Published</Badge>
                <Button variant="outline" size="sm">
                  <Edit className="h-4 w-4 mr-2" />
                  Edit
                </Button>
              </div>
            </div>
          </div>
        </header>

        {/* Content */}
        <ArticleContent content={article.content} />

        {/* Footer */}
        <footer className="pt-8 border-t">
          <div className="flex items-center justify-between">
            <div className="text-sm text-muted-foreground">
              Last updated: {formatDate(article.updated_at)}
            </div>
            <Button variant="outline" asChild>
              <Link href="/articles">
                More Articles
              </Link>
            </Button>
          </div>
        </footer>
      </article>
    </div>
  )
}