CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_mozregression.deletion_request`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_mozregression_stable.deletion_request_v1`
