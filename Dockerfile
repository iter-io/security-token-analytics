#
# This Dockerfile is based on Puckel's popular image:
#
# https://github.com/puckel/docker-airflow
#
# The major differences:
#
# 1. Airflow is installed directly from the master branch instead of the
# tagged releases.
#
# 2. Dependencies added for ethereum-etl.
#

FROM python:3.6-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.1
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    # Required by Airflow S3 Hook
    && pip install boto3 \
    # Required by ethereum-etl-airflow
    && pip install google-api-python-client \
    && pip install httplib2 \
    && pip install ethereum-etl \
    && pip install mythril \
    && pip install pyetherchain \
    && pip install pandas \
    && pip install pandas-gbq \
    # Required by Airflow
    && pip install pytz \
    && pip install cryptography \
    && pip install requests \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install psycopg2 \
    && pip install celery>=4.0.0 \
    && pip install flower>=0.7.3 \
    && pip install Flask-WTF==0.14 \
    && pip install click \
    && pip install 'redis>=2.10.5,<3' \
    && pip install kubernetes \
    && pip install git+https://github.com/apache/airflow.git \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY ./dags ${AIRFLOW_HOME}/dags

# Trying to get Kubernetes workers to load our dags
COPY ./dags /tmp/dags


RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]

# sets default arg for entrypoint
CMD ["webserver"]
