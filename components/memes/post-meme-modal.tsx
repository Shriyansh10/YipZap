'use client'

import { useState, useRef } from 'react'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import { Card, CardContent } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Upload, Link, Image, Video, FileText, X, TriangleAlert as AlertTriangle } from 'lucide-react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { CreateMemePostSchema, type CreateMemePost, type MediaType } from '@/lib/validations'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

interface PostMemeModalProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function PostMemeModal({ open, onOpenChange }: PostMemeModalProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [activeTab, setActiveTab] = useState('upload')
  const [uploadProgress, setUploadProgress] = useState(0)
  const [previewUrl, setPreviewUrl] = useState<string>('')
  const fileInputRef = useRef<HTMLInputElement>(null)

  const form = useForm<CreateMemePost>({
    resolver: zodResolver(CreateMemePostSchema),
    defaultValues: {
      nsfw: false,
      media_type: 'IMAGE',
    },
  })

  const watchedFile = form.watch('upload')
  const watchedUrl = form.watch('media_url')

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Validate file size (20MB limit)
    const maxSize = 20 * 1024 * 1024
    if (file.size > maxSize) {
      toast.error('File size must be less than 20MB')
      return
    }

    // Determine media type
    let mediaType: MediaType = 'IMAGE'
    if (file.type.startsWith('video/')) {
      mediaType = 'VIDEO'
    } else if (file.type === 'image/gif') {
      mediaType = 'GIF'
    }

    form.setValue('upload', file)
    form.setValue('media_type', mediaType)

    // Create preview
    const url = URL.createObjectURL(file)
    setPreviewUrl(url)
  }

  const handleUrlChange = (url: string) => {
    form.setValue('media_url', url)
    if (url) {
      // Try to determine media type from URL
      if (url.includes('.mp4') || url.includes('.webm') || url.includes('.mov')) {
        form.setValue('media_type', 'VIDEO')
      } else if (url.includes('.gif')) {
        form.setValue('media_type', 'GIF')
      } else {
        form.setValue('media_type', 'IMAGE')
      }
      setPreviewUrl(url)
    } else {
      setPreviewUrl('')
    }
  }

  const onSubmit = async (data: CreateMemePost) => {
    setIsLoading(true)

    try {
      // In a real app, this would:
      // 1. Upload file to Supabase Storage if using upload
      // 2. Create meme post record in database
      // 3. Handle errors appropriately

      // Simulate upload progress
      if (data.upload) {
        for (let i = 0; i <= 100; i += 10) {
          setUploadProgress(i)
          await new Promise(resolve => setTimeout(resolve, 100))
        }
      }

      toast.success('Meme posted successfully!')
      onOpenChange(false)

      // Reset form
      form.reset()
      setPreviewUrl('')
      setUploadProgress(0)

    } catch (error) {
      toast.error('Failed to post meme. Please try again.')
      console.error('Error posting meme:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const clearPreview = () => {
    setPreviewUrl('')
    form.setValue('upload', undefined)
    form.setValue('media_url', '')
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const MediaPreview = ({ url, type }: { url: string; type: MediaType }) => {
    if (!url) return null

    return (
      <div className="relative mt-4">
        <Button
          variant="outline"
          size="sm"
          className="absolute top-2 right-2 z-10 h-8 w-8 p-0"
          onClick={clearPreview}
        >
          <X className="h-4 w-4" />
        </Button>

        <Card>
          <CardContent className="p-4">
            {type === 'VIDEO' ? (
              <video
                src={url}
                controls
                className="w-full max-h-64 object-contain rounded"
              />
            ) : (
              <img
                src={url}
                alt="Preview"
                className="w-full max-h-64 object-contain rounded"
                onError={() => {
                  toast.error('Unable to load image preview')
                  setPreviewUrl('')
                }}
              />
            )}
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Post a Meme</DialogTitle>
          <DialogDescription>
            Share your meme with the community. Choose to upload a file or paste a URL.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="upload" className="flex items-center space-x-2">
                <Upload className="h-4 w-4" />
                <span>Upload</span>
              </TabsTrigger>
              <TabsTrigger value="url" className="flex items-center space-x-2">
                <Link className="h-4 w-4" />
                <span>URL</span>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="upload" className="space-y-4">
              <div className="space-y-2">
                <Label>Media File</Label>
                <div
                  className={cn(
                    "border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors",
                    "hover:border-primary/50 hover:bg-primary/5",
                    "focus-within:border-primary focus-within:bg-primary/5"
                  )}
                  onClick={() => fileInputRef.current?.click()}
                >
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*,video/*,.gif"
                    className="hidden"
                    onChange={handleFileSelect}
                  />
                  <div className="space-y-2">
                    <Upload className="h-12 w-12 mx-auto text-muted-foreground" />
                    <div className="text-sm">
                      <span className="font-semibold">Click to upload</span> or drag and drop
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Images, GIFs, or videos up to 20MB
                    </p>
                  </div>
                </div>
              </div>

              {watchedFile && (
                <MediaPreview
                  url={previewUrl}
                  type={form.getValues('media_type')}
                />
              )}

              {isLoading && uploadProgress > 0 && (
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Uploading...</span>
                    <span>{uploadProgress}%</span>
                  </div>
                  <div className="w-full bg-secondary rounded-full h-2">
                    <div
                      className="bg-primary h-2 rounded-full transition-all duration-300"
                      style={{ width: `${uploadProgress}%` }}
                    />
                  </div>
                </div>
              )}
            </TabsContent>

            <TabsContent value="url" className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="media-url">Media URL</Label>
                <Input
                  id="media-url"
                  type="url"
                  placeholder="https://example.com/meme.jpg"
                  value={watchedUrl || ''}
                  onChange={(e) => handleUrlChange(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  Direct link to an image, GIF, or video
                </p>
              </div>

              {watchedUrl && (
                <MediaPreview
                  url={previewUrl}
                  type={form.getValues('media_type')}
                />
              )}
            </TabsContent>
          </Tabs>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="title">Title (optional)</Label>
              <Textarea
                id="title"
                placeholder="Add a funny title or caption..."
                className="resize-none"
                rows={2}
                maxLength={200}
                {...form.register('title')}
              />
              {form.formState.errors.title && (
                <p className="text-sm text-red-500">
                  {form.formState.errors.title.message}
                </p>
              )}
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <Switch
                  id="nsfw"
                  checked={form.watch('nsfw')}
                  onCheckedChange={(checked) => form.setValue('nsfw', checked)}
                />
                <Label htmlFor="nsfw" className="flex items-center space-x-2 text-sm">
                  <AlertTriangle className="h-4 w-4 text-orange-500" />
                  <span>Mark as NSFW</span>
                </Label>
              </div>

              <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                <Select
                  value={form.watch('media_type')}
                  onValueChange={(value: MediaType) => form.setValue('media_type', value)}
                >
                  <SelectTrigger className="w-24 h-8">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="IMAGE">
                      <div className="flex items-center space-x-2">
                        <Image className="h-4 w-4" />
                        <span>Image</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="GIF">
                      <div className="flex items-center space-x-2">
                        <FileText className="h-4 w-4" />
                        <span>GIF</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="VIDEO">
                      <div className="flex items-center space-x-2">
                        <Video className="h-4 w-4" />
                        <span>Video</span>
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          <div className="flex justify-end space-x-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              disabled={isLoading}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={isLoading || (!watchedFile && !watchedUrl)}
            >
              {isLoading ? 'Posting...' : 'Post Meme'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}