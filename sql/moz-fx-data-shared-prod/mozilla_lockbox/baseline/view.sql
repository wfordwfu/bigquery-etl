CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.mozilla_lockbox.baseline`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.mozilla_lockbox_stable.baseline_v1`
