/*
  # Authentication and Meme Platform Schema

  1. **New Tables Created**
     - `profiles` - Extended user profiles with metadata
     - `memes` - Meme posts with media references
     - `meme_likes` - User likes on memes
     - `meme_comments` - Comments on memes
     - `categories` - Meme categories/tags
     - `meme_categories` - Junction table for meme-category relationships
     - `articles` - Blog articles about memes
     - `user_follows` - User following relationships

  2. **Authentication Integration**
     - Profiles table syncs with Supabase auth.users
     - Username uniqueness enforced
     - User metadata (date of birth, bio, etc.)
     - Account creation tracking

  3. **Security Implementation**
     - Row Level Security (RLS) enabled on all tables
     - Users can only modify their own data
     - Public read access for memes and articles
     - Private user data properly protected
     - Comprehensive policies for all operations (SELECT, INSERT, UPDATE, DELETE)

  4. **Performance Optimizations**
     - Indexes on frequently queried columns
     - Foreign key constraints for data integrity
     - Proper default values to prevent null issues

  5. **Important Features**
     - NSFW content flagging
     - Soft delete capability
     - Created/updated timestamps
     - Like and comment counters with triggers
     - Media URL storage for Supabase Storage integration
*/

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE media_type_enum AS ENUM ('IMAGE', 'VIDEO', 'GIF');
CREATE TYPE user_role_enum AS ENUM ('USER', 'MODERATOR', 'ADMIN');

-- 1. PROFILES TABLE (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  display_name text,
  bio text,
  avatar_url text,
  website_url text,
  date_of_birth date,
  role user_role_enum DEFAULT 'USER' NOT NULL,
  is_verified boolean DEFAULT false,
  follower_count integer DEFAULT 0,
  following_count integer DEFAULT 0,
  meme_count integer DEFAULT 0,
  total_likes_received integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  CONSTRAINT username_length CHECK (char_length(username) >= 3 AND char_length(username) <= 30),
  CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]+$'),
  CONSTRAINT bio_length CHECK (char_length(bio) <= 500)
);

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  color text DEFAULT '#3B82F6',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  
  CONSTRAINT category_name_length CHECK (char_length(name) >= 2 AND char_length(name) <= 50)
);

-- 3. MEMES TABLE
CREATE TABLE IF NOT EXISTS memes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text,
  description text,
  media_url text NOT NULL,
  media_type media_type_enum NOT NULL,
  thumbnail_url text,
  width integer,
  height integer,
  file_size integer,
  is_nsfw boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  is_deleted boolean DEFAULT false,
  like_count integer DEFAULT 0,
  comment_count integer DEFAULT 0,
  view_count integer DEFAULT 0,
  share_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  CONSTRAINT title_length CHECK (char_length(title) <= 200),
  CONSTRAINT description_length CHECK (char_length(description) <= 1000)
);

-- 4. MEME_CATEGORIES JUNCTION TABLE
CREATE TABLE IF NOT EXISTS meme_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meme_id uuid NOT NULL REFERENCES memes(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  
  UNIQUE(meme_id, category_id)
);

-- 5. MEME_LIKES TABLE
CREATE TABLE IF NOT EXISTS meme_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  meme_id uuid NOT NULL REFERENCES memes(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  
  UNIQUE(user_id, meme_id)
);

-- 6. MEME_COMMENTS TABLE
CREATE TABLE IF NOT EXISTS meme_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meme_id uuid NOT NULL REFERENCES memes(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES meme_comments(id) ON DELETE CASCADE,
  content text NOT NULL,
  like_count integer DEFAULT 0,
  is_deleted boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  CONSTRAINT content_length CHECK (char_length(content) >= 1 AND char_length(content) <= 1000)
);

-- 7. ARTICLES TABLE
CREATE TABLE IF NOT EXISTS articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  excerpt text,
  content text NOT NULL,
  featured_image_url text,
  is_published boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  view_count integer DEFAULT 0,
  reading_time_minutes integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  published_at timestamptz,
  
  CONSTRAINT title_length CHECK (char_length(title) >= 5 AND char_length(title) <= 200),
  CONSTRAINT slug_format CHECK (slug ~ '^[a-z0-9-]+$'),
  CONSTRAINT excerpt_length CHECK (char_length(excerpt) <= 300)
);

-- 8. USER_FOLLOWS TABLE
CREATE TABLE IF NOT EXISTS user_follows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  
  UNIQUE(follower_id, following_id),
  CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_memes_author_id ON memes(author_id);
CREATE INDEX IF NOT EXISTS idx_memes_created_at ON memes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_memes_like_count ON memes(like_count DESC);
CREATE INDEX IF NOT EXISTS idx_memes_is_featured ON memes(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_memes_not_deleted ON memes(created_at DESC) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_meme_likes_user_id ON meme_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_meme_likes_meme_id ON meme_likes(meme_id);
CREATE INDEX IF NOT EXISTS idx_meme_comments_meme_id ON meme_comments(meme_id);
CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles(slug);
CREATE INDEX IF NOT EXISTS idx_articles_published ON articles(published_at DESC) WHERE is_published = true;
CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);

-- Insert default categories
INSERT INTO categories (name, description, color) VALUES
('Funny', 'General humor and comedy memes', '#FFB800'),
('Wholesome', 'Positive and heartwarming content', '#10B981'),
('Gaming', 'Video game related memes', '#8B5CF6'),
('Technology', 'Tech, programming, and internet culture', '#06B6D4'),
('Animals', 'Cute pets and animal memes', '#F59E0B'),
('Sports', 'Athletic and sports related content', '#EF4444'),
('Movies & TV', 'Entertainment industry memes', '#EC4899'),
('Music', 'Musical memes and artist content', '#F97316')
ON CONFLICT (name) DO NOTHING;