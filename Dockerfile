#
# This Dockerfile is used to build a Docker image for Airflow that contains all
# dependencies and DAGs. This same image is used for the scheduler, webserver,
# and workers.
#
# It's based on the ones in the Airflow repository:
#
# https://github.com/apache/airflow/blob/master/Dockerfile
# https://github.com/apache/airflow/blob/master/scripts/ci/kubernetes/docker/Dockerfile
#
# It also borrows from Puckel's popular image:
#
# https://github.com/puckel/docker-airflow
#
# The major differences:
#
# 1. Airflow is installed directly from the master branch instead of the tagged
#    releases.  This involves cloning the code from Github into the image and
#    building the frontend with npm.
#
# 2. Dependencies were added for ethereum-etl and bitcoin-etl.
#
#

FROM python:3.6-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Dependences required for the build but not at runtime
ARG buildDeps="\
    freetds-dev \
    libczmq-dev \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    git \
    nodejs"

# Dependencies required by Airflow at runtime
ARG APT_DEPS="\
    $buildDeps \
    bind9utils \
    libsasl2-dev \
    freetds-bin \
    build-essential \
    default-libmysqlclient-dev \
    inetutils-telnet \
    apt-utils \
    curl \
    rsync \
    netcat \
    locales \
    wget \
    zip \
    unzip"

# Dependencies installed via pip
ARG PYTHON_DEPS="\
    pytz \
    cryptography \
    requests \
    pyOpenSSL \
    ndg-httpsclient \
    pyasn1 \
    psycopg2-binary \
    Flask-Bcrypt \
    Flask-WTF==0.14 \
    click \
    kubernetes \
    setuptools \
    wheel"

# http://airflow.apache.org/installation.html
ARG AIRFLOW_DEPS="postgres,s3,devel"
ARG AIRFLOW_HOME=/usr/local/airflow

# Required by ethereum-etl
ARG ETHEREUM_ETL_DEPS="\
    google-api-python-client \
    httplib2 \
    bitcoin-etl \
    ethereum-etl \
    mythril \
    pyetherchain \
    pandas \
    pandas-gbq"

ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

WORKDIR /opt/

RUN set -ex \
    # Update our currently installed packages
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    # Install Airflow dependencies
    && apt install -y $APT_DEPS \
    && pip install --upgrade pip \
    && pip install --no-cache-dir ${PYTHON_DEPS} \
    # Get the master branch of Airflow from Github
    && git clone --depth=1 https://github.com/apache/airflow.git \
    # Build the Airflow frontend
    && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get install -y nodejs \
    && npm --prefix /opt/airflow/airflow/www install /opt/airflow/airflow/www \
    && npm --prefix /opt/airflow/airflow/www run-script build \
    # Install Airflow from source
    && pip install --no-cache-dir -e /opt/airflow[$AIRFLOW_DEPS] \
    # Required by Airflow S3 Hook
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install boto3 \
    # Change the local to UTF-8
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    # Required by ethereum-etl-airflow
    && pip install --no-cache-dir ${ETHEREUM_ETL_DEPS} \
    # Remove unncessary files from this layer
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

WORKDIR ${AIRFLOW_HOME}

COPY airflow/entrypoint.sh /entrypoint.sh
COPY airflow/config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY ./airflow/dags ${AIRFLOW_HOME}/dags

# Trying to get Kubernetes workers to load our dags
COPY ./airflow/dags /tmp/dags

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
ENTRYPOINT ["/entrypoint.sh"]

# sets default arg for entrypoint
CMD ["webserver"]
