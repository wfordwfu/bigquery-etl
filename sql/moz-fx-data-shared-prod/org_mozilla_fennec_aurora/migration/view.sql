CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_fennec_aurora.migration`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_fennec_aurora_stable.migration_v1`
