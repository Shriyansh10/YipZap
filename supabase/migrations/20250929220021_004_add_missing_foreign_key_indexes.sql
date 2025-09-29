/*
  # Add Missing Foreign Key Indexes

  1. **Performance Optimization**
     - Add indexes for all foreign key columns that were missing them
     - These indexes are critical for join performance and referential integrity checks

  2. **Indexes Added**
     - `idx_articles_author_id` for articles.author_id
     - `idx_meme_categories_category_id` for meme_categories.category_id  
     - `idx_meme_comments_author_id` for meme_comments.author_id
     - `idx_meme_comments_parent_id` for meme_comments.parent_id

  3. **Performance Impact**
     - Dramatically improves JOIN performance
     - Speeds up foreign key constraint validation
     - Essential for queries filtering by author or parent relationships
     - Prevents table scans on large datasets
*/

-- Add missing foreign key indexes for optimal query performance

-- Index for articles.author_id (for author-based queries and joins)
CREATE INDEX IF NOT EXISTS idx_articles_author_id 
ON articles(author_id);

-- Index for meme_categories.category_id (for category-based queries)
CREATE INDEX IF NOT EXISTS idx_meme_categories_category_id 
ON meme_categories(category_id);

-- Index for meme_comments.author_id (for author-based comment queries)
CREATE INDEX IF NOT EXISTS idx_meme_comments_author_id 
ON meme_comments(author_id);

-- Index for meme_comments.parent_id (for threaded comment queries)
CREATE INDEX IF NOT EXISTS idx_meme_comments_parent_id 
ON meme_comments(parent_id) 
WHERE parent_id IS NOT NULL;