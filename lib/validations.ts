import { z } from 'zod'

export const MediaTypeEnum = z.enum(['IMAGE', 'VIDEO', 'GIF'])
export const RoleEnum = z.enum(['USER', 'ADMIN'])

export const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().nullable(),
  image: z.string().nullable(),
  role: RoleEnum.default('USER'),
  created_at: z.string(),
})

export const ProfileSchema = z.object({
  id: z.string(),
  user_id: z.string(),
  username: z.string().min(3).max(30).regex(/^[a-zA-Z0-9_]+$/, {
    message: 'Username can only contain letters, numbers, and underscores'
  }),
  date_of_birth: z.string().refine((date) => {
    const birthDate = new Date(date)
    const today = new Date()
    const age = today.getFullYear() - birthDate.getFullYear()
    const monthDiff = today.getMonth() - birthDate.getMonth()

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      return age - 1 >= 13
    }
    return age >= 13
  }, {
    message: 'You must be at least 13 years old'
  }),
  created_at: z.string(),
})

export const MemePostSchema = z.object({
  id: z.string(),
  author_id: z.string(),
  title: z.string().max(200).nullable(),
  media_type: MediaTypeEnum,
  media_url: z.string().url(),
  storage_path: z.string().nullable(),
  nsfw: z.boolean().default(false),
  like_count: z.number().default(0),
  comment_count: z.number().default(0),
  created_at: z.string(),
  updated_at: z.string(),
})

export const CreateMemePostSchema = z.object({
  title: z.string().max(200).optional(),
  media_type: MediaTypeEnum,
  media_url: z.string().url().optional(),
  upload: z.instanceof(File).optional(),
  nsfw: z.boolean().default(false),
}).refine((data) => data.media_url || data.upload, {
  message: 'Either media URL or file upload is required'
})

export const MemeCommentSchema = z.object({
  id: z.string(),
  user_id: z.string(),
  post_id: z.string(),
  body: z.string().min(1).max(1000),
  created_at: z.string(),
})

export const CreateCommentSchema = z.object({
  post_id: z.string(),
  body: z.string().min(1).max(1000),
})

export const ArticleSchema = z.object({
  id: z.string(),
  author_id: z.string(),
  title: z.string().min(1).max(200),
  slug: z.string().min(1).max(200),
  cover_image_url: z.string().url().nullable(),
  content: z.string().min(1),
  published: z.boolean().default(false),
  created_at: z.string(),
  updated_at: z.string(),
})

export const CreateArticleSchema = z.object({
  title: z.string().min(1).max(200),
  slug: z.string().min(1).max(200).regex(/^[a-z0-9-]+$/, {
    message: 'Slug can only contain lowercase letters, numbers, and hyphens'
  }),
  cover_image_url: z.string().url().optional(),
  content: z.string().min(1),
  published: z.boolean().default(false),
})

export const UpdateArticleSchema = CreateArticleSchema.partial()

export const AuthSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export const RegisterSchema = AuthSchema.extend({
  name: z.string().optional(),
})

export type MediaType = z.infer<typeof MediaTypeEnum>
export type Role = z.infer<typeof RoleEnum>
export type User = z.infer<typeof UserSchema>
export type Profile = z.infer<typeof ProfileSchema>
export type MemePost = z.infer<typeof MemePostSchema>
export type CreateMemePost = z.infer<typeof CreateMemePostSchema>
export type MemeComment = z.infer<typeof MemeCommentSchema>
export type CreateComment = z.infer<typeof CreateCommentSchema>
export type Article = z.infer<typeof ArticleSchema>
export type CreateArticle = z.infer<typeof CreateArticleSchema>
export type UpdateArticle = z.infer<typeof UpdateArticleSchema>
export type AuthInput = z.infer<typeof AuthSchema>
export type RegisterInput = z.infer<typeof RegisterSchema>