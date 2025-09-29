/*
  # Fix Function Search Path Security Issues

  1. **Security Issue**
     - Functions had mutable search_path which can be exploited
     - Attackers could potentially redirect function calls to malicious objects

  2. **Solution**
     - Set search_path to a secure, immutable value for all functions
     - Use 'pg_catalog, public' as the secure search path
     - Add SECURITY DEFINER where appropriate for elevation

  3. **Functions Secured**
     - create_profile_for_new_user
     - update_updated_at_column
     - update_meme_like_count
     - update_meme_comment_count
     - update_follow_counts
     - update_user_meme_count
     - set_article_published_at

  4. **Security Benefits**
     - Prevents search path injection attacks
     - Ensures functions use intended schemas
     - Maintains function integrity and predictability
*/

-- Recreate all functions with secure search paths

-- Function to automatically create profile for new users
CREATE OR REPLACE FUNCTION create_profile_for_new_user()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
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
    dob_value := (NEW.raw_user_meta_data->>'dateOfBirth')::date;
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
END;
$$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger 
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Function to update meme like count
CREATE OR REPLACE FUNCTION update_meme_like_count()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE memes
    SET like_count = like_count + 1
    WHERE id = NEW.meme_id;
    
    -- Update user's total likes received
    UPDATE profiles
    SET total_likes_received = total_likes_received + 1
    WHERE id = (SELECT author_id FROM memes WHERE id = NEW.meme_id);
    
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE memes
    SET like_count = like_count - 1
    WHERE id = OLD.meme_id;
    
    -- Update user's total likes received
    UPDATE profiles
    SET total_likes_received = total_likes_received - 1
    WHERE id = (SELECT author_id FROM memes WHERE id = OLD.meme_id);
    
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

-- Function to update meme comment count
CREATE OR REPLACE FUNCTION update_meme_comment_count()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
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
$$;

-- Function to update user follow counts
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Increase following count for follower
    UPDATE profiles
    SET following_count = following_count + 1
    WHERE id = NEW.follower_id;
    
    -- Increase follower count for followed user
    UPDATE profiles
    SET follower_count = follower_count + 1
    WHERE id = NEW.following_id;
    
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    -- Decrease following count for follower
    UPDATE profiles
    SET following_count = following_count - 1
    WHERE id = OLD.follower_id;
    
    -- Decrease follower count for followed user
    UPDATE profiles
    SET follower_count = follower_count - 1
    WHERE id = OLD.following_id;
    
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

-- Function to update user meme count
CREATE OR REPLACE FUNCTION update_user_meme_count()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
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
$$;

-- Function to set article published_at when is_published changes to true
CREATE OR REPLACE FUNCTION set_article_published_at()
RETURNS trigger 
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
  -- If is_published is being set to true and wasn't true before
  IF NEW.is_published = true AND (OLD.is_published IS DISTINCT FROM true) THEN
    NEW.published_at = now();
  -- If is_published is being set to false, clear published_at
  ELSIF NEW.is_published = false THEN
    NEW.published_at = NULL;
  END IF;
  
  RETURN NEW;
END;
$$;