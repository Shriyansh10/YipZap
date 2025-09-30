-- ============================================
-- COMPLETE DATABASE SETUP
-- Run this entire file in Supabase SQL Editor
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
DO $$ BEGIN
  CREATE TYPE media_type_enum AS ENUM ('IMAGE', 'VIDEO', 'GIF');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE user_role_enum AS ENUM ('USER', 'MODERATOR', 'ADMIN');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ============================================
-- TABLES
-- ============================================

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

-- ============================================
-- INDEXES
-- ============================================

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

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to automatically create profile for new users
CREATE OR REPLACE FUNCTION create_profile_for_new_user()
RETURNS trigger AS $$
DECLARE
  username_value text;
  dob_value date;
BEGIN
  -- Extract username from metadata, fallback to email prefix
  username_value := COALESCE(
    NEW.raw_user_meta_data->>'username',
    split_part(NEW.email, '@', 1)
  );

  -- Ensure username is unique by appending numbers if needed
  WHILE EXISTS (SELECT 1 FROM profiles WHERE username = username_value) LOOP
    username_value := username_value || floor(random() * 1000)::text;
  END LOOP;

  -- Extract date of birth from metadata
  IF NEW.raw_user_meta_data->>'dateOfBirth' IS NOT NULL THEN
    BEGIN
      dob_value := (NEW.raw_user_meta_data->>'dateOfBirth')::date;
    EXCEPTION
      WHEN OTHERS THEN
        dob_value := NULL;
    END;
  END IF;

  -- Create the profile
  INSERT INTO profiles (
    id,
    username,
    display_name,
    date_of_birth,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    username_value,
    COALESCE(NEW.raw_user_meta_data->>'name', username_value),
    dob_value,
    now(),
    now()
  );

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't block user creation
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile for new users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_profile_for_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers to relevant tables
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_memes_updated_at ON memes;
CREATE TRIGGER update_memes_updated_at
  BEFORE UPDATE ON memes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_meme_comments_updated_at ON meme_comments;
CREATE TRIGGER update_meme_comments_updated_at
  BEFORE UPDATE ON meme_comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_articles_updated_at ON articles;
CREATE TRIGGER update_articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update meme like count
CREATE OR REPLACE FUNCTION update_meme_like_count()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE memes
    SET like_count = like_count + 1
    WHERE id = NEW.meme_id;

    UPDATE profiles
    SET total_likes_received = total_likes_received + 1
    WHERE id = (SELECT author_id FROM memes WHERE id = NEW.meme_id);

    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE memes
    SET like_count = like_count - 1
    WHERE id = OLD.meme_id;

    UPDATE profiles
    SET total_likes_received = total_likes_received - 1
    WHERE id = (SELECT author_id FROM memes WHERE id = OLD.meme_id);

    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS meme_like_count_trigger ON meme_likes;
CREATE TRIGGER meme_like_count_trigger
  AFTER INSERT OR DELETE ON meme_likes
  FOR EACH ROW EXECUTE FUNCTION update_meme_like_count();

-- Function to update meme comment count
CREATE OR REPLACE FUNCTION update_meme_comment_count()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE memes
    SET comment_count = comment_count + 1
    WHERE id = NEW.meme_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE memes
    SET comment_count = comment_count - 1
    WHERE id = OLD.meme_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS meme_comment_count_trigger ON meme_comments;
CREATE TRIGGER meme_comment_count_trigger
  AFTER INSERT OR DELETE ON meme_comments
  FOR EACH ROW EXECUTE FUNCTION update_meme_comment_count();

-- Function to update user follow counts
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE profiles
    SET following_count = following_count + 1
    WHERE id = NEW.follower_id;

    UPDATE profiles
    SET follower_count = follower_count + 1
    WHERE id = NEW.following_id;

    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE profiles
    SET following_count = following_count - 1
    WHERE id = OLD.follower_id;

    UPDATE profiles
    SET follower_count = follower_count - 1
    WHERE id = OLD.following_id;

    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS follow_count_trigger ON user_follows;
CREATE TRIGGER follow_count_trigger
  AFTER INSERT OR DELETE ON user_follows
  FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- Function to update user meme count
CREATE OR REPLACE FUNCTION update_user_meme_count()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE profiles
    SET meme_count = meme_count + 1
    WHERE id = NEW.author_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE profiles
    SET meme_count = meme_count - 1
    WHERE id = OLD.author_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS user_meme_count_trigger ON memes;
CREATE TRIGGER user_meme_count_trigger
  AFTER INSERT OR DELETE ON memes
  FOR EACH ROW EXECUTE FUNCTION update_user_meme_count();

-- Function to set article published_at when is_published changes to true
CREATE OR REPLACE FUNCTION set_article_published_at()
RETURNS trigger AS $$
BEGIN
  IF NEW.is_published = true AND (OLD.is_published IS DISTINCT FROM true) THEN
    NEW.published_at = now();
  ELSIF NEW.is_published = false THEN
    NEW.published_at = NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_article_published_at_trigger ON articles;
CREATE TRIGGER set_article_published_at_trigger
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION set_article_published_at();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE memes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Profiles policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Memes policies
DROP POLICY IF EXISTS "Memes are viewable by everyone" ON memes;
CREATE POLICY "Memes are viewable by everyone"
  ON memes FOR SELECT
  USING (NOT is_deleted);

DROP POLICY IF EXISTS "Authenticated users can create memes" ON memes;
CREATE POLICY "Authenticated users can create memes"
  ON memes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can update own memes" ON memes;
CREATE POLICY "Users can update own memes"
  ON memes FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can delete own memes" ON memes;
CREATE POLICY "Users can delete own memes"
  ON memes FOR DELETE
  TO authenticated
  USING (auth.uid() = author_id);

-- Meme likes policies
DROP POLICY IF EXISTS "Likes are viewable by everyone" ON meme_likes;
CREATE POLICY "Likes are viewable by everyone"
  ON meme_likes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can like memes" ON meme_likes;
CREATE POLICY "Authenticated users can like memes"
  ON meme_likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can remove their own likes" ON meme_likes;
CREATE POLICY "Users can remove their own likes"
  ON meme_likes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Meme comments policies
DROP POLICY IF EXISTS "Comments are viewable by everyone" ON meme_comments;
CREATE POLICY "Comments are viewable by everyone"
  ON meme_comments FOR SELECT
  USING (NOT is_deleted);

DROP POLICY IF EXISTS "Authenticated users can create comments" ON meme_comments;
CREATE POLICY "Authenticated users can create comments"
  ON meme_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can update own comments" ON meme_comments;
CREATE POLICY "Users can update own comments"
  ON meme_comments FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can delete own comments" ON meme_comments;
CREATE POLICY "Users can delete own comments"
  ON meme_comments FOR DELETE
  TO authenticated
  USING (auth.uid() = author_id);

-- Categories policies
DROP POLICY IF EXISTS "Categories are viewable by everyone" ON categories;
CREATE POLICY "Categories are viewable by everyone"
  ON categories FOR SELECT
  USING (is_active);

-- Meme categories policies
DROP POLICY IF EXISTS "Meme categories are viewable by everyone" ON meme_categories;
CREATE POLICY "Meme categories are viewable by everyone"
  ON meme_categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can categorize own memes" ON meme_categories;
CREATE POLICY "Users can categorize own memes"
  ON meme_categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id AND memes.author_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can remove categories from own memes" ON meme_categories;
CREATE POLICY "Users can remove categories from own memes"
  ON meme_categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id AND memes.author_id = auth.uid()
    )
  );

-- Articles policies
DROP POLICY IF EXISTS "Published articles are viewable by everyone" ON articles;
CREATE POLICY "Published articles are viewable by everyone"
  ON articles FOR SELECT
  USING (is_published = true);

DROP POLICY IF EXISTS "Users can view own unpublished articles" ON articles;
CREATE POLICY "Users can view own unpublished articles"
  ON articles FOR SELECT
  TO authenticated
  USING (auth.uid() = author_id);

DROP POLICY IF EXISTS "Authenticated users can create articles" ON articles;
CREATE POLICY "Authenticated users can create articles"
  ON articles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can update own articles" ON articles;
CREATE POLICY "Users can update own articles"
  ON articles FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Users can delete own articles" ON articles;
CREATE POLICY "Users can delete own articles"
  ON articles FOR DELETE
  TO authenticated
  USING (auth.uid() = author_id);

-- User follows policies
DROP POLICY IF EXISTS "Follows are viewable by everyone" ON user_follows;
CREATE POLICY "Follows are viewable by everyone"
  ON user_follows FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can follow others" ON user_follows;
CREATE POLICY "Authenticated users can follow others"
  ON user_follows FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = follower_id);

DROP POLICY IF EXISTS "Users can unfollow others" ON user_follows;
CREATE POLICY "Users can unfollow others"
  ON user_follows FOR DELETE
  TO authenticated
  USING (auth.uid() = follower_id);

-- ============================================
-- SEED DATA
-- ============================================

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