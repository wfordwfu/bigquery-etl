CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.burnham.events`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.burnham_stable.events_v1`
