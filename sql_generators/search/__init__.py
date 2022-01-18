"""
Generate mobile search clients_daily query.

Creates a combined CTE for metrics and baseline for Android and iOS Glean
apps, then print query to stdout

To update query file:
python -m bigquery_etl.search.mobile_search_clients_daily \
> sql/moz-fx-data-shared-prod/\
search_derived/mobile_search_clients_daily_v1/query.sql
"""
from pathlib import Path
from typing import List

import click
from jinja2 import Environment, FileSystemLoader

from bigquery_etl.format_sql.formatter import reformat

# fmt: off
FIREFOX_FOR_ANDROID_TUPLES = [
    ("org_mozilla_fenix",           "Firefox Preview",  "beta"),  # noqa E241 E501
    ("org_mozilla_fenix_nightly",   "Firefox Preview",  "nightly"),  # noqa E241 E501
    ("org_mozilla_fennec_aurora",   "Fenix",            "nightly"),  # noqa E241 E501
    ("org_mozilla_firefox_beta",    "Fenix",            "beta"),  # noqa E241 E501
    ("org_mozilla_firefox",         "Fenix",            "release"),  # noqa E241 E501
]

FIREFOX_FOR_IOS_TUPLES = [
    ("org_mozilla_ios_firefox",     "Fennec", "release"),  # noqa E241 E501
    ("org_mozilla_ios_firefoxbeta", "Fennec", "beta"),  # noqa E241 E501
    ("org_mozilla_ios_fennec",      "Fennec", "nightly"),  # noqa E241 E501
]
# fmt: on


def union_statements(statements: List[str]):
    """Join a list of strings together by UNION ALL."""
    return "\nUNION ALL\n".join(statements)


@click.command()
@click.option(
    "--output-dir",
    "--output_dir",
    help="Output directory generated SQL is written to",
    type=click.Path(file_okay=False),
    default="sql",
)
@click.option(
    "--target-project",
    "--target_project",
    help="GCP project ID",
    default="moz-fx-data-shared-prod",
)
def generate(output_dir, target_project):
    """Generate mobile search clients daily query and print to stdout."""
    base_dir = Path(__file__).parent

    env = Environment(loader=FileSystemLoader(base_dir / "templates"))

    android_query_template = env.get_template("fenix_metrics.template.sql")
    ios_query_template = env.get_template("ios_metrics.template.sql")

    firefox_for_android_queries = [
        android_query_template.render(
            namespace=namespace, app_name=app_name, channel=channel
        )
        for namespace, app_name, channel in FIREFOX_FOR_ANDROID_TUPLES
    ]

    firefox_for_ios_queries = [
        ios_query_template.render(
            namespace=namespace, app_name=app_name, channel=channel
        )
        for namespace, app_name, channel in FIREFOX_FOR_IOS_TUPLES
    ]

    queries = firefox_for_android_queries + firefox_for_ios_queries

    search_query_template = env.get_template("mobile_search_clients_daily.template.sql")

    fenix_combined_baseline = union_statements(
        [
            f"SELECT * FROM baseline_{namespace}"
            for namespace, _, _ in FIREFOX_FOR_ANDROID_TUPLES
        ]
    )
    fenix_combined_metrics = union_statements(
        [
            f"SELECT * FROM metrics_{namespace}"
            for namespace, _, _ in FIREFOX_FOR_ANDROID_TUPLES
        ]
    )
    ios_combined_metrics = union_statements(
        [
            f"SELECT * FROM metrics_{namespace}"
            for namespace, _, _ in FIREFOX_FOR_IOS_TUPLES
        ]
    )

    search_query = search_query_template.render(
        baseline_and_metrics_by_namespace="\n".join(queries),
        fenix_baseline=fenix_combined_baseline,
        fenix_metrics=fenix_combined_metrics,
        ios_metrics=ios_combined_metrics,
    )

    print(reformat(search_query))
