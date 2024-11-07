### Deployment Steps

Note before starting the following EC2 Security policy needs to be updated in order for access to be allowed within react and django ports.

Within the AWS EC2 Instance. Open the following ports within AWS EC2 Security Groups. 80 (HTTP), 443 (HTTPS, once implemented), 8000 (Django), 3000 (React)
<br>
<br>
Inbound Rules:

- Type: HTTP, Protocol: TCP, Port: 80, Source: 0.0.0.0/0
- Type: HTTPS, Protocol:TCP, Port: 443, Source: 0.0.0.0/0 (Not currently needed)
- Type: Custom TCP, Protocol: TCP, Port: 8080, Source: 127.0.0.1/0 # NGINX

After this is updated docker will need to be installed on the server in order to use the dockerfile. after downloading docker onto the server through a preferred method. start and enable docker.

```bash

# after docker has been installed
sudo systemctl start docker
sudo systemctl enable docker

```


Next Install docker-compose:

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

Next, update the following variables with the correct deployment IPv4 DNS

1.) https://github.com/rell/man_deploy/blob/main/config.ts

```bash
# change  API_BASE_URL
# Example: const API_BASE_URL = "http://10.0.0.1:8000";
const API_BASE_URL = "http://<your IPv4 DNS IP>:8000";
```
2.) https://github.com/rell/man_deploy/blob/main/Dockerfile

```bash
#  Example: ENV AWS_PUB_DNS=10.0.0.1
ENV AWS_PUB_DNS=<your IPv4 DNS IP>
````

Next run the setup script.

```bash
# Depending on privileges script may need to be modified by placing sudo infront of each docker/docker-compse command
./restart.sh # will remove all current docker instances and run docker with complete build

```

After a successful build

```bash
# run the following the run the docker instance as a daemon
docker-compose up -d
```

### Post configuration

After the dockerfile has successfully run. NGINX can be configured within the server to allow for the frontend to be served from the AWS EC2 url and the backend to be served from the AWS EC2 url/api/ instead of using ports.

#TODO: Make Apache Local Configuration
