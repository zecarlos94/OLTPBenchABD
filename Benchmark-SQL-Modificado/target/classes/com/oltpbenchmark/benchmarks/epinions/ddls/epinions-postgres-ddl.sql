-- PostgreSQL DDL

DROP TABLE IF EXISTS "user" cascade;
CREATE TABLE "user" (
  u_id int NOT NULL,
  name varchar(128) DEFAULT NULL,
  PRIMARY KEY (u_id)
);

DROP TABLE IF EXISTS "item" cascade;
CREATE TABLE "item" (
  i_id int NOT NULL,
  title varchar(20) DEFAULT NULL,
  PRIMARY KEY (i_id)
);

DROP TABLE IF EXISTS "review";
CREATE TABLE "review" (
  a_id int NOT NULL,
  u_id int NOT NULL REFERENCES "user" (u_id),
  i_id int NOT NULL REFERENCES "item" (i_id),
  rating int DEFAULT NULL,
  rank int DEFAULT NULL
);
CREATE INDEX IDX_RATING_UID ON "review" (u_id);
CREATE INDEX IDX_RATING_AID ON "review" (a_id);

DROP TABLE IF EXISTS "review_rating";
CREATE TABLE "review_rating" (
  u_id int NOT NULL REFERENCES "user" (u_id),
  a_id int NOT NULL,
  rating int NOT NULL,
  status int NOT NULL,
  creation_date timestamp DEFAULT NULL,
  last_mod_date timestamp DEFAULT NULL,
  type int DEFAULT NULL,
  vertical_id int DEFAULT NULL
);
CREATE INDEX IDX_REVIEW_RATING_UID ON "review_rating" (u_id);
CREATE INDEX IDX_REVIEW_RATING_AID ON "review_rating" (a_id);

DROP TABLE IF EXISTS "trust";
CREATE TABLE "trust" (
  source_u_id int NOT NULL REFERENCES "user" (u_id),
  target_u_id int NOT NULL REFERENCES "user" (u_id),
  trust int NOT NULL,
  creation_date timestamp DEFAULT NULL
);

-----------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT avg(rating) FROM review r, trust t WHERE r.u_id=t.target_u_id AND r.i_id=? AND t.source_u_id=?"
drop materialized view if exists GetAverageRatingByTrustedUser;
create materialized view GetAverageRatingByTrustedUser as
	select r.i_id, t.source_u_id, avg(rating) FROM review as r
		inner join trust as t
		on r.u_id=t.target_u_id
	group by( r.i_id , t.source_u_id );

drop index if exists IDX_MVIEW_GARBTU;
CREATE INDEX IDX_MVIEW_GARBTU ON GetAverageRatingByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "SELECT avg(rating) FROM review r WHERE r.i_id=?"
drop index if exists IDX_RATING_IID;
CREATE INDEX IDX_RATING_IID ON "review" (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r WHERE r.i_id=?" and "SELECT * FROM trust t WHERE t.source_u_id=?"
drop materialized view if exists GetItemReviewsByTrustedUser;
create materialized view GetItemReviewsByTrustedUser as
	select r.i_id,r.a_id,r.u_id,r.rating,t.source_u_id,t.target_u_id,t.trust,t.creation_date from review as r
		inner join trust as t
		on r.u_id=t.source_u_id;

drop index if exists IDX_MVIEW_GIRBTU;
CREATE INDEX IDX_MVIEW_GIRBTU ON GetItemReviewsByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, item i WHERE i.i_id = r.i_id and r.i_id=? ORDER BY rating LIMIT 10;"
drop materialized view if exists GetReviewItemById;
create materialized view GetReviewItemById as
        select r.i_id,r.a_id,r.u_id,r.rating,i.title from review as r
                inner join item as i
                on i.i_id=r.i_id
        order by(r.rating)
	    limit 10;

drop index if exists IDX_MVIEW_GRIBI;
CREATE INDEX IDX_MVIEW_GRIBI ON GetReviewItemById (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, user u WHERE u.u_id = r.u_id AND r.u_id=? ORDER BY rating LIMIT 10;"
drop materialized view if exists GetReviewsByUser;
create materialized view GetReviewsByUser as
        select r.u_id,r.a_id,r.i_id,r.rating,u.name from review as r
                inner join "user" as u
                on u.u_id=r.u_id
        order by(r.rating)
        limit 10;

drop index if exists IDX_MVIEW_GRBU;
CREATE INDEX IDX_MVIEW_GRBU ON GetReviewsByUser (u_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on item for "UPDATE item SET title = ? WHERE i_id=?"
drop index if exists IDX_TITLE_IID;
CREATE INDEX IDX_TITLE_IID ON "item" (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE review SET rating = ? WHERE i_id=? AND u_id=?"
drop index if exists IDX_RATING_IID_UID;
CREATE INDEX IDX_RATING_IID_UID ON "review" (i_id,u_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE trust SET trust = ? WHERE source_u_id=? AND target_u_id=?"
drop index if exists IDX_RATING_SUID_TUID;
CREATE INDEX IDX_RATING_SUID_TUID ON "trust" (source_u_id,target_u_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE user SET name = ? WHERE u_id=?"
drop index if exists IDX_NAME_UID;
CREATE INDEX IDX_NAME_UID ON "user" (u_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trig_refresh_GetAverageRatingByTrustedUser() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW GetAverageRatingByTrustedUser;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql ;

DROP TRIGGER if exists trig_01_refresh_GetAverageRatingByTrustedUser ON review;
CREATE TRIGGER trig_01_refresh_GetAverageRatingByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetAverageRatingByTrustedUser();

DROP TRIGGER if exists trig_02_refresh_GetAverageRatingByTrustedUser ON trust;
CREATE TRIGGER trig_02_refresh_GetAverageRatingByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
  ON trust FOR EACH STATEMENT
  EXECUTE PROCEDURE trig_refresh_GetAverageRatingByTrustedUser();

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trig_refresh_GetItemReviewsByTrustedUser() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW GetItemReviewsByTrustedUser;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql ;

DROP TRIGGER if exists trig_01_refresh_GetItemReviewsByTrustedUser ON review;
CREATE TRIGGER trig_01_refresh_GetItemReviewsByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetItemReviewsByTrustedUser();

DROP TRIGGER if exists trig_02_refresh_GetItemReviewsByTrustedUser ON trust;
CREATE TRIGGER trig_02_refresh_GetItemReviewsByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
  ON trust FOR EACH STATEMENT
  EXECUTE PROCEDURE trig_refresh_GetItemReviewsByTrustedUser();

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trig_refresh_GetReviewItemById() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW GetReviewItemById;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql ;

DROP TRIGGER if exists trig_01_refresh_GetReviewItemById ON review;
CREATE TRIGGER trig_01_refresh_GetReviewItemById AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetReviewItemById();

DROP TRIGGER if exists trig_02_refresh_GetReviewItemById ON item;
CREATE TRIGGER trig_02_refresh_GetReviewItemById AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
  ON item FOR EACH STATEMENT
  EXECUTE PROCEDURE trig_refresh_GetReviewItemById();

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trig_refresh_GetReviewsByUser() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW GetReviewsByUser;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql ;

DROP TRIGGER if exists trig_01_refresh_GetReviewsByUser ON review;
CREATE TRIGGER trig_01_refresh_GetReviewsByUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetReviewsByUser();

DROP TRIGGER if exists trig_02_refresh_GetReviewsByUser ON "user";
CREATE TRIGGER trig_02_refresh_GetReviewsByUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
  ON "user" FOR EACH STATEMENT
  EXECUTE PROCEDURE trig_refresh_GetReviewsByUser();
