-- Generated by bigquery_etl/events_daily/generate_queries.py
CREATE OR REPLACE TABLE
  fenix_derived.event_types_v1
AS
SELECT
  * EXCEPT (submission_date)
FROM
  fenix_derived.event_types_history_v1