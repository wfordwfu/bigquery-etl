CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.org_mozilla_fenix.activation`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.org_mozilla_fenix_stable.activation_v1`
