-- Generated via ./bqetl glean_usage generate
CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.klar_ios.baseline_clients_last_seen`
AS
SELECT
  * REPLACE ("release" AS normalized_channel)
FROM
  `moz-fx-data-shared-prod.org_mozilla_ios_klar.baseline_clients_last_seen`