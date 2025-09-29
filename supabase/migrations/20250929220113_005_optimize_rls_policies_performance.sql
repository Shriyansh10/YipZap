/*
  # Optimize RLS Policies for Better Performance

  1. **Performance Issue**
     - RLS policies were re-evaluating auth.uid() for each row
     - This causes poor performance at scale due to repeated function calls

  2. **Solution**
     - Replace `auth.uid()` with `(SELECT auth.uid())` in all policies
     - This ensures the auth function is called once and cached per query

  3. **Policies Updated**
     - All authentication-based policies across all tables
     - Maintains exact same security behavior with better performance
     - Critical for scale as user base grows

  4. **Security Maintained**
     - No changes to security logic or access control
     - Same permissions, just optimized execution
*/

-- Drop and recreate all RLS policies with optimized auth function calls

-- PROFILES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = id)
  WITH CHECK ((SELECT auth.uid()) = id);

-- MEMES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Authenticated users can create memes" ON memes;
DROP POLICY IF EXISTS "Authors can update own memes" ON memes;
DROP POLICY IF EXISTS "Authors and admins can delete memes" ON memes;

CREATE POLICY "Authenticated users can create memes"
  ON memes FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Authors can update own memes"
  ON memes FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = author_id)
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Authors and admins can delete memes"
  ON memes FOR DELETE
  TO authenticated
  USING (
    (SELECT auth.uid()) = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- CATEGORIES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Only admins can manage categories" ON categories;
DROP POLICY IF EXISTS "Only admins can update categories" ON categories;
DROP POLICY IF EXISTS "Only admins can delete categories" ON categories;

CREATE POLICY "Only admins can manage categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'ADMIN'
    )
  );

CREATE POLICY "Only admins can update categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'ADMIN'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'ADMIN'
    )
  );

CREATE POLICY "Only admins can delete categories"
  ON categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'ADMIN'
    )
  );

-- MEME_CATEGORIES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Meme authors can add categories to their memes" ON meme_categories;
DROP POLICY IF EXISTS "Meme authors can remove categories from their memes" ON meme_categories;

CREATE POLICY "Meme authors can add categories to their memes"
  ON meme_categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id
      AND memes.author_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "Meme authors can remove categories from their memes"
  ON meme_categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM memes
      WHERE memes.id = meme_id
      AND memes.author_id = (SELECT auth.uid())
    )
  );

-- MEME_LIKES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Authenticated users can like memes" ON meme_likes;
DROP POLICY IF EXISTS "Users can remove their own likes" ON meme_likes;

CREATE POLICY "Authenticated users can like memes"
  ON meme_likes FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can remove their own likes"
  ON meme_likes FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- MEME_COMMENTS TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Authenticated users can create comments" ON meme_comments;
DROP POLICY IF EXISTS "Comment authors can update their comments" ON meme_comments;
DROP POLICY IF EXISTS "Authors and admins can delete comments" ON meme_comments;

CREATE POLICY "Authenticated users can create comments"
  ON meme_comments FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Comment authors can update their comments"
  ON meme_comments FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = author_id)
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Authors and admins can delete comments"
  ON meme_comments FOR DELETE
  TO authenticated
  USING (
    (SELECT auth.uid()) = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- ARTICLES TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Authenticated users can create articles" ON articles;
DROP POLICY IF EXISTS "Authors can update own articles" ON articles;
DROP POLICY IF EXISTS "Authors and admins can delete articles" ON articles;

CREATE POLICY "Authenticated users can create articles"
  ON articles FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Authors can update own articles"
  ON articles FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = author_id)
  WITH CHECK ((SELECT auth.uid()) = author_id);

CREATE POLICY "Authors and admins can delete articles"
  ON articles FOR DELETE
  TO authenticated
  USING (
    (SELECT auth.uid()) = author_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role IN ('ADMIN', 'MODERATOR')
    )
  );

-- USER_FOLLOWS TABLE POLICIES (Optimized)
DROP POLICY IF EXISTS "Users can follow others" ON user_follows;
DROP POLICY IF EXISTS "Users can unfollow others" ON user_follows;

CREATE POLICY "Users can follow others"
  ON user_follows FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = follower_id);

CREATE POLICY "Users can unfollow others"
  ON user_follows FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = follower_id);