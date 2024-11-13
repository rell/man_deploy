FROM python:3.12

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Etc/UTC

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
 apt-get install -y --no-install-recommends \
        software-properties-common \
        tzdata \
        git \
        gosu \
        postgresql-client \
        postgis \
        postgresql-15-postgis-3 \
        libpq-dev \
        curl \
        gnupg \
        nodejs \
        npm \
        git \
        nginx \
        openssh-client \
        gdal-bin \
        python3-gdal \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libdb5.3-dev \
        libbz2-dev \
        libexpat1-dev \
        liblzma-dev \
        libffi-dev \
        tar \
        cron \
        wget && \
    apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

RUN python3.12 -m pip install --upgrade pip setuptools pipenv
RUN groupadd -r nginx && useradd -r -g nginx nginx

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_DB_HOST=db
ENV DJANGO_DB_PORT=5432
ENV DJANGO_DB_NAME=man_db
ENV DJANGO_DB_USER=man_user
ENV DJANGO_DB_PASS=Y8ksKX2uqdHEepzW8s9*vX@LbANPVbrQgfgzpRgP@dJATFKCfQ6de@n3g6GYeL-yrh3Mp!CKa-hQdUM
ENV DJANGO_SECRET_KEY=64*39&)axn)l1ik_90h=yz(8#ttn^wo%%y&$ed+y*r2l(9v--@s
# ENV AWS_PUB_DNS=36.172.116.118
# ENV AWS_PUB_DNS=128.183.160.250
ENV AWS_PUB_DNS=localhost

WORKDIR /app

RUN git clone https://github.com/rell/man.git .

WORKDIR /app/backend

RUN curl -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
  && chmod +x /usr/local/bin/wait-for-it.sh

COPY config.ini /app/backend/
RUN pipenv install --deploy --ignore-pipfile

WORKDIR /app/frontend
COPY config.ts /app/frontend/src/
RUN npm install && \
  npm run build

WORKDIR /app
COPY setup_postgres.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_postgres.sh && \
  /usr/local/bin/setup_postgres.sh

EXPOSE 8000
EXPOSE 3000

COPY cron-scripts/update_git /app/scripts/update_git.sh
COPY cron-scripts/update_and_pop /app/scripts/update_and_pop.sh
COPY cron-scripts/man_crontab /etc/cron.d/man_crontab
COPY entrypoint /usr/local/bin/entrypoint.sh
RUN chmod +x /app/scripts/update_git.sh
RUN chmod +x /app/scripts/update_and_pop.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod 0644 /etc/cron.d/man_crontab
# RUN crontab /etc/cron.d/man_crontab
