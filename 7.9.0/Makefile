# which service (from docker-compose.yml:services) to run commands agains
SERVICE ?=

EXEC_ARGS ?=
RUN_ARGS ?=
DOWN_ARGS ?= --remove-orphans
BUILD_ARGS ?=

include .env
export

COMPOSE_FILE_ARGS ?= -f $(CURDIR)/docker-compose.yml

DOCKER_COMPOSE = docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME)

ifeq ($(shell uname -s),Darwin)
XARGS_OPTS =
else
XARGS_OPTS = -r
endif

build:
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) build --no-cache jira

push: build
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) push jira

up: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) up $(UP_ARGS) ${SERVICE}

logs: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) logs --tail=100 -f

stop: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) stop ${SERVICE}

rm: stop
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) rm -f ${SERVICE}

restart: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) restart $(SERVICE)

recreate: env-check
	$(DOCKER_COMPOSE) up -d --force-recreate --build jira

down: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) down $(DOWN_ARGS)

exec: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec -T $(SERVICE) $(EXEC_ARGS)

bash: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec $(SERVICE) bash

jira: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec jira bash

psql: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec $(SERVICE) psql -U jira

ps:
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) ps

env-check:
ifeq ($(shell uname -s),Darwin)
	ifconfig lo0 | grep -qF '$(BIND_IP)' || sudo ifconfig lo0 alias $(BIND_IP)
endif

.PHONY: %
.DEFAULT: run