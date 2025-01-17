CREATE TABLE IF NOT EXISTS
  `moz-fx-data-shared-prod.monitoring_derived.airflow_dag_v1`
AS
SELECT
  dag_id,
  IF(is_subdag, SPLIT(dag_id, ".")[OFFSET(0)], dag_id) AS root_dag_id,
  IF(is_subdag, SPLIT(dag_id, ".")[OFFSET(1)], NULL) AS subdag_id,
  is_subdag,
  owners,
  is_paused,
  has_task_concurrency_limits,
  concurrency,
FROM
  `moz-fx-data-bq-fivetran.airflow_metadata_airflow_db.dag`
WHERE
  NOT _fivetran_deleted
  AND is_active
