#!/usr/bin/env bash

# Copy the binaries
cp -r -v ./target/livescore-demo-vertx-amqp-bridge-rest-style-1.0-SNAPSHOT/livescore-demo-vertx-amqp-bridge-rest-style-1.0-SNAPSHOT ./Dockerfile/livescore-demo-vertx-amqp-bridge-rest-style-1.0-SNAPSHOT

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
docker build -t scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT} ./Dockerfile/
docker tag scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT} docker.io/scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT}
docker push scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT}
docker tag scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT} docker.io/scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_BRANCH}
docker push scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_BRANCH}
docker tag scholzj/livescore-demo-vertx-amqp-bridge-rest-style:${TRAVIS_COMMIT} docker.io/scholzj/livescore-demo-vertx-amqp-bridge-rest-style:latest
docker push scholzj/livescore-demo-vertx-amqp-bridge-rest-style:latest

# Delete the binaries
rm -rf ./Dockerfile/livescore-demo-vertx-amqp-bridge-1.0-SNAPSHOT