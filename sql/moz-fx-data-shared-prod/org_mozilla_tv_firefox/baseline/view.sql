CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_tv_firefox.baseline`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_tv_firefox_stable.baseline_v1`
