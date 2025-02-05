FROM python:3.12

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Etc/UTC
ENV SHELL=/bin/bash

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
RUN npm install -g pnpm

ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

RUN python3.12 -m pip install --upgrade pip setuptools pipenv
RUN groupadd -r nginx && useradd -r -g nginx nginx

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_DB_HOST=db
ENV DJANGO_DB_PORT=5432
ENV DJANGO_DB_NAME=man_db
ENV DJANGO_DB_USER=man_user
ENV DJANGO_DB_PASS=e3KR3B*AQqTMa4suUGVnbyyx-7s@Bex!vGF2zh2xkN6hiKXFrNCH4UeFpTVK8BDdp-_Qv48aj@MP7UQ!M.BUi*-*49r-vNyNrBwH
ENV DJANGO_SECRET_KEY=5hi_*o@$4pf@f078gzwxx3erernbh0fbw=_am9xf=5-88o_w(5
# ENV AWS_PUB_DNS=36.172.116.118
ENV AWS_PUB_DNS=128.183.160.250
# ENV AWS_PUB_DNS=localhost

# START-DIR
WORKDIR /app
RUN git clone https://github.com/rell/aeronet_man.git .

# BACK-END
WORKDIR /app/backend
RUN curl -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
  && chmod +x /usr/local/bin/wait-for-it.sh
COPY config.ini /app/backend/
RUN pipenv install --deploy --ignore-pipfile
RUN mkdir -p /app/backend/log/gunicorn/
RUN mkdir -p /app/backend/log/django/

# FRONT-END
WORKDIR /app/frontend
RUN   pnpm i

# POSTGRESQL
WORKDIR /app
COPY setup_postgres.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_postgres.sh && \
  /usr/local/bin/setup_postgres.sh

# PORTS
EXPOSE 8000
EXPOSE 3000


# SCRIPTS (INACTIVE)
COPY cron-scripts/update_git /app/scripts/update_git.sh
COPY cron-scripts/update_and_pop /app/scripts/update_and_pop.sh
COPY cron-scripts/man_crontab /etc/cron.d/man_crontab
COPY entrypoint /usr/local/bin/entrypoint.sh
RUN chmod +x /app/scripts/update_git.sh
RUN chmod +x /app/scripts/update_and_pop.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod 0644 /etc/cron.d/man_crontab
# RUN crontab /etc/cron.d/man_crontab
