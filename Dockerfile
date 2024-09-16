FROM ubuntu:20.04

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
  apt-get install -y \
  tzdata \
  python3 \
  python3-pip \
  git \
  gosu \
  postgresql \
  postgresql-contrib \
  postgis \
  libpq-dev \
  python3-dev \
  curl \
  gnupg \
  nodejs \
  npm \
  nginx \
  openssh-client \
  gdal-bin \
  python3-gdal && \
  rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
RUN python3 -m pip install --upgrade pip setuptools
RUN python3 -m pip install pipenv

ENV LANG C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_DB_HOST=db
ENV DJANGO_DB_PORT=5432
ENV DJANGO_DB_NAME=man_db
ENV DJANGO_DB_USER=man_user
ENV DJANGO_DB_PASS=Y8ksKX2uqdHEepzW8s9*vX@LbANPVbrQgfgzpRgP@dJATFKCfQ6de@n3g6GYeL-yrh3Mp!CKa-hQdUM
ENV DJANGO_SECRET_KEY=64*39&)axn)l1ik_90h=yz(8#ttn^wo%%y&$ed+y*r2l(9v--@s
ENV AWS_PUB_DNS=127.0.0.1

WORKDIR /app

RUN git clone https://github.com/rell/man.git .

WORKDIR /app/backend
RUN pipenv install --deploy --ignore-pipfile

WORKDIR /app/frontend
RUN npm install && \
  npm run build

WORKDIR /app
COPY setup_postgres.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_postgres.sh && \
  /usr/local/bin/setup_postgres.sh

EXPOSE 8000
EXPOSE 3000

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["bash", "-c", "cd /app/backend && pipenv run python manage.py populate && pipenv run gunicorn -b 0.0.0.0:8000 maritimeapp.wsgi:application & cd /app/frontend && npm start & nginx -g 'daemon off;'"]
