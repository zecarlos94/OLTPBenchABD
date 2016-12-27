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


drop materialized view if exists GetReviewsByUser;
create materialized view GetReviewsByUser as
        select r.u_id,r.a_id,r.i_id,r.rating,u.name from review as r
                inner join "user" as u
                on u.u_id=r.u_id
        order by(r.rating)
        limit 10;

drop index if exists IDX_MVIEW_GRBU;
CREATE INDEX IDX_MVIEW_GRBU ON GetReviewsByUser (u_id);

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

