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
  software-properties-common \
  nodejs \
  npm \
  pipenv \
  nginx \
  openssh-client \
  gdal-bin \
  python3-gdal && \
  rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_DB_HOST=db
ENV DJANGO_DB_PORT=5432
ENV DJANGO_DB_NAME=man_db
ENV DJANGO_DB_USER=man_user
ENV DJANGO_DB_PASS=Y8ksKX2uqdHEepzW8s9*vX@LbANPVbrQgfgzpRgP@dJATFKCfQ6de@n3g6GYeL-yrh3Mp!CKa-hQdUM

WORKDIR /app

RUN git clone https://github.com/rell/man.git .

WORKDIR /app/backend
RUN pipenv install --deploy --ignore-pipfile && \
  pipenv install gunicorn

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
