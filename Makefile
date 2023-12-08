export
PROJECT_PATH=$(shell pwd)
APPLICATION=baas
network=$(APPLICATION)

NGINX_IMAGE=nginx
NGINX_IMAGE_TAG=1.25.3
NGINX_PORT=5050
NGINX_DEFAULT_CONFIG_FILE=$(PROJECT_PATH)/src/nginx/configs/default.conf
NGINX_CONFIG_FILE=$(PROJECT_PATH)/src/nginx/configs/nginx.conf

ELASTICSEARCH_IMAGE=elasticsearch
ELASTICSEARCH_IMAGE_TAG=8.11.1
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_PORT_9300=9300

KIBANA_IMAGE=kibana
KIBANA_IMAGE_TAG=8.11.1
KIBANA_PORT=5601

FILEBEAT_IMAGE=filebeat
FILEBEAT_IMAGE_TAG=8.11.1
LOG_FOLDER=/export/var/log/$(APPLICATION)
FILEBEAT_CONFIG_FILE=$(PROJECT_PATH)/src/filebeat/configs/filebeat.yml

SUBDIRS := $(wildcard $(PROJECT_PATH)/src/*)

.PHONY: all
all: deploy

.PHONY: create-network
network:
	-docker network create $(network)

.PHONY: remove-container
remove-container:
	-docker-compose down

.PHONY: build $(SUBDIRS)
build: $(SUBDIRS)
	git submodule update --init --recursive --remote
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir build; \
	done

.PHONY: deploy
deploy: network remove-container 
	docker-compose up -d

.PHONY: restart
restart:
	docker-compose restart $(service)

.PHONY: git-push
git-push:
	@for remote in $$(git remote); do \
		echo "Pushing to $$remote"; \
        git push $$remote; \
	done