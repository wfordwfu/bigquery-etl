CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.telemetry.first_shutdown`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.telemetry_stable.first_shutdown_v4`
