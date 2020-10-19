# RMG Media PHP Docker Image

This image is an extension of the official PHP image, opinionated for RMG Media development needs

## Environment variables
The following environment variables should be set when running this image: 

### Outbound Email via MSMTP

* MSMTP_HOST - SMTP relay host
* MSMTP_PORT - SMTP relay port
* MSMTP_USER - SMTP relay user
* MSMTP_PASSWORD - SMTP relay password
* MSMTP_FROM - From email address. This is not the sender envelope and does not include a full name.

### How to build, test, and push this image

#### Set up

Copy the dist environment file, then adjust settings as needed.
```bash
cp .env.dist .env
```

#### Build & Run

```bash
TAG=rmgmedia/php:7.4-fpm
docker build --tag "$TAG" .
CONTAINER_ID=$(docker run --env-file .env --rm -d "$TAG")
```

#### Test

```bash
docker exec -it "$CONTAINER_ID" /bin/bash
docker kill "$CONTAINER_ID"
```

#### Push tag to Dockerhub

```bash
docker push "$TAG"
```
