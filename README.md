[![Build Status](https://travis-ci.org/scholzj/livescore-demo-vertx-amqp-bridge-rest-style.svg?branch=master)](https://travis-ci.org/scholzj/livescore-demo-vertx-amqp-bridge-rest-style)

# LiveScore service demo with Vert.x AMQP Bridge and Apache Qpid Dispatch with REST style API

This project demonstrates how can AMQP be used as an API for accessing services. It has a simple service for keeping live scores. The service allows to:
* add games
* update scores
* request score results
* receive live score updates

The service is using Apache Qpid Dispatch and Vert.x AMQP Bridge for the AMQP API. Dispatch is used as AMQP server, where AMQP clients can connect. AMQP Bridge in Vert.x connects to it as client and is used to send and receive messages.

## API

To send a request, send the message to the specific AMQP address. If reply-to address is specified, the service will send response to it. **This version of the service is using a REST style API.** The HTTP-like method which should be triggered is specified in the application property called `method`. All requests are sent to the same address `/scores`.

### Add new game

#### Request

* Send a message to endpoint `/scores`
* The request should have following application properties:
```
"method"="POST"
```
* The message payload should be in JSON format:
```json
{
  "homeTeam": "Aston Villa",
  "awayTeam": "Preston North End",
  "startTime": "14th January 2017, 17:30"
}
```

#### Response

In case of success:

* The response will contain application property `status` with value `201`
* The message payload will contain a JSON object with the created game:
```json
{
  "awayTeam": "Preston North End",
  "awayTeamGoals": 0,
  "gameTime": "0",
  "homeTeam": "Aston Villa",
  "homeTeamGoals": 0,
  "startTime": "Saturday 14th January 2017, 17:30"
}
```

In case of problems:
* The response will contain application property `status` with value `400`
* The message payload will contain a JSON object with the created game:
```json
{
  "error": "Game between Aston Villa and Preston North End already exists!"
}
```

### Update game score

#### Request

* Send a message to endpoint `/scores`
* The request should have following application properties:
```
"method"="PUT"
```
* The message payload should be in JSON format:
```json
{
  "homeTeam": "Aston Villa",
  "awayTeam": "Preston North End",
  "homeTeamGoals": 1,
  "awayTeamGoals": 0,
  "gameTime": "HT"
}
```

#### Response

In case of success:

* The response will contain application property `status` with value `200`
* The message payload will contain a JSON object with the updated game:
```json
{
  "awayTeam": "Preston North End",
  "awayTeamGoals": 1,
  "gameTime": "HT",
  "homeTeam": "Aston Villa",
  "homeTeamGoals": 0,
  "startTime": "Saturday 14th January 2017, 17:30"
}
```

In case of problems:
* The response will contain application property `status` with value `400`
* The message payload will contain a JSON object with the created game:
```json
{
  "error": "The home and away team goals have to be => 0!"
}
```

### Get game scores

#### Request

* Send a message to endpoint `/scores`
* The request should have following application properties:
```
"method"="GET"
```
* The message payload should be empty

#### Response

In case of success:

* The response will contain application property `status` with value `200`
* The message payload will contain a JSON array with the game results:
```json
[
  {
    "awayTeam": "Preston North End",
    "awayTeamGoals": 1,
    "gameTime": "HT",
    "homeTeam": "Aston Villa",
    "homeTeamGoals": 0,
    "startTime": "Saturday 14th January 2017, 17:30"
  }
]
```

### Receive live score updates

#### Subscribe

* To subscribe to live score updates, connect a receiver to `/liveScores`

#### Broadcasts

In case of success:

* The message payload will contain a JSON object with the game results:
```json
{
  "awayTeam": "Preston North End",
  "awayTeamGoals": 1,
  "gameTime": "HT",
  "homeTeam": "Aston Villa",
  "homeTeamGoals": 0,
  "startTime": "Saturday 14th January 2017, 17:30"
}
```

### API Examples

You can use the qpid-send and qpid-receive utilities from Apache Qpid project to communicate with the service from the command line:

* Create a new game
```bash
qpid-send -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "'/scores'" --property method=POST --content-string '{"homeTeam": "Aston Villa", "awayTeam": "Preston North End", "startTime": "Saturday 14th January 2017, 17:30"}'

```

* Update the score
```bash
qpid-send -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "'/scores'" --property method=PUT --content-string '{"homeTeam": "Aston Villa", "awayTeam": "Preston North End", "homeTeamGoals": 1, "awayTeamGoals": 0, "gameTime": "10"}'
qpid-send -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "'/scores'" --property method=PUT --content-string '{"homeTeam": "Aston Villa", "awayTeam": "Preston North End", "homeTeamGoals": 2, "awayTeamGoals": 0, "gameTime": "35"}'

```

* Get scores
```bash
qpid-receive -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "myReplyToAddress" -m 1 -f --print-headers yes &
qpid-send -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "'/scores'" --property method=GET --content-string '' --reply-to "myReplyToAddress"

```

* Subscribe to live updates
```bash
qpid-receive -b 127.0.0.1:5672 --connection-options "{protocol: amqp1.0}" -a "'/liveScores'" -f

```

## Kubernetes deployment

The `Kubernetes` directory contains YAML files which can be used for deployment into Kubernetes cluster. Use the `kubectl` utility to deploy it.

```bash
kubectl create -f config.yaml
kubectl create -f deployment.yaml
```
