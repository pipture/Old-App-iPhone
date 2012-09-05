CREATE TABLE pipture_freemsgviewers (
  FreeMsgViewersId integer NOT NULL PRIMARY KEY,
  UserId_id integer,
  EpisodeId_id integer,
  Rest integer,
  FOREIGN KEY (UserId_id) REFERENCES pipture_pipuser(UserUID) ON DELETE CASCADE,
  FOREIGN KEY (EpisodeId_id) REFERENCES pipture_episodes(EpisodeId) ON DELETE CASCADE
);

ALTER TABLE pipture_sendmessage
  ADD COLUMN FreeViews INT
  AFTER ViewsLimit;