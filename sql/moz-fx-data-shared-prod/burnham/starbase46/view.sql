CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.burnham.starbase46`
AS SELECT
  * REPLACE(
    mozfun.norm.metadata(metadata) AS metadata)
FROM
  `moz-fx-data-shared-prod.burnham_stable.starbase46_v1`
