CREATE OR REPLACE FUNCTION search_products(search_term text)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  price numeric,
  category_id uuid,
  images text[],
  sizes text[],
  colors text[],
  stock_qty integer,
  is_featured boolean,
  is_active boolean,
  created_at timestamptz
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    id, name, description, price, category_id,
    images, sizes, colors, stock_qty,
    is_featured, is_active, created_at
  FROM products
  WHERE
    is_active = true
    AND (
      name ILIKE '%' || search_term || '%'
      OR description ILIKE '%' || search_term || '%'
    )
  ORDER BY
    CASE
      WHEN name ILIKE '%' || search_term || '%' THEN 1        -- name match first
      WHEN description ILIKE '%' || search_term || '%' THEN 2 -- description match second
    END,
    is_featured DESC,  -- featured items bubble up within each group
    created_at DESC;   -- newest within that
$$;
