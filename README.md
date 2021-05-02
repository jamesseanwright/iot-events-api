# Terraform Lambda Atlas

A REST API for storing and retrieving IoT device events, built with Terraform, AWS Lambda, and MongoDB Atlas.

## Running Locally

Ensure [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) are present on your system. You can then run `docker-compose up`.

### Example Requests

#### Adding a New Event

```sh
$ curl -XPOST "http://localhost:9001/2015-03-31/functions/function/invocations" -d '{ "body": "{ \"date\": \"'$(date --iso-8601=seconds --utc)'\", \"deviceID\": \"8f188304-e7b3-4a16-a243-b9470468478a\", \"eventType\": \"temp_celcius\", \"value\": 4 }" }'
```

#### Retrieving events for a given device ID by event type and date

```sh
$ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{ "queryStringParameters": { "deviceID": "8f188304-e7b3-4a16-a243-b9470468478a", "date": "'$(date --iso-8601=date)'", "eventType": "temp_celcius" } }'
```

## Deploying to AWS and MongoDB Atlas (WIP)

- Will need to run:

```sh
$ aws ecr get-login-password --region <AWS region> | docker login --username AWS --password-stdin <AWS account ID>.dkr.ecr.<AWS region>.amazonaws.com
```

before running `terraform apply`

## Schema Design

TODO
