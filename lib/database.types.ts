export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          name: string | null
          image: string | null
          role: 'USER' | 'ADMIN'
          created_at: string
        }
        Insert: {
          id?: string
          email: string
          name?: string | null
          image?: string | null
          role?: 'USER' | 'ADMIN'
          created_at?: string
        }
        Update: {
          id?: string
          email?: string
          name?: string | null
          image?: string | null
          role?: 'USER' | 'ADMIN'
          created_at?: string
        }
      }
      profiles: {
        Row: {
          id: string
          user_id: string
          username: string
          date_of_birth: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          username: string
          date_of_birth: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          username?: string
          date_of_birth?: string
          created_at?: string
        }
      }
      meme_posts: {
        Row: {
          id: string
          author_id: string
          title: string | null
          media_type: 'IMAGE' | 'VIDEO' | 'GIF'
          media_url: string
          storage_path: string | null
          nsfw: boolean
          like_count: number
          comment_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          author_id: string
          title?: string | null
          media_type: 'IMAGE' | 'VIDEO' | 'GIF'
          media_url: string
          storage_path?: string | null
          nsfw?: boolean
          like_count?: number
          comment_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          author_id?: string
          title?: string | null
          media_type?: 'IMAGE' | 'VIDEO' | 'GIF'
          media_url?: string
          storage_path?: string | null
          nsfw?: boolean
          like_count?: number
          comment_count?: number
          created_at?: string
          updated_at?: string
        }
      }
      meme_likes: {
        Row: {
          id: string
          user_id: string
          post_id: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string
          created_at?: string
        }
      }
      meme_comments: {
        Row: {
          id: string
          user_id: string
          post_id: string
          body: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id: string
          body: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string
          body?: string
          created_at?: string
        }
      }
      articles: {
        Row: {
          id: string
          author_id: string
          title: string
          slug: string
          cover_image_url: string | null
          content: string
          published: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          author_id: string
          title: string
          slug: string
          cover_image_url?: string | null
          content: string
          published?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          author_id?: string
          title?: string
          slug?: string
          cover_image_url?: string | null
          content?: string
          published?: boolean
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}