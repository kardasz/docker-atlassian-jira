# which service (from docker-compose.yml:services) to run commands agains
SERVICE ?=

EXEC_ARGS ?=
RUN_ARGS ?=
DOWN_ARGS ?= --remove-orphans
BUILD_ARGS ?=

include .env
export

COMPOSE_FILE_ARGS ?= -f docker-compose.yml

DOCKER_COMPOSE = docker-compose $(COMPOSE_FILE_ARGS)

ifeq ($(shell uname -s),Darwin)
XARGS_OPTS =
else
XARGS_OPTS = -r
endif

build:
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) build jira

push: build
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) push jira

up: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) up $(UP_ARGS) ${SERVICE}

logs: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) logs --tail=100 -f

stop: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) stop ${SERVICE}

rm: stop
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) rm -f ${SERVICE}

restart: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) restart $(SERVICE)

recreate: env-check
	$(DOCKER_COMPOSE) up -d --force-recreate --build jira

down: env-check
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) down $(DOWN_ARGS)

exec: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) exec -T $(SERVICE) $(EXEC_ARGS)

bash: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) exec $(SERVICE) bash

jira: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) exec jira bash

psql: up
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) exec $(SERVICE) psql -U jira

ps:
	$(COMPOSE_ENV) docker-compose $(COMPOSE_FILE_ARGS) ps

env-check:
ifeq ($(shell uname -s),Darwin)
	ifconfig lo0 | grep -qF '$(BIND_IP)' || sudo ifconfig lo0 alias $(BIND_IP)
endif

.PHONY: %
.DEFAULT: run