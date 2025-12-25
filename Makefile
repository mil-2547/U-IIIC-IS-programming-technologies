
_version_file := VERSION

ifeq ($(OS),Windows_NT)
	PLATFORM       := Windows
    VERSION_SCRIPT := scripts/increment-version.cmd
	NULL           := nul
	FIXPATH         = $(subst /,\,$(1))
	READ_VER        = $(shell if exist "$(call FIXPATH,$(_version_file))" (type "$(call FIXPATH,$(_version_file))") else (echo 1.0))
else
	PLATFORM       := Unix
    VERSION_SCRIPT := scripts/increment-version.sh
	NULL           := /dev/null
	FIXPATH         = $(1)
	READ_VER        = $(shell cat "$(_version_file)" 2>$(NULL) || echo 1.0)
endif

_image_name := lab4-jenkins
_image_tag   = $(strip $(READ_VER))
_jenkins_id := $(firstword $(shell docker compose ps -q 2>$(NULL)))


.PHONY: all build up down version info key logs

all: greeter build up


greeter:
	@echo [INFO] Platform: $(PLATFORM)

version:
    @echo [INFO] Old Version: $(strip $(READ_VER))
    @$(VERSION_SCRIPT)
	$(_image_tag) := $(strip $(READ_VER))
    @echo [INFO] New Version: $(_image_tag)

build: version
	@echo [DOCKER] Building image $(_image_name):$(_image_tag)...
	docker build -t $(_image_name):$(_image_tag) .

up:
	@echo [DOCKER] Starting compose...
	docker compose up -d
	@echo [INFO] System is up :: running $(_image_name):$(_image_tag)

down:
	@echo [DOCKER] Stopping...
	docker compose down
	@echo [INFO] Stopped.

info:
    @echo ========================================
    @echo Image:     $(_image_name):$(_image_tag)
	ifeq ($(OS),Windows_NT)
	@if "$(_jenkins_id)"=="" ( \
		echo Container: NOT RUNNING \
	) else ( \
		echo Container ID: $(_jenkins_id) && \
		docker inspect --format "Status: {{.State.Status}} (Started: {{.State.StartedAt}})" $(_jenkins_id) \
	)
	else
	@if [ -z "$(_jenkins_id)" ]; then \
		echo "Container: NOT RUNNING"; \
	else \
		echo "Container ID: $(_jenkins_id)"; \
		docker inspect --format 'Status: {{.State.Status}} (Started: {{.State.StartedAt}})' "$(_jenkins_id)"; \
	fi
	endif
    @echo ========================================

key:
	ifeq ($(OS),Windows_NT)
	@if "$(_jenkins_id)"=="" ( \
		echo [ERROR] Container not running. Run 'make up' first. && exit 1 \
	)
	else
	@if [ -z "$(_jenkins_id)" ]; then \
        echo "[ERROR] Container not running. Run 'make up' first."; exit 1; \
    fi
	endif
	@echo [SECRET] Initial Admin Password:
	@docker exec $(_jenkins_id) cat /var/jenkins_home/secrets/initialAdminPassword

logs:
    @if "$(_jenkins_id)"=="" ( \
        echo [WARN] No container running. \
    ) else ( \
        docker logs -f $(_jenkins_id) \
    )
