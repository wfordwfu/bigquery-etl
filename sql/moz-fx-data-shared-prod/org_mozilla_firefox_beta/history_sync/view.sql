CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_firefox_beta.history_sync`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_firefox_beta_stable.history_sync_v1`
