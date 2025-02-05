import multiprocessing

# Number of workers
workers = (2 * multiprocessing.cpu_count()) + 1

# Worker class - 'sync' for CPU-bound, 'gevent' for I/O-bound
worker_class = 'sync'
threads = 4
timeout = 30

# Keep-alive
keepalive = 2

# Maximum number of requests a worker will process before restarting
max_requests = 400 
max_requests_jitter = 50

# Logging
accesslog = '/app/backend/log/gunicorn/accesslog'
errorlog = '/app/backend/log/gunicorn/errorlog'
loglevel = 'debug'
acesslogformat ="%(h)s %(l)s %(u)s %(t)s %(r)s %(s)s %(b)s %(f)s %(a)s"
bind = '0.0.0.0:8000'

# Enable the preload app feature
preload_app = True

# Enable the reloading feature (useful during development)
# remove this in production
reload = False
