
from __future__ import print_function
from airflow import models
from airflow.hooks.postgres_hook import PostgresHook
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
from time import mktime

import logging
import os

logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)

default_dag_args = {
    'depends_on_past': False,
    'start_date': datetime(2015, 7, 30),
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 5,
    'retry_delay': timedelta(minutes=5)
}

notification_emails = os.environ.get('NOTIFICATION_EMAILS')
if notification_emails and len(notification_emails) > 0:
    default_dag_args['email'] = [email.strip() for email in notification_emails.split(',')]

dag = models.DAG(
    dag_id='redshift_increment_aggregates',
    # Daily at 2:00am
    schedule_interval='0 2 * * *',
    concurrency=1,
    max_active_runs=1,
    default_args=default_dag_args
)

sql_folder = os.environ.get('REDSHIFT_SQL_FOLDER', "/usr/local/airflow/dags/redshift/sql")
if sql_folder is None:
    raise ValueError("You must set REDSHIFT_SQL_FOLDER environment variable")


def run_sql(ds, **kwargs):
    conn_id = kwargs.get('conn_id')
    sql_file_path = kwargs.get('sql_file_path')
    pg_hook = PostgresHook(conn_id)

    # Get inclusive timestamp bounds of the execution day
    year, month, day = map(int, ds.split('-'))
    start_timestamp = int(mktime(datetime(year, month, day, 0, 0, 0).timetuple()))
    end_timestamp = int(mktime(datetime(year, month, day, 23, 59, 59).timetuple()))

    with open(sql_file_path, 'r') as sql_file:
        sql = sql_file.read().format(
            start_timestamp=start_timestamp,
            end_timestamp=end_timestamp
        )
        pg_hook.run(sql)


def add_refresh_task(task_id, sql_file_path, dependencies=None):

    operator = PythonOperator(
        task_id=task_id,
        dag = dag,
        python_callable=run_sql,
        provide_context=True,
        op_kwargs={
            'conn_id'       : 'redshift',
            'sql_file_path' : sql_file_path
        },
    )
    if dependencies is not None and len(dependencies) > 0:
        for dependency in dependencies:
            if dependency is not None:
                dependency >> operator
    return operator


transaction_metrics_operator = add_refresh_task(
    'aggregate_transaction_metrics_by_block',
    sql_folder + '/increment/aggregate_transaction_metrics_by_block.sql'
)

transaction_metrics_operator = add_refresh_task(
    'aggregate_metrics_by_day',
    sql_folder + '/increment/aggregate_metrics_by_day.sql',
    dependencies=[transaction_metrics_operator]
)
