drop index if exists IDX_RATING_IID;
CREATE INDEX IDX_RATING_IID ON "review" (i_id);

drop index if exists IDX_TITLE_IID;
CREATE INDEX IDX_TITLE_IID ON "item" (i_id);

drop index if exists IDX_RATING_IID_UID;
CREATE INDEX IDX_RATING_IID_UID ON "review" (i_id,u_id);

drop index if exists IDX_RATING_SUID_TUID;
CREATE INDEX IDX_RATING_SUID_TUID ON "trust" (source_u_id,target_u_id);

drop index if exists IDX_NAME_UID;
CREATE INDEX IDX_NAME_UID ON "user" (u_id);


-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

drop materialized view if exists GetAverageRatingByTrustedUser;
create materialized view GetAverageRatingByTrustedUser as
	select r.i_id, t.source_u_id, avg(rating) FROM review as r
		inner join trust as t
		on r.u_id=t.target_u_id
	group by( r.i_id , t.source_u_id );

drop index if exists IDX_MVIEW_GARBTU;
CREATE INDEX IDX_MVIEW_GARBTU ON GetAverageRatingByTrustedUser (i_id);

DROP FUNCTION trig_refresh_GetAverageRatingByTrustedUser();
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

drop materialized view if exists GetItemReviewsByTrustedUser;
create materialized view GetItemReviewsByTrustedUser as
	select r.i_id,r.a_id,r.u_id,r.rating,t.source_u_id,t.target_u_id,t.trust,t.creation_date from review as r
		inner join trust as t
		on r.u_id=t.source_u_id;

drop index if exists IDX_MVIEW_GIRBTU;
CREATE INDEX IDX_MVIEW_GIRBTU ON GetItemReviewsByTrustedUser (i_id);

DROP FUNCTION trig_refresh_GetItemReviewsByTrustedUser();
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

drop materialized view if exists GetReviewItemById;
create materialized view GetReviewItemById as
        select r.i_id,r.a_id,r.u_id,r.rating,i.title from review as r
                inner join item as i
                on i.i_id=r.i_id
        order by(r.rating)
	      limit 10;

drop index if exists IDX_MVIEW_GRIBI;
CREATE INDEX IDX_MVIEW_GRIBI ON GetReviewItemById (i_id);

DROP FUNCTION trig_refresh_GetReviewItemById();
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

drop materialized view if exists GetReviewsByUser;
create materialized view GetReviewsByUser as
        select r.u_id,r.a_id,r.i_id,r.rating,u.name from review as r
                inner join "user" as u
                on u.u_id=r.u_id
        order by(r.rating)
        limit 10;

drop index if exists IDX_MVIEW_GRBU;
CREATE INDEX IDX_MVIEW_GRBU ON GetReviewsByUser (u_id);

DROP FUNCTION trig_refresh_GetReviewsByUser();
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
