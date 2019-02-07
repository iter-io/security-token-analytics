
from __future__ import print_function
from airflow import models
from airflow.hooks.postgres_hook import PostgresHook
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta

import logging
import os

logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)

default_dag_args = {
    'depends_on_past': False,
    'start_date': datetime(2019, 2, 1),
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 5,
    'retry_delay': timedelta(minutes=5)
}

notification_emails = os.environ.get('NOTIFICATION_EMAILS')
if notification_emails and len(notification_emails) > 0:
    default_dag_args['email'] = [email.strip() for email in notification_emails.split(',')]

dag = models.DAG(
    dag_id='redshift_refresh_aggregates',
    schedule_interval='0 2 * * *',
    concurrency=1,
    default_args=default_dag_args
)

sql_folder = os.environ.get('REDSHIFT_SQL_FOLDER', "/usr/local/airflow/dags/redshift/sql")
if sql_folder is None:
    raise ValueError("You must set REDSHIFT_SQL_FOLDER environment variable")

def refresh_task(**kwargs):
    conn_id = kwargs.get('conn_id')
    pg_hook = PostgresHook(conn_id)
    sql_path = sql_folder + '/refresh/aggregates.sql'
    print("sql_path:  " + sql_path)

    with open(sql_path, 'r') as sql_file:
        sql = sql_file.read()
        pg_hook.run(sql)


refresh_task = load_operator = PythonOperator(
    task_id='refresh_aggregates',
    dag = dag,
    python_callable=refresh_task,
    provide_context=True,
    op_kwargs={
        'conn_id' : 'redshift'
    },
)
