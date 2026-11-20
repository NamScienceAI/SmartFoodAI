-- Link each purchased grocery item to the single inventory batch created from it.
CREATE TABLE grocery_item_receipts (
    list_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    batch_id INTEGER NOT NULL UNIQUE REFERENCES batches(id),
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    PRIMARY KEY(list_id,product_id),
    FOREIGN KEY(list_id,product_id) REFERENCES grocery_items(list_id,product_id)
);
