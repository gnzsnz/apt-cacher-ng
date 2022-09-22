# APT-Cacher-ng docker image

A docker image to run a local [apt-cacher-ng](https://www.unix-ag.uni-kl.de/~bloch/acng/) for your containers and servers.

## Build the Image <a name="build-image"></a>

To build the image you will need to edit the `.env-dist` file with your prefered setup

```bash
cp .env-dist .env
nano .env
```
Set UID and GID as per your needs. You can optionally define an apt proxy that will be used to build the docker image.
```
UID=1000
GID=1000
APT_PROXY=http://apt_proxy:3142
```

Run `docker-compose config` and check that everything looks good. To build the image using docker-compose you can do

```bash
docker compose build
```

Or with `docker build`

```bash
docker build --build-arg UID="$(id -u)" \
            --build-arg GID="$(id -g)" \
            -t gnzsnz/apt-cacher-ng:latest .
```
UID and GID are used to map the host user to the apt-cacher-ng user in the container. The image volumes will  use this UID and GID.

## Run apt-cacher-ng <a name="run-apt-cacher-ng"></a>

Simplest way would be `docker compose up`, you might modify the docker-compose.yml file provided to adjust it to your needs.

Or alternatively with
```bash
docker run -it gnzsnz/apt-cacher-ng:latest aptcacher
```
Your apt-cacher-ng should be available at [http://hostname:3142/]

## Setup clients <a name="setup-clients"></a>

To use the apt cache proxy you need to setup your clients. This can be done by running the following line on each client.

```bash
echo 'Acquire::http { Proxy "http://proxy:3142"; }' | sudo tee  /etc/apt/apt.conf.d/02proxy
sudo apt update
```

To use apt-cacher in your containers you need to define in your `Dockerfile`

```docker
ARG APT_PROXY
RUN echo 'Acquire::http { Proxy "'$APT_PROXY'"; }'  \
    | tee /etc/apt/apt.conf.d/02proxy &&\
    apt-get update && apt-get -y install ...
```

You will need to pass the apt-cache-ng address ARG to build the image,

```bash
docker build \
  --build-arg APT_PROXY="http://apt-cacher:3142" -t your/image .
```

I cover the steps in this [blog entry](https://gonzalosaenz.com/Docker%20Finger%20Food.html#use-an-apt-proxy-from-a-container).

## Clean up <a name="clean-up"></a>

To clean up everything

```bash
docker compose down --rmi all -v
```
