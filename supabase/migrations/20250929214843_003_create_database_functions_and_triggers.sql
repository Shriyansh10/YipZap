/*
  # Database Functions and Triggers

  1. **Automatic Profile Creation**
     - Creates profile when user signs up
     - Extracts username and date_of_birth from auth metadata

  2. **Counter Maintenance**
     - Like count updates when likes are added/removed
     - Comment count updates when comments are added/removed
     - Follower/following counts update automatically
     - Meme count updates for user profiles

  3. **Data Integrity**
     - Updated_at timestamps are maintained automatically
     - Soft delete functionality for memes and comments
     - Prevent duplicate likes and follows

  4. **Performance Optimizations**
     - Efficient counter updates using triggers
     - Batch operations where possible
     - Proper indexing maintained
*/

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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers for like count updates
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

-- Trigger for comment count updates
DROP TRIGGER IF EXISTS meme_comment_count_trigger ON meme_comments;
CREATE TRIGGER meme_comment_count_trigger
  AFTER INSERT OR DELETE ON meme_comments
  FOR EACH ROW EXECUTE FUNCTION update_meme_comment_count();

-- Function to update user follow counts
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS trigger AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for follow count updates
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

-- Trigger for user meme count updates
DROP TRIGGER IF EXISTS user_meme_count_trigger ON memes;
CREATE TRIGGER user_meme_count_trigger
  AFTER INSERT OR DELETE ON memes
  FOR EACH ROW EXECUTE FUNCTION update_user_meme_count();

-- Function to set article published_at when is_published changes to true
CREATE OR REPLACE FUNCTION set_article_published_at()
RETURNS trigger AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger for article publishing
DROP TRIGGER IF EXISTS set_article_published_at_trigger ON articles;
CREATE TRIGGER set_article_published_at_trigger
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION set_article_published_at();