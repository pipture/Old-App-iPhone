ALTER TABLE pipture_pipturesettings
  ADD COLUMN Album_id INT
  AFTER PremierePeriod;

ALTER TABLE pipture_pipturesettings
  ADD FOREIGN KEY (Album_id)
  REFERENCES pipture_albums(AlbumId)
  ON DELETE SET NULL;