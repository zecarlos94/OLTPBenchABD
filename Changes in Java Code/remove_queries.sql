drop index if exists IDX_RATING_IID;
drop index if exists IDX_TITLE_IID;
drop index if exists IDX_RATING_IID_UID;
drop index if exists IDX_RATING_SUID_TUID;
drop index if exists IDX_NAME_UID;
drop materialized view if exists GetAverageRatingByTrustedUser;
drop materialized view if exists GetItemReviewsByTrustedUser;
drop materialized view if exists GetReviewItemById;
drop materialized view if exists GetReviewsByUser;
