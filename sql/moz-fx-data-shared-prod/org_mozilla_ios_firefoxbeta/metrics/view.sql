CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_ios_firefoxbeta.metrics`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_ios_firefoxbeta_stable.metrics_v1`
