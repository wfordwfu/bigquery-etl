CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_connect_firefox.events`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_connect_firefox_stable.events_v1`
