ALTER TABLE pipture_userpurchaseditems
  ADD COLUMN Unverified BOOLEAN NOT NULL DEFAULT 0
  AFTER ItemCost;

ALTER TABLE pipture_userpurchaseditems
  ADD COLUMN AppleTransactionId VARCHAR(36) NULL
  AFTER Unverified;

ALTER TABLE pipture_userpurchaseditems
  ADD COLUMN ReceiptData TEXT NULL
  AFTER AppleTransactionId;

CREATE TABLE pipture_purchasers (
  PurchaserId integer NOT NULL PRIMARY KEY AUTO_INCREMENT
);

ALTER TABLE pipture_pipusers
  ADD COLUMN Purchaser_id INT
  AFTER Balance;
  
ALTER TABLE pipture_pipusers
  ADD CONSTRAINT fk_users_purchasers
  FOREIGN KEY (Purchaser_id)
  REFERENCES pipture_purchasers(PurchaserId)
  ON DELETE SET NULL;

DROP INDEX "pipture_userpurchaseditems_f4f89c" ON "pipture_userpurchaseditems";

ALTER TABLE pipture_userpurchaseditems
  DROP COLUMN UserId_id;

ALTER TABLE pipture_userpurchaseditems
  ADD COLUMN Purchaser_id INT
  AFTER receiptData;

CREATE INDEX "pipture_userpurchaseditems_f4f89c" ON "pipture_userpurchaseditems" ("Purchaser_id");
  
ALTER TABLE pipture_userpurchaseditems
  ADD CONSTRAINT fk_purchaseditems_purchaser
  FOREIGN KEY (Purchaser_id)
  REFERENCES pipture_purchasers(PurchaserId)
  ON DELETE SET NULL;

ALTER TABLE pipture_transactions
  DROP COLUMN UserId_id;

ALTER TABLE pipture_transactions
  ADD COLUMN Purchaser_id INT
  AFTER ViewsCount;
  
ALTER TABLE pipture_transactions
  ADD CONSTRAINT fk_transactions_purchaser
  FOREIGN KEY (Purchaser_id)
  REFERENCES pipture_purchasers(PurchaserId)
  ON DELETE SET NULL;
  