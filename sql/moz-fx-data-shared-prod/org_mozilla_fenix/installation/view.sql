CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_fenix.installation`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_fenix_stable.installation_v1`
