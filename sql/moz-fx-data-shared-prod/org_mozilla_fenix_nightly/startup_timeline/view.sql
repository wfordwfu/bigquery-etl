CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_fenix_nightly.startup_timeline`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_fenix_nightly_stable.startup_timeline_v1`
