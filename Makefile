.DEFAULT_GOAL := help
SUBMAKE := $(MAKE) --no-print-directory

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
LOCAL_FLUTTER := $(abspath ./.flutter/bin/flutter.bat)
LOCAL_DART := $(abspath ./.flutter/bin/dart.bat)
MELOS := call "$(LOCAL_DART)" run melos
FLUTTER_BIN_DIR := $(if $(wildcard $(LOCAL_FLUTTER)),$(patsubst %/,%,$(dir $(LOCAL_FLUTTER))),)
PATH_SEP := ;
BASE_PATH := $(strip $(shell powershell -NoProfile -Command "$$machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine'); $$user = [System.Environment]::GetEnvironmentVariable('Path', 'User'); [Console]::Write($$machine + ';' + $$user)"));$(PATH)
BLANK_LINE := @echo.
define run_script
	@call scripts\$(1).cmd $(2)
endef
else
SHELL := /bin/bash
LOCAL_FLUTTER := $(abspath ./.flutter/bin/flutter)
LOCAL_DART := $(abspath ./.flutter/bin/dart)
MELOS := "$(LOCAL_DART)" run melos
FLUTTER_BIN_DIR := $(if $(wildcard $(LOCAL_FLUTTER)),$(patsubst %/,%,$(dir $(LOCAL_FLUTTER))),)
PATH_SEP := :
BASE_PATH := $(PATH)
BLANK_LINE := @echo
define run_script
	@bash scripts/$(1).sh $(2)
endef
endif

ifeq ($(MHABIT_MAKE_PATH_READY),)
PATH := $(if $(FLUTTER_BIN_DIR),$(FLUTTER_BIN_DIR)$(PATH_SEP),)$(BASE_PATH)
export PATH
export MHABIT_MAKE_PATH_READY := 1
endif

SYNC_RULES_FILE ?= docs/rules/rules.md


.PHONY: help init bootstrap \
	normalize-l10n build-runner format fix gen-icons test gen \
	verify-generated verify-submodules aio aio-full sync-rules unsync-rules \
	gen-screenshot-data

help:
	@echo Standardized automation entrypoints
	$(BLANK_LINE)
	@echo   init              Configure git hooks and aliases, initialize submodule, fetch packages
	@echo   bootstrap         Alias of init
	@echo   normalize-l10n    Normalize ARB resources
	@echo   build-runner      Run build_runner generators and gen-l10n
	@echo   format            Format Dart sources under lib and test
	@echo   fix               Apply Dart fixes and then format sources
	@echo   gen-icons         Generate icon fonts
	@echo   test              Run the root app and internal package test suites
	@echo   gen               Run the main generation workflow
	@echo   verify-generated  Ensure normalized/generated files are up to date
	@echo   verify-submodules Show recursive submodule status
	@echo   aio               Run generation, fixes, and generation verification
	@echo   aio-full          Run aio plus the root app and internal package test suites
	@echo "  sync-rules        Distribute rule references to AI tools (SYNC_RULES_FILE=docs/rules/rules.md)"
	@echo "  gen-screenshot-data  Generate seed JSON for screenshots (all langs)"

init:
	@git config --local core.hooksPath .githooks
	@echo "Git hooks path has been set!"
	-@git config --local --unset-all commit.template
	@echo "Legacy git commit.template has been cleared if it was set"
	@git config --local alias.cfix "commit -t .githooks/templates/bugfix.txt"
	@git config --local alias.cbump "commit -t .githooks/templates/bumpversion.txt"
	@echo "Git aliases configured: cfix, cbump"
	@git submodule update --init --recursive
	@echo "Submodules initialized"
	@$(MELOS) bootstrap
	@echo "Melos workspace bootstrapped"

bootstrap: init

verify-submodules:
	@git submodule status --recursive

normalize-l10n:
	$(call run_script,normalize_arb)

build-runner:
	@$(MELOS) run build-runner

format:
	@$(MELOS) run format

fix:
	@$(MELOS) run fix

gen-icons:
	$(call run_script,gen_icons)

test:
	@$(MELOS) run test

gen:
	@$(SUBMAKE) normalize-l10n
	@$(SUBMAKE) gen-icons
	@$(SUBMAKE) build-runner

verify-generated:
	$(call run_script,verify_generated)

sync-rules:
	$(call run_script,sync-rules,install $(SYNC_RULES_FILE))

unsync-rules:
	$(call run_script,sync-rules,uninstall)

gen-screenshot-data:
	@$(LOCAL_DART) run tools/bin/gen_screenshot_data.dart --all-langs

aio:
	@$(SUBMAKE) gen
	@$(SUBMAKE) fix
	@$(SUBMAKE) verify-generated

aio-full:
	@$(SUBMAKE) aio
	@$(SUBMAKE) test