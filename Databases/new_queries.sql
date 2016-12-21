-- Create Materialized View for Inner Join in "SELECT avg(rating) FROM review r, trust t WHERE r.u_id=t.target_u_id AND r.i_id=? AND t.source_u_id=?"
create materialized view GetAverageRatingByTrustedUser as 
	select r.i_id, t.source_u_id, avg(rating) FROM review as r
		inner join trust as t
		on r.u_id=t.target_u_id
	group by( r.i_id , t.source_u_id );

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "SELECT avg(rating) FROM review r WHERE r.i_id=?"
CREATE INDEX IDX_RATING_IID ON "review" (i_id);

CLUSTER reviews_average_rating_clustered USING INDEX IDX_RATING_IID;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r WHERE r.i_id=?" and "SELECT * FROM trust t WHERE t.source_u_id=?"
create materialized view GetItemReviewsByTrustedUser as 
	select * from review as r
		inner join trust as t
		on r.u_id=t.source_u_id 
	group by(r.i_id);

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, item i WHERE i.i_id = r.i_id and r.i_id=? ORDER BY rating LIMIT 10;"
create materialized view GetReviewItemById as
        select * from review as r
                inner join item as i
                on i.i_id=r.i_id
	group by(r.i_id)
        order by(rating)
	limit 10;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create Materialized View for Inner Join in "SELECT * FROM review r, user u WHERE u.u_id = r.u_id AND r.u_id=? ORDER BY rating LIMIT 10;"
create materialized view GetReviewsByUser as
        select * from review as r
                inner join user as u
                on u.u_id=r.u_id
        group by(r.u_id)
        order by(rating)
        limit 10;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on item for "UPDATE item SET title = ? WHERE i_id=?"
-- UpdateItemTitle
CREATE INDEX IDX_TITLE_IID ON "item" (i_id);

CLUSTER items_update_title_clustered USING INDEX IDX_TITLE_IID;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE review SET rating = ? WHERE i_id=? AND u_id=?"
-- UpdateReviewRating
CREATE INDEX IDX_RATING_IID_UID ON "review" (i_id,u_id);

CLUSTER reviews_update_rating_clustered USING INDEX IDX_RATING_IID_UID;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE trust SET trust = ? WHERE source_u_id=? AND target_u_id=?"
-- UpdateTrustRating
CREATE INDEX IDX_RATING_SUID_TUID ON "trust" (source_u_id,target_u_id);

CLUSTER reviews_update_trust_clustered USING INDEX IDX_RATING_SUID_TUID;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Create index on review for "UPDATE user SET name = ? WHERE u_id=?"
-- UpdateUserName
CREATE INDEX IDX_NAME_UID ON "user" (u_id);

CLUSTER user_update_name_clustered USING INDEX IDX_NAME_UID;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- For more information on cluster consult the following site
-- http://hans.io/blog/2014/03/25/postgresql_cluster
