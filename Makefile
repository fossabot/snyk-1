# REQUIRED SECTION
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
include $(ROOT_DIR)/.mk-lib/common.mk
# END OF REQUIRED SECTION

ifeq "$(SWARM)" "true"
else
	ifneq (,$(wildcard ../.env))
		include ../.env
		export
	endif
endif

# vars
# BUILD_DIR := docker-nestjs-environment/
DOCKERFILE := Dockerfile
COMPOSE_BASE := docker-compose-base.yml
COMPOSE_DEV := docker-compose-dev.yml
COMPOSE_PROD := docker-compose-prod.yml
COMPOSE_LOCAL_PROD := docker-compose-prod-local.yml

COMPOSE_POSTGRES := docker-compose-postgres.yml
COMPOSE_POSTGRES_LOCAL := docker-compose-postgres-local.yml
COMPOSE_POSTGRES_STORAGE := docker-compose-postgres-storage.yml
COMPOSE_POSTGRES_NETWORK := docker-compose-prod-network-db.yml
COMPOSE_POSTGRES_BACKUP := docker-compose-postgres-db-backup.yml
COMPOSE_TRAEFIK := docker-compose-traefik.yml
COMPOSE_TRAEFIK_NETWORK := docker-compose-prod-network-traefik.yml
COMPOSE_KONG_NETWORK := docker-compose-prod-network-kong.yml
COMPOSE_MIGRATIONS := docker-compose-migrations.yml
COMPOSE_MIGRATIONS_DEV := docker-compose-migrations-dev.yml
ifeq "$(SWARM)" "true"
	ifeq "$(MIGRATIONS)" "true"
		ENABLED_MIGRATIONS := -c $(COMPOSE_MIGRATIONS)
		ENABLED_MIGRATION_LOCALPROD := -f $(COMPOSE_MIGRATIONS)
	else
		ENABLED_MIGRATIONS :=
		ENABLED_MIGRATION_LOCALPROD :=
	endif
	ifeq "$(POSTGRES)" "true"
		ifeq "$(CI_ENVIRONMENT_SLUG)" "prod"
			ENABLED_POSTGRES := -c $(COMPOSE_POSTGRES) -c $(COMPOSE_POSTGRES_STORAGE) -c $(COMPOSE_POSTGRES_NETWORK) -c $(COMPOSE_POSTGRES_BACKUP)
			ENABLED_POSTGRES_LOCALPROD := -f $(COMPOSE_POSTGRES) -f $(COMPOSE_POSTGRES_STORAGE) -f $(COMPOSE_POSTGRES_NETWORK) -f $(COMPOSE_POSTGRES_BACKUP)
		else
			ENABLED_POSTGRES := -c $(COMPOSE_POSTGRES) -c $(COMPOSE_POSTGRES_STORAGE) -c $(COMPOSE_POSTGRES_NETWORK)
			ENABLED_POSTGRES_LOCALPROD := -f $(COMPOSE_POSTGRES) -f $(COMPOSE_POSTGRES_STORAGE) -f $(COMPOSE_POSTGRES_NETWORK)
		endif
	else
		ENABLED_POSTGRES :=
		ENABLED_POSTGRES_LOCALPROD :=
	endif
	ifeq "$(TRAEFIK)" "true"
		ENABLED_TRAEFIK := -c $(COMPOSE_TRAEFIK) -c $(COMPOSE_TRAEFIK_NETWORK)
		ENABLED_TRAEFIK_LOCALPROD := -f $(COMPOSE_TRAEFIK) -f $(COMPOSE_TRAEFIK_NETWORK)
	else
		ENABLED_TRAEFIK :=
		ENABLED_TRAEFIK_LOCALPROD :=
	endif
	ifeq "$(KONG_NETWORK)" "true"
		ENABLED_KONG := -c $(COMPOSE_KONG_NETWORK)
		ENABLED_KONG_LOCALPROD := -f $(COMPOSE_KONG_NETWORK)
	else
		ENABLED_KONG :=
		ENABLED_KONG_LOCALPROD :=
	endif
else
	ifeq "$(MIGRATIONS)" "true"
		ENABLED_MIGRATIONS := -f $(COMPOSE_MIGRATIONS) -f $(COMPOSE_MIGRATIONS_DEV)
		ENABLED_MIGRATION_LOCALPROD := -f $(COMPOSE_MIGRATIONS)
	else
		ENABLED_MIGRATIONS :=
		ENABLED_MIGRATION_LOCALPROD :=
	endif
	ifeq "$(POSTGRES)" "true"
		ENABLED_POSTGRES := -f $(COMPOSE_POSTGRES) -f $(COMPOSE_POSTGRES_LOCAL)
		ENABLED_POSTGRES_LOCALPROD := -f $(COMPOSE_POSTGRES) -f $(COMPOSE_POSTGRES_LOCAL)
	else
		ENABLED_POSTGRES :=
		ENABLED_POSTGRES_LOCALPROD :=
	endif
	ENABLED_TRAEFIK :=
	ENABLED_TRAEFIK_LOCALPROD :=
	ENABLED_KONG :=
	ENABLED_KONG_LOCALPROD :=
endif
COMPOSE_MINIO := docker-compose-minio.yml
ifeq "$(MINIO)" "true"
	ENABLED_MINIO := -f $(COMPOSE_MINIO)
else ifeq "$(SWARM)" "true" 
	ENABLED_MINIO :=
else
	ENABLED_MINIO :=
endif

DEV := -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) $(ENABLED_POSTGRES) $(ENABLED_MINIO) $(ENABLED_MIGRATIONS)
LOCAL_PROD := -f $(COMPOSE_BASE) -f $(COMPOSE_PROD) -f $(COMPOSE_LOCAL_PROD) $(ENABLED_POSTGRES_LOCALPROD) $(ENABLED_MINIO) $(ENABLED_MIGRATION_LOCALPROD)
DCOMPOSE_PROD := -f $(COMPOSE_BASE) -f $(COMPOSE_PROD) $(ENABLED_POSTGRES_LOCALPROD) $(ENABLED_MINIO) $(ENABLED_TRAEFIK_LOCALPROD) $(ENABLED_KONG_LOCALPROD) $(ENABLED_MIGRATION_LOCALPROD)
STACK_PROD := -c $(COMPOSE_BASE) -c $(COMPOSE_PROD) $(ENABLED_POSTGRES) $(ENABLED_TRAEFIK) $(ENABLED_KONG) $(ENABLED_MIGRATIONS)

# DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_FILE)

.PHONY: help dependencies build up up-bg start stop restart status ps clean login-api login-nginx db-shell logs logs-api



dev: ##@localdev Build and Up all or c=<name> containers in background
	@$(DOCKER_COMPOSE) $(DEV) up --build --remove-orphans $(c)

build: ##@localdev Build all or c=<name> containers
	@$(DOCKER_COMPOSE) $(DEV) build $(c)

up: ##@localdev Start all or c=<name> containers in foreground
	@$(DOCKER_COMPOSE) $(DEV) up -d $(c)

down: ##@localdev Down all or c=<name> containers
	@$(DOCKER_COMPOSE) $(DEV) down $(c)

restart: ##@localdev Restart all or c=<name> containers
	@$(DOCKER_COMPOSE) $(DEV) stop $(c)
	@$(DOCKER_COMPOSE) $(DEV) up -d $(c)

status: ##@localdev Show status of containers
	@$(DOCKER_COMPOSE) $(DEV) ps

ps: status ##@localdev Alias of status

validateconf: ##@tests validate docker-compose conf in local
	@$(DOCKER_COMPOSE) $(DEV) config -q

clean: confirm ##@localdev Clean all data
	@$(DOCKER_COMPOSE) $(DEV) down

logs: ##@localdev Docker logs all services or c=<name>
	@$(DOCKER_COMPOSE) $(DEV) logs --tail=100 $(p) $(c)

top: ##@localdev containers processes
	@$(DOCKER_COMPOSE) $(DEV) top

shell: ##@localdev join to container shell
	@$(DOCKER_COMPOSE) $(DEV) exec api /bin/sh

env: ##@localdev generates env from examploe
	cp .env-sample ../.env

migrations: ##@localdev run migrations
	@$(DOCKER_COMPOSE) $(DEV) up -d migrations

prod-validateconf: ##@production validate docker-compose configuration
	@$(DOCKER_COMPOSE) $(DCOMPOSE_PROD) config -q

prod-build: ##@production build docker image in production
	@$(DOCKER_COMPOSE) $(DCOMPOSE_PROD) build

prod-push: ##@production push production docker image to registry
	@$(DOCKER_COMPOSE) $(DCOMPOSE_PROD) push

prod-deploy-swarm: ##@production deploy in docker swarm - use app=APP_NAME
	docker stack deploy $(STACK_PROD) --with-registry-auth $(app)

local-prod: ##@tests deploy container without volumes of local dev and networks
	@$(DOCKER_COMPOSE) $(LOCAL_PROD) up --build

local-prod-top: ##@tests deploy container without volumes of local dev and networks
	@$(DOCKER_COMPOSE) $(LOCAL_PROD) top

local-validate-prod: ##@tests test local prod conf
	@$(DOCKER_COMPOSE) $(LOCAL_PROD) config -q

local-lint: ##@tests running yarn lint
	@$(DOCKER_COMPOSE) $(DEV) exec api yarn lint

gitlab-create-env: ##@gitlab-ci create env for deploy variables in gitlab CI
	cp gitlab-deploy-vars-sample .env

gitlab-deploy-vars: ##@gitlab-ci deploy variables in Gitlab of project
	ansible-playbook gitlab-deploy-vars.yaml -v 

