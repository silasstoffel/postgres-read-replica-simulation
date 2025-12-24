CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL REFERENCES categories(id),
    name VARCHAR(150) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    status VARCHAR(30) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    product_id BIGINT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(12,2) NOT NULL
);

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);


INSERT INTO categories (name)
SELECT 'Category ' || gs
FROM generate_series(1, 20) gs;

INSERT INTO products (category_id, name, price)
SELECT
    (random() * 19 + 1)::INT,
    'Product ' || gs,
    round((random() * 500 + 10)::numeric, 2)
FROM generate_series(1, 1000) gs;


INSERT INTO orders (status, total_amount, created_at)
SELECT
    (ARRAY['PENDING','PAID','CANCELLED','SHIPPED','DELIVERED'])[
        floor(random() * 5 + 1)
    ],
    0, -- será atualizado depois
    now() - (random() * interval '5 years')
FROM generate_series(1, 200000);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
SELECT
    o.id,
    p.id,
    qty,
    p.price,
    qty * p.price
FROM orders o
JOIN LATERAL (
    SELECT
        id,
        price,
        (random() * 4 + 1)::INT AS qty
    FROM products
    ORDER BY random()
    LIMIT (random() * 4 + 1)::INT
) p ON true;


UPDATE orders o
SET total_amount = sub.total
FROM (
    SELECT
        order_id,
        SUM(total_price) AS total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.id = sub.order_id;
