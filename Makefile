# ==========================================
# CROSS-PLATFORM SETTINGS
# ==========================================

VERSION_FILE := assets/VERSION

# Defining OS and configuring commands
ifeq ($(OS),Windows_NT)
    # --- WINDOWS SETTINGS ---
    PLATFORM    := Windows
    SHELL       := cmd.exe
    NULL        := nul
    RM          := del /Q /F
    # Macro for replacing slashes (assets/file -> assets\file)
    FIXPATH     = $(subst /,\,$(1))
    # Version reading function (performed each time it is accessed)
    READ_VER    = $(shell if exist "$(call FIXPATH,$(VERSION_FILE))" (type "$(call FIXPATH,$(VERSION_FILE))") else (echo 1.0))
else
    # --- LINUX / MAC SETTINGS ---
    PLATFORM    := Unix
    SHELL       := /bin/sh
    NULL        := /dev/null
    RM          := rm -f
    FIXPATH     = $(1)
    READ_VER    = $(shell cat "$(VERSION_FILE)" 2>$(NULL) || echo 1.0)
endif

# [IMPORTANT] Use = to make Make reread the file in each new target
VERSION = $(strip $(READ_VER))

# Search for script
VERSION_SCRIPT := $(firstword \
    $(wildcard scripts/increment-version.cmd) \
    $(wildcard scripts/increment-version.sh) \
)

# Container ID
JENKINS_ID = $(firstword $(shell docker compose ps -q 2>$(NULL)))

# ==========================================
# TARGETS
# ==========================================

.PHONY: all build up down version info key logs clean

all: version build up info

# 1. Version management
version:
	@echo [INFO] Platform: $(PLATFORM)
	@echo [INFO] Old Version: $(VERSION)
ifeq ($(VERSION_SCRIPT),)
	$(error [ERROR] No version script found in scripts/ folder!)
endif
# Running the script
ifeq ($(OS),Windows_NT)
	@echo [EXEC] Running script for Windows...
	@if /I "$(suffix $(VERSION_SCRIPT))"==".cmd" call "$(call FIXPATH,$(VERSION_SCRIPT))"
	@if /I "$(suffix $(VERSION_SCRIPT))"==".sh"  sh "$(VERSION_SCRIPT)"
else
	@echo [EXEC] Running script for Unix...
	@sh "$(VERSION_SCRIPT)"
endif
	@REM Читаем файл напрямую через консоль, чтобы показать реальную новую версию
	@REM Вывод на одной строке
ifeq ($(OS),Windows_NT)
	@REM || verify >nul сбрасывает ошибку, которую выдает set /p
	@set /p="[INFO] New Version check: " <nul || verify >nul
	@type "$(call FIXPATH,$(VERSION_FILE))"
else
	@echo -n "[INFO] New Version check: "
	@cat "$(VERSION_FILE)"
endif

# 2. Build (Here, Make will reread $(VERSION) and substitute the correct value)
build: version
	@echo [DOCKER] Building image lab4-jenkins:$(VERSION)...
	docker build -t lab4-jenkins:$(VERSION) .

# 3. Launch
up:
	@echo [DOCKER] Starting compose...
	docker compose up -d
	@echo [INFO] System is up running lab4-jenkins:$(VERSION)

# 4. Stop
down:
	@echo [DOCKER] Stopping...
	docker compose down
	@echo [INFO] Stopped.

# 5. Information
info:
	@echo ========================================
	@echo Image:     lab4-jenkins:$(VERSION)
ifeq ($(OS),Windows_NT)
	@if "$(JENKINS_ID)"=="" ( \
		echo Container: NOT RUNNING \
	) else ( \
		echo Container ID: $(JENKINS_ID) && \
		docker inspect --format "Status: {{.State.Status}} (Started: {{.State.StartedAt}})" $(JENKINS_ID) \
	)
else
	@if [ -z "$(JENKINS_ID)" ]; then \
		echo "Container: NOT RUNNING"; \
	else \
		echo "Container ID: $(JENKINS_ID)"; \
		docker inspect --format 'Status: {{.State.Status}} (Started: {{.State.StartedAt}})' "$(JENKINS_ID)"; \
	fi
endif
	@echo ========================================

# 6. Admin Key
key:
ifeq ($(OS),Windows_NT)
	@if "$(JENKINS_ID)"=="" ( \
		echo [ERROR] Container not running. Run 'make up' first. && exit 1 \
	)
	@echo [SECRET] Initial Admin Password:
	@docker exec $(JENKINS_ID) cat /var/jenkins_home/secrets/initialAdminPassword
else
	@if [ -z "$(JENKINS_ID)" ]; then \
		echo "[ERROR] Container not running. Run 'make up' first."; exit 1; \
	fi
	@echo "[SECRET] Initial Admin Password:"
	@docker exec $(JENKINS_ID) cat /var/jenkins_home/secrets/initialAdminPassword
endif

# 7. Logs
logs:
ifeq ($(JENKINS_ID),)
	@echo [WARN] No container running.
else
	docker logs -f $(JENKINS_ID)
endif

clean:
	@echo [CLEAN] Removing version file...
	-$(RM) "$(call FIXPATH,$(VERSION_FILE))"
