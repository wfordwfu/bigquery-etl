CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.mozilla_mach.deletion_request`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.mozilla_mach_stable.deletion_request_v1`
