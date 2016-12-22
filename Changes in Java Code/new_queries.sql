-- Create Materialized View for Inner Join in "SELECT avg(rating) FROM review r, trust t WHERE r.u_id=t.target_u_id AND r.i_id=? AND t.source_u_id=?"
-- drop materialized view if exists GetAverageRatingByTrustedUser;
create materialized view GetAverageRatingByTrustedUser as
	select r.i_id, t.source_u_id, avg(rating) FROM review as r
		inner join trust as t
		on r.u_id=t.target_u_id
	group by( r.i_id , t.source_u_id );

CREATE INDEX IDX_MVIEW_GARBTU ON GetAverageRatingByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE TABLE table2 AS SELECT * FROM table1; to create clusters in a duplicate table
-- Create index on review for "SELECT avg(rating) FROM review r WHERE r.i_id=?"
-- drop index if exists IDX_RATING_IID;
CREATE INDEX IDX_RATING_IID ON "review" (i_id);

--CLUSTER "review" USING IDX_RATING_IID;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r WHERE r.i_id=?" and "SELECT * FROM trust t WHERE t.source_u_id=?"
-- drop materialized view if exists GetItemReviewsByTrustedUser;
create materialized view GetItemReviewsByTrustedUser as
	select r.i_id,r.a_id,r.u_id,r.rating,t.source_u_id,t.target_u_id,t.trust,t.creation_date from review as r
		inner join trust as t
		on r.u_id=t.source_u_id;
	-- group by(r.i_id);

CREATE INDEX IDX_MVIEW_GIRBTU ON GetItemReviewsByTrustedUser (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, item i WHERE i.i_id = r.i_id and r.i_id=? ORDER BY rating LIMIT 10;"
-- drop materialized view if exists GetReviewItemById;
create materialized view GetReviewItemById as
        select r.i_id,r.a_id,r.u_id,r.rating,i.title from review as r
                inner join item as i
                on i.i_id=r.i_id
	      -- group by(r.i_id)
        order by(r.rating)
	      limit 10;

CREATE INDEX IDX_MVIEW_GRIBI ON GetReviewItemById (i_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, user u WHERE u.u_id = r.u_id AND r.u_id=? ORDER BY rating LIMIT 10;"
-- drop materialized view if exists GetReviewsByUser;
create materialized view GetReviewsByUser as
        select r.u_id,r.a_id,r.i_id,r.rating,u.name from review as r
                inner join "user" as u
                on u.u_id=r.u_id
        -- group by(r.u_id)
        order by(r.rating)
        limit 10;

CREATE INDEX IDX_MVIEW_GRBU ON GetReviewsByUser (u_id);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on item for "UPDATE item SET title = ? WHERE i_id=?"
-- UpdateItemTitle
-- drop index if exists IDX_TITLE_IID;
CREATE INDEX IDX_TITLE_IID ON "item" (i_id);

--CLUSTER "item" USING IDX_TITLE_IID;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE review SET rating = ? WHERE i_id=? AND u_id=?"
-- UpdateReviewRating
-- drop index if exists IDX_RATING_IID_UID;
CREATE INDEX IDX_RATING_IID_UID ON "review" (i_id,u_id);

--CLUSTER "review" USING IDX_RATING_IID_UID;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE trust SET trust = ? WHERE source_u_id=? AND target_u_id=?"
-- UpdateTrustRating
-- drop index if exists IDX_RATING_SUID_TUID;
CREATE INDEX IDX_RATING_SUID_TUID ON "trust" (source_u_id,target_u_id);

--CLUSTER "trust" USING IDX_RATING_SUID_TUID;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE user SET name = ? WHERE u_id=?"
-- UpdateUserName
-- drop index if exists IDX_NAME_UID;
CREATE INDEX IDX_NAME_UID ON "user" (u_id);

--CLUSTER "user" USING IDX_NAME_UID;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- For more information on cluster consult the following site
-- http://hans.io/blog/2014/03/25/postgresql_cluster
