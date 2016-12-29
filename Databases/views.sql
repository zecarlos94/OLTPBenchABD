--drop index if exists IDX_RATING_IID;
CREATE INDEX IDX_RATING_IID ON "review" (i_id);

--drop index if exists IDX_TITLE_IID;
CREATE INDEX IDX_TITLE_IID ON "item" (i_id);

--drop index if exists IDX_RATING_IID_UID;
CREATE INDEX IDX_RATING_IID_UID ON "review" (i_id,u_id);

--drop index if exists IDX_RATING_SUID_TUID;
CREATE INDEX IDX_RATING_SUID_TUID ON "trust" (source_u_id,target_u_id);

--drop index if exists IDX_NAME_UID;
CREATE INDEX IDX_NAME_UID ON "user" (u_id);


-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

--drop materialized view if exists GetAverageRatingByTrustedUser;
create materialized view GetAverageRatingByTrustedUser as
	select r.i_id, t.source_u_id, avg(rating) FROM review as r
		inner join trust as t
		on r.u_id=t.target_u_id
	group by( r.i_id , t.source_u_id );

--drop index if exists IDX_MVIEW_GARBTU;
CREATE INDEX IDX_MVIEW_GARBTU ON GetAverageRatingByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

--drop materialized view if exists GetItemReviewsByTrustedUser;
create materialized view GetItemReviewsByTrustedUser as
	select r.i_id,r.a_id,r.u_id,r.rating,t.source_u_id,t.target_u_id,t.trust,t.creation_date from review as r
		inner join trust as t
		on r.u_id=t.source_u_id;

--drop index if exists IDX_MVIEW_GIRBTU;
CREATE INDEX IDX_MVIEW_GIRBTU ON GetItemReviewsByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

--drop materialized view if exists GetReviewItemById;
create materialized view GetReviewItemById as
        select r.i_id,r.a_id,r.u_id,r.rating,i.title from review as r
                inner join item as i
                on i.i_id=r.i_id
        order by(r.rating)
	      limit 10;

--drop index if exists IDX_MVIEW_GRIBI;
CREATE INDEX IDX_MVIEW_GRIBI ON GetReviewItemById (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

--drop materialized view if exists GetReviewsByUser;
create materialized view GetReviewsByUser as
        select r.u_id,r.a_id,r.i_id,r.rating,u.name from review as r
                inner join "user" as u
                on u.u_id=r.u_id
        order by(r.rating)
        limit 10;

--drop index if exists IDX_MVIEW_GRBU;
CREATE INDEX IDX_MVIEW_GRBU ON GetReviewsByUser (u_id);
