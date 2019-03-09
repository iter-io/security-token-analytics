#!/bin/bash

CMD="airflow"
TRY_LOOP="${TRY_LOOP:-10}"
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT=5432
POSTGRES_CREDS="${POSTGRES_CREDS:-airflow:airflow}"
AIRFLOW_URL_PREFIX="${AIRFLOW_URL_PREFIX:-}"

sed -i "s/{{ POSTGRES_HOST }}/${POSTGRES_HOST}/" ${AIRFLOW_HOME}/airflow.cfg
sed -i "s/{{ POSTGRES_CREDS }}/${POSTGRES_CREDS}/" ${AIRFLOW_HOME}/airflow.cfg
sed -i "s#{{ AIRFLOW_URL_PREFIX }}#${AIRFLOW_URL_PREFIX}#" ${AIRFLOW_HOME}/airflow.cfg

# ethereum-etl
export CLOUD_PROVIDER="aws"
export OUTPUT_BUCKET="insight-prod-ethereum-etl-output"
export EXPORT_BLOCKS_AND_TRANSACTIONS=True
export EXPORT_RECEIPTS_AND_LOGS=True
export EXTRACT_TOKEN_TRANSFERS=True
export EXPORT_CONTRACTS=True
export EXPORT_TOKENS=True
export EXPORT_TRACES=False
export NOTIFICATION_EMAILS="webster@iteriodata.com"
export EXPORT_MAX_WORKERS=4
export EXPORT_BATCH_SIZE=10
export WEB3_PROVIDER_URI_BACKUP="https://mainnet.infura.io"
export WEB3_PROVIDER_URI_ARCHIVAL="https://mainnet.infura.io"
export DESTINATION_DATASET_PROJECT_ID="test"
export DAGS_FOLDER="/usr/local/airflow/dags/ethereum-etl-airflow/dags"
export PYTHONPATH="${PYTHONPATH}:/${DAGS_FOLDER}"


# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

# wait for postgres
sleep 60
#if [ "$1" = "webserver" ] || [ "$1" = "worker" ] || [ "$1" = "scheduler" ] ; then
#  i=0
#  while ! nc $POSTGRES_HOST $POSTGRES_PORT >/dev/null 2>&1 < /dev/null; do
#    i=`expr $i + 1`
#    if [ $i -ge $TRY_LOOP ]; then
#      echo "$(date) - ${POSTGRES_HOST}:${POSTGRES_PORT} still not reachable, giving up"
#      exit 1
#    fi
#    echo "$(date) - waiting for ${POSTGRES_HOST}:${POSTGRES_PORT}... $i/$TRY_LOOP"
#    sleep 5
#  done

case "$1" in
  webserver)
    sleep 10
    echo "Initialize database..."
    #  # TODO: move to a Helm hook
    # https://github.com/kubernetes/helm/blob/master/docs/charts_hooks.md
    $CMD initdb
    # https://github.com/apache/airflow/blob/master/docs/security.rst
    airflow users --create --username admin --password password --role Admin --email webster@iteriodata.com --firstname Webster --lastname Cook
    exec $CMD webserver
    ;;
  worker)
    # To give the webserver time to run initdb.
    sleep 30
    exec $CMD "$@"
    ;;
  scheduler)
    # To give the webserver time to run initdb.
    sleep 30
    # Via Tobias Kaymak
    # https://github.com/puckel/docker-airflow/issues/55
    while echo "Running Scheduler"; do
      # See https://airflow.apache.org/cli.html#scheduler
      airflow scheduler
      exitcode=$?
      if [ $exitcode -ne 0 ]; then
        echo "ERROR: Scheduler exited with exit code $?."
        echo $(date)
        exit $exitcode
      fi
      sleep 30
    done
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
