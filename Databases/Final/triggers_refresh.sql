CREATE OR REPLACE FUNCTION trig_refresh_GetAverageRatingByTrustedUser() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW GetAverageRatingByTrustedUser;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql ;


CREATE TRIGGER trig_01_refresh_GetAverageRatingByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetAverageRatingByTrustedUser();

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


CREATE TRIGGER trig_01_refresh_GetItemReviewsByTrustedUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetItemReviewsByTrustedUser();

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


CREATE TRIGGER trig_01_refresh_GetReviewItemById AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetReviewItemById();

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


CREATE TRIGGER trig_01_refresh_GetReviewsByUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
   ON review FOR EACH STATEMENT
   EXECUTE PROCEDURE trig_refresh_GetReviewsByUser();

CREATE TRIGGER trig_02_refresh_GetReviewsByUser AFTER TRUNCATE OR INSERT OR UPDATE OR DELETE
  ON "user" FOR EACH STATEMENT
  EXECUTE PROCEDURE trig_refresh_GetReviewsByUser();
