.DEFAULT_GOAL := help
SUBMAKE := $(MAKE) --no-print-directory

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
LOCAL_FLUTTER := .flutter\bin\flutter.bat
FLUTTER_BIN_DIR := $(if $(wildcard .flutter/bin/flutter.bat),.flutter\bin,)
PATH_SEP := ;
BASE_PATH := $(strip $(shell powershell -NoProfile -Command "$$machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine'); $$user = [System.Environment]::GetEnvironmentVariable('Path', 'User'); [Console]::Write($$machine + ';' + $$user)"));$(PATH)
BLANK_LINE := @echo.
define run_script
	@call scripts\$(1).cmd
endef
else
SHELL := /bin/bash
LOCAL_FLUTTER := ./.flutter/bin/flutter
FLUTTER_BIN_DIR := $(if $(wildcard .flutter/bin/flutter),./.flutter/bin,)
PATH_SEP := :
BASE_PATH := $(PATH)
BLANK_LINE := @echo
define run_script
	@bash scripts/$(1).sh
endef
endif

ifeq ($(MHABIT_MAKE_PATH_READY),)
PATH := $(if $(FLUTTER_BIN_DIR),$(FLUTTER_BIN_DIR)$(PATH_SEP),)$(BASE_PATH)
export PATH
export MHABIT_MAKE_PATH_READY := 1
endif



.PHONY: help init bootstrap \
	normalize-l10n build-runner format fix gen-icons gen \
	verify-generated verify-submodules ci-check aio aio-full package-windows

help:
	@echo Standardized automation entrypoints
	$(BLANK_LINE)
	@echo   init              Configure git hooks and aliases, initialize submodule, fetch packages
	@echo   bootstrap         Alias of init
	@echo   normalize-l10n    Normalize ARB resources
	@echo   build-runner      Run build_runner and gen-l10n
	@echo   format            Format Dart sources under lib and test
	@echo   fix               Apply Dart fixes and then format sources
	@echo   gen-icons         Generate icon fonts
	@echo   gen               Run the main generation workflow
	@echo   verify-generated  Ensure normalized/generated files are up to date
	@echo   verify-submodules Show recursive submodule status
	@echo   ci-check          Alias of verify-generated
	@echo   aio               Run generation, fixes, and generation verification
	@echo   aio-full          Run aio plus the internal Flutter test suite
	@echo   package-windows   Build Windows MSIX package

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
	@"$(LOCAL_FLUTTER)" pub get
	@echo "Flutter packages resolved"

bootstrap: init

verify-submodules:
	@git submodule status --recursive

normalize-l10n:
	$(call run_script,normalize_arb)

build-runner:
	$(call run_script,build_runner)

format:
	@dart format lib test

fix:
	@dart fix --apply
	@$(SUBMAKE) format

gen-icons:
	$(call run_script,gen_icons)

gen:
	@$(SUBMAKE) normalize-l10n
	@$(SUBMAKE) gen-icons
	@$(SUBMAKE) build-runner

verify-generated:
	$(call run_script,verify_generated)

ci-check: verify-generated

aio:
	@$(SUBMAKE) gen
	@$(SUBMAKE) fix
	@$(SUBMAKE) verify-generated

aio-full:
	@$(SUBMAKE) aio
	@flutter test

package-windows:
	$(call run_script,build_msix)