CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.telemetry.saved_session`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.telemetry_stable.saved_session_v4`
