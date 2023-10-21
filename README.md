# institute-person-api

## Table of Contents

- [Overview](#overview)
- [Prerequisits](#prerequisits)
- Getting Started [for API Engineers](#getting-started-for-api-engineers)
  - [Building the Database Container](#building-the-database-container)
  - [Install dependencies and run the API locally](#install-dependencies-and-run-the-api-locally)
- Getting Started [for UI Engineers](#getting-started-for-ui-engineers)
  - [Building and Run the API in one step](#bulid-and-run-in-one-step)
  - [Start the Containers without rebuilding](#start-the-containers-without-rebuilding)
  - [Stoping and Starting the containers without loosing data](#stoping-and-starting-the-containers-without-loosing-data)
  - [Restart the containers and Reseting the database](#restart-the-containers-and-reseting-the-database)
- Local API Testing with [CURL](#local-api-testing-with-curl)
  - [A word on ports](#a-word-on-ports)
  - [Test Config Endpoint](#test-config-endpoint)
  - [Test Health Endpoint](#test-health-endpoint)
  - [Test find all people with IDs](#test-find-all-people-with-ids)
  - [Test get a person](#test-get-a-person)
  - [Test add a person](#test-add-a-person)
  - [Test update a person](#test-update-a-person)
- [Observability and Configuration](#observability-and-configuration)
- [Backlog and Feature Branch info](#backlog-and-feature-branch-info)

## Overview

This is a simple GoLang API that was written by a polyglot software engineer with the help of ChatGPT, with only a cursory understaqnding of the Go language and MongoDB. See [here](https://chat.openai.com/share/dcb8b738-7e73-40da-8b08-38024f1c9997) for the chat that was used to start.

[Here](./product-api-openapi.yaml) is the Swagger for the API

[Here](https://github.com/orgs/agile-learning-institute/repositories?q=institute-person&type=all&sort=name) are the repositories in the person microservice.

[Here](https://github.com/orgs/agile-learning-institute/repositories?q=institute&type=all&sort=name) are all of the repositories in the [Institute](https://github.com/agile-learning-institute/institute/tree/main) system

## Prerequisits

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Go Language](https://go.dev/doc/install)
- [Mongo Compass](https://www.mongodb.com/try/download/compass) - if you want a way to look into the database

## Getting Started for API Engineers

### Building the Database Container

To run locally, you need to build the database container. Clone [this repo](https://github.com/agile-learning-institute/institute-mongodb) and follow the instructions to build the container. Once that container is built you can run it independently using the database docker compose option.

### Install dependencies and run the API locally

If you have started the database separatly, you can run the API locally

```bash
go get -u
go run main.go
```

### Generate fresh mocks

If you make substantial changes to the interfaces, you may need to regenerate gomock mocks used in unit testing.

```bash
mockgen -source=models/person.go -destination=mocks/mock_person.go -package=mocks
mockgen -source=models/person_store.go -destination=mocks/mock_person_store.go -package=mocks
```

## Getting Started for UI Engineers

If you want to run both the API and Database containers you can build the database container as described [above](#building-the-database-container), and then build the API container, and then use the docker compose command below to run both of them together.

### Bulid and Run in one step

To build and run both of the containers, first clone [data](https://github.com/agile-learning-institute/institute-mongodb) repo as a sibling to this repo, then you can run this script to build both the database and api containers and start the stack.

```bash
./docker-build-all.sh
```

### Start the Containers without rebuilding

```bash
docker compose up --detach
```

### Stoping and Starting the containers without loosing data

```bash
docker compose stop
docker compose start
```

### Restart the containers and Reseting the database

```bash
docker compose down
docker compose up --deatch
```

### Building the API Container

The containerization expects the go API to be compiled to a linux binary, and the PATCH_LEVEL file to contain the build hash. This has not bee tested on Apple silicone, or Windows. If you run ```docker-build.sh``` will run the following commands:

```bash
GOOS=linux GOARCH=amd64 go build -o "institute-person-api" main.go
export BRANCH=$(git branch --show-current)
export PATCH=$(git rev-parse $BRANCH)
echo $BRANCH.$PATCH > PATCH_LEVEL
docker build . --tag institute-person-api
```

## Local API Testing with CURL

### A word on ports

NOTE: If you are running the API from the command line with ```go run main.go``` the API will be served at port 8080, if you run the API in containers with ```docker compose up``` then it will be served at port 8081.
Adjust the following URI's accordingly.

### Test Config Endpoint

```bash
curl http://localhost:8081/api/config/

```

### Test Health Endpoint

This endpoint supports the promethius monitoring standards for a healthcheck endpoint

```bash
curl http://localhost:8081/api/health/

```

### Test find all people with IDs

```bash
curl http://localhost:8081/api/person/
```

### Test get a person

```bash
curl http://localhost:8081/api/person/[ID]

```

### Test add a person

```bash
curl -X POST http://localhost:8081/api/person/ \
     -d '{"name":"Foo", "description":"Some short description"}'

```

### Test update a person

```bash
curl -X PATCH http://localhost:8081/api/person/[ID] \
     -d '{"description":"Some long description"}'

```

## Observability and Configuration

The ```api/config/``` endpoint will return a list of configuration values. These values are either "defaults" or loaded from an Environment Variable, or found in a singleton configuration file of the same name. Environment Variables take precidence. The variable "CONFIG_FOLDER" will change the location of configuration files from the default of ```./```

The docker build expects a linux native binary, and a text file called PATCH_LEVEL to exist, I was unable to get the git commands to work in a 2-stage build, so I created [docker-build.sh](./docker-build.sh)

The PATCH_LEVEL file that is located in the same folder as the executable should be populated by CI with the hash of the commit-to-main that triggers CI. This will be used on the Version number reported by the /api/config/ endpoint.

## Backlog and Feature Branch info

- [X] Shift dependency injection to Config object Bad Idea!
  - injection-refactor branch
  - [X] Person-store delivers DB Version to Config
  - [X] ConfigHandler injects config
  - [X] Add unit testing of config-handler
- [x] Improved Error Handling & testing (data dependency)
  - [x] All PersonStore timeout and errors logged and thrown
  - [x] Handlers to catch and return errors
- [x] Add attributes from database v1.1.Test
- [x] Add CID to HTTP Error Responses
- [x] Return full document after patch
- [x] Gorilla Promethius Health endpoint
- [x] Add breadcrumbs
- [x] Refactor Person as Simple Class, PersonStore to abstract mongo specific dependencies
- [ ] Add beter unit testing of breadcrumbs
- [ ] Fix unit testing that uses byte[] for string comparisons
- [ ] Add JWT authentication

- [ ] Implement Store interfaces (Store(Collection), ReadStore, PostStore, PatchStore, ReadOnlyStore)
  - [ ] Refactor config to use list of collection objects {name, version, *Store}
  - [ ] Store Constructor with config & Collection name
  - [ ] ReadOnlyStore constructor with filter, projection - calls Store constructor
  - [ ] ReadStore, PostStore, PatchStore call Store(collection) constructor
  - [ ] Refactor person_store to implement ReadStore, PostStore, PatchStore and use new config
  - [ ] Move person_store GetNames, GetFiltered, GetOne, Patch, Post methods to XxxStore Interfaces
  - [ ] Refactor enum_handlers into ReadHandler with a config & collectionName injected.
  - [ ] Refactor-replace enumerator_store with ReadStore
  
- [ ] Implement readOnlyHandler with ReadOnlyStore getFiltered
  - [ ] Add get/mentors endpoint with readOnlyHandler
  - [ ] Add get/partners endpoint with readOnlyHandler
