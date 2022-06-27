CREATE OR REPLACE VIEW
  `moz-fx-data-shared-prod.subscription_platform.stripe_subscriptions`
AS
WITH subscriptions AS (
  SELECT
    customer_id,
    id AS subscription_id,
    status,
    _fivetran_synced,
    COALESCE(trial_end, start_date) AS subscription_start_date,
    created,
    trial_start,
    trial_end,
    -- current_period_end,
    -- current_period_start,
    canceled_at,
    JSON_VALUE(metadata, "$.cancelled_for_customer_at") AS canceled_for_customer_at,
    cancel_at,
    cancel_at_period_end,
    ended_at,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.subscription_history
  WHERE
    status NOT IN ("incomplete", "incomplete_expired")
    -- choose subscription from subscription history
    AND _fivetran_active
),
subscription_items AS (
  SELECT
    id AS subscription_item_id,
    subscription_id,
    plan_id,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.subscription_item
),
customers AS (
  SELECT
    id AS customer_id,
    COALESCE(
      TO_HEX(SHA256(JSON_VALUE(customers.metadata, "$.userid"))),
      JSON_VALUE(pre_fivetran_customers.metadata, "$.fxa_uid")
    ) AS fxa_uid,
    COALESCE(customers.address_country, pre_fivetran_customers.address_country) AS address_country,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.customer AS customers
  FULL JOIN
    -- include customers that were deleted before the initial fivetran stripe import
    `moz-fx-data-shared-prod`.stripe_external.pre_fivetran_customers
  USING
    (id)
),
charges AS (
  SELECT
    charges.id AS charge_id,
    COALESCE(cards.country, charges.billing_detail_address_country) AS country,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.charge AS charges
  JOIN
    `moz-fx-data-bq-fivetran`.stripe.card AS cards
  ON
    charges.card_id = cards.id
  WHERE
    charges.status = "succeeded"
),
invoices_provider_country AS (
  SELECT
    invoices.subscription_id,
    IF(
      JSON_VALUE(invoices.metadata, "$.paypalTransactionId") IS NOT NULL,
      -- FxA copies paypal billing agreement country to customer address
      STRUCT("Paypal" AS provider, customers.address_country AS country),
      ("Stripe", charges.country)
    ).*,
    invoices.created,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.invoice AS invoices
  LEFT JOIN
    customers
  USING
    (customer_id)
  LEFT JOIN
    charges
  USING
    (charge_id)
  WHERE
    invoices.status = "paid"
),
subscriptions_promotion_codes AS (
  SELECT
    invoices.subscription_id,
    ARRAY_AGG(DISTINCT promotion_codes.code IGNORE NULLS) AS promotion_codes,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.invoice AS invoices
  JOIN
    `moz-fx-data-bq-fivetran`.stripe.invoice_discount AS invoice_discounts
  ON
    invoices.id = invoice_discounts.invoice_id
  JOIN
    `moz-fx-data-bq-fivetran`.stripe.promotion_code AS promotion_codes
  ON
    invoice_discounts.promotion_code = promotion_codes.id
  WHERE
    invoices.status = "paid"
  GROUP BY
    subscription_id
),
subscriptions_provider_country AS (
  SELECT
    subscription_id,
    ARRAY_AGG(
      STRUCT(provider, LOWER(country) AS country)
      ORDER BY
        -- prefer rows with country
        IF(country IS NULL, 0, 1) DESC,
        created DESC
      LIMIT
        1
    )[OFFSET(0)].*
  FROM
    invoices_provider_country
  GROUP BY
    subscription_id
),
plans AS (
  SELECT
    plans.id AS plan_id,
    plans.amount AS plan_amount,
    plans.billing_scheme AS billing_scheme,
    plans.currency AS plan_currency,
    plans.interval AS plan_interval,
    plans.interval_count AS plan_interval_count,
    plans.product_id,
    products.name AS product_name,
  FROM
    `moz-fx-data-bq-fivetran`.stripe.plan AS plans
  LEFT JOIN
    `moz-fx-data-bq-fivetran`.stripe.product AS products
  ON
    plans.product_id = products.id
)
SELECT
  customer_id,
  subscription_id,
  subscription_item_id,
  plan_id,
  status,
  _fivetran_synced AS event_timestamp,
  subscription_start_date,
  created,
  trial_start,
  trial_end,
  canceled_at,
  canceled_for_customer_at,
  cancel_at,
  cancel_at_period_end,
  ended_at,
  fxa_uid,
  country,
  provider,
  plan_amount,
  billing_scheme,
  plan_currency,
  plan_interval,
  plan_interval_count,
  "Etc/UTC" AS plan_interval_timezone,
  product_id,
  product_name,
  promotion_codes,
FROM
  subscriptions
LEFT JOIN
  subscription_items
USING
  (subscription_id)
LEFT JOIN
  plans
USING
  (plan_id)
LEFT JOIN
  subscriptions_provider_country
USING
  (subscription_id)
LEFT JOIN
  customers
USING
  (customer_id)
LEFT JOIN
  subscriptions_promotion_codes
USING
  (subscription_id)
