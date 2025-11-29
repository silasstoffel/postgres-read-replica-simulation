-- Core entities
CREATE TABLE public.users (
  id            BIGSERIAL PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.products (
  id            BIGSERIAL PRIMARY KEY,
  sku           TEXT UNIQUE NOT NULL,
  name          TEXT NOT NULL,
  price_cents   INT NOT NULL CHECK (price_cents >= 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.orders (
  id            BIGSERIAL PRIMARY KEY,
  user_id       BIGINT NOT NULL REFERENCES public.users(id),
  status        TEXT NOT NULL CHECK (status IN ('paid','pending','failed')),
  total_cents   INT NOT NULL CHECK (total_cents >= 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.order_items (
  id            BIGSERIAL PRIMARY KEY,
  order_id      BIGINT NOT NULL REFERENCES public.orders(id),
  product_id    BIGINT NOT NULL REFERENCES public.products(id),
  quantity      INT NOT NULL CHECK (quantity > 0),
  price_cents   INT NOT NULL CHECK (price_cents >= 0)
);

-- Minimal seed data
INSERT INTO public.users (email, created_at) VALUES
('a@x.com', now() - interval '80 days'),
('b@x.com', now() - interval '40 days'),
('c@x.com', now() - interval '10 days');

INSERT INTO public.products (sku, name, price_cents) VALUES
('SKU-1', 'Coffee Grinder', 4999),
('SKU-2', 'Kettle Pro', 6999),
('SKU-3', 'Espresso Beans', 1599);

-- Some orders across time windows
INSERT INTO public.orders (user_id, status, total_cents, created_at) VALUES
(1, 'paid', 4999, now() - interval '75 days'),
(1, 'paid', 8598, now() - interval '38 days'),
(2, 'paid', 1599, now() - interval '33 days'),
(2, 'failed', 6999, now() - interval '20 days'),
(3, 'paid', 8598, now() - interval '8 days'),
(3, 'paid', 1599, now() - interval '2 days');

-- Items reflecting those orders
INSERT INTO public.order_items (order_id, product_id, quantity, price_cents) VALUES
(1, 1, 1, 4999),
(2, 2, 1, 6999),
(2, 3, 1, 1599),
(3, 3, 1, 1599),
(4, 2, 1, 6999),
(5, 2, 1, 6999),
(5, 3, 1, 1599),
(6, 3, 1, 1599);