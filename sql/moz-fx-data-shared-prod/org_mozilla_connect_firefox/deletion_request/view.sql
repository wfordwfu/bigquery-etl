CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_connect_firefox.deletion_request`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_connect_firefox_stable.deletion_request_v1`
