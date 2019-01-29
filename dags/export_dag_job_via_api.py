
# Should be run with the LocalExecutor

from airflow.models import DAG
from datetime import datetime, timedelta
import kubernetes.client
import kubernetes.config
import kubernetes.utils

from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator
from airflow.operators import python_operator


default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    "start_date": datetime(2019, 1, 5),
    'catchup': False,
    'retries': 0,
    'max_active_runs': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG('export_dag_job_via_api', schedule_interval=None, default_args=default_args)

def create_kube_job(execution_date, **kwargs):
    # it works only if this script is run by K8s as a POD
    kubernetes.config.load_incluster_config()

    k8s_client = kubernetes.client.ApiClient()
    k8s_api = kubernetes.utils.create_from_yaml(k8s_client, "ethereum_etl_job.yaml")
    deps = k8s_api.read_namespaced_job("ethereum-etl", "default")
    print("Deployment {0} created".format(deps.metadata.name))


operator = python_operator.PythonOperator(
    task_id="task-1",
    python_callable=create_kube_job,
    provide_context=True,
    execution_timeout=timedelta(hours=15),
    dag=dag,
)
