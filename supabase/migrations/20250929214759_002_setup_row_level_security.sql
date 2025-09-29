/*
  # Row Level Security Setup

  1. **Security Model**
     - All tables have RLS enabled
     - Users can only modify their own data
     - Public read access for memes and articles
     - Private user data is properly protected

  2. **Policy Structure**
     - Separate policies for SELECT, INSERT, UPDATE, DELETE
     - Authenticated users for write operations
     - Public access for read operations where appropriate
     - Admin override capabilities for moderation

  3. **Key Security Features**
     - Users cannot impersonate others
     - Profile data is protected but publicly readable
     - Memes are public but only editable by authors
     - Comments and likes require authentication
     - Follow relationships are properly secured

  4. **Authentication Integration**
     - Uses auth.uid() for user identification
     - Proper role-based access control
     - Admin users have elevated permissions
*/

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE memes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meme_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- PROFILES TABLE POLICIES
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users cannot delete profiles"
  ON profiles FOR DELETE
  TO authenticated
  USING (false);

-- CATEGORIES TABLE POLICIES
CREATE POLICY "Categories are viewable by everyone"
  ON categories FOR SELECT
  USING (is_active = true);

CREATE POLICY "Only admins can manage categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'ADMIN'
    )
  );

CREATE POLICY "Only admins can update categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'ADMIN'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'ADMIN'
    )
  );

CREATE POLICY "Only admins can delete categories"
  ON categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'ADMIN'
    )
  );

-- MEMES TABLE POLICIES
CREATE POLICY "Published memes are viewable by everyone"
  ON memes FOR SELECT
  USING (is_deleted = false);

CREATE POLICY "Authenticated users can create memes"
  ON memes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update own memes"
  ON memes FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors and admins can delete memes"
  ON memes FOR DELETE
  TO authenticated
  USING (
    auth.uid() = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- MEME_CATEGORIES TABLE POLICIES
CREATE POLICY "Meme categories are viewable by everyone"
  ON meme_categories FOR SELECT
  USING (true);

CREATE POLICY "Meme authors can add categories to their memes"
  ON meme_categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id
      AND memes.author_id = auth.uid()
    )
  );

CREATE POLICY "Meme authors can remove categories from their memes"
  ON meme_categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id
      AND memes.author_id = auth.uid()
    )
  );

-- MEME_LIKES TABLE POLICIES
CREATE POLICY "Meme likes are viewable by everyone"
  ON meme_likes FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can like memes"
  ON meme_likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their own likes"
  ON meme_likes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- MEME_COMMENTS TABLE POLICIES
CREATE POLICY "Comments are viewable by everyone"
  ON meme_comments FOR SELECT
  USING (is_deleted = false);

CREATE POLICY "Authenticated users can create comments"
  ON meme_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Comment authors can update their comments"
  ON meme_comments FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors and admins can delete comments"
  ON meme_comments FOR DELETE
  TO authenticated
  USING (
    auth.uid() = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- ARTICLES TABLE POLICIES
CREATE POLICY "Published articles are viewable by everyone"
  ON articles FOR SELECT
  USING (is_published = true);

CREATE POLICY "Authenticated users can create articles"
  ON articles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update own articles"
  ON articles FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors and admins can delete articles"
  ON articles FOR DELETE
  TO authenticated
  USING (
    auth.uid() = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- USER_FOLLOWS TABLE POLICIES
CREATE POLICY "Follow relationships are viewable by everyone"
  ON user_follows FOR SELECT
  USING (true);

CREATE POLICY "Users can follow others"
  ON user_follows FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow others"
  ON user_follows FOR DELETE
  TO authenticated
  USING (auth.uid() = follower_id);