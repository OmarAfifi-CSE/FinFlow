-- =============================================================================
--  SCHEMA FOR FINFLOW
-- =============================================================================
--  Run this script in your Supabase SQL Editor to prepare your database for the app.
-- =============================================================================


-- 1. CATEGORIES TABLE
-- Stores user-defined and default categories for transactions.
-- -----------------------------------------------------------------------------
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  is_default boolean NULL DEFAULT false,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  -- If a user is deleted, all their categories are deleted too.
  CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.categories IS 'Stores transaction categories like "Food", "Shopping", etc.';

-- Row Level Security (RLS) for the 'categories' table.
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Combined policy for all operations (SELECT, INSERT, UPDATE, DELETE) for authenticated users.
CREATE POLICY "Enable users to handle their data" ON public.categories
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- 2. TAGS TABLE
-- Stores user-defined tags for more specific transaction labeling.
-- -----------------------------------------------------------------------------
CREATE TABLE public.tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT tags_pkey PRIMARY KEY (id),
  -- If a user is deleted, all their tags are deleted too.
  CONSTRAINT tags_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.tags IS 'Stores user-created tags like "#Work", "#Vacation", etc.';

-- Row Level Security (RLS) for the 'tags' table.
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

-- Combined policy for all operations for authenticated users.
CREATE POLICY "Users can handle their own data" ON public.tags
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- 3. EXPENSES TABLE (Transactions)
-- Stores all income and expense records for each user.
-- -----------------------------------------------------------------------------
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  amount float8 NOT NULL,
  category_id uuid Not NULL,
  description text NULL,
  date timestamp with time zone NOT NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  tag_id uuid NULL,
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  -- If a category is deleted, all transactions linked to it are also permanently deleted.
  CONSTRAINT expenses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE,
  -- If a tag is deleted, the transaction remains but the tag link is removed (set to NULL).
  CONSTRAINT expenses_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE SET NULL,
  -- If a user is deleted, all their transactions are deleted too.
  CONSTRAINT expenses_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.expenses IS 'Stores all income and expense transactions.';
COMMENT ON COLUMN public.expenses.amount IS 'The transaction value. Positive for income, negative for expense.';

-- Row Level Security (RLS) for the 'expenses' table.
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Combined policy for all operations for authenticated users.
CREATE POLICY "Users can handle their own data" ON public.expenses
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
