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
HOST_PLATFORM := $(shell uname -s)
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
NATIVE_TEST_PACKAGE := packages/mhabit_desktop_window_chrome
NATIVE_BUILD_DIR := build/native-tests
NATIVE_RESULTS_DIR ?= build/test-results/native


.PHONY: help init bootstrap \
	normalize-l10n build-runner format fix gen-icons test gen \
	test-ci test-native test-linux test-windows test-macos test-all \
	verify-generated verify-submodules aio aio-full sync-rules unsync-rules \
	gen-screenshot-data gen-natural-sort-data

help:
	@echo Standardized automation entrypoints
	$(BLANK_LINE)
	@echo   init              Configure git hooks and aliases, initialize submodule, fetch packages
	@echo   bootstrap         Alias of init
	@echo   normalize-l10n    Normalize ARB resources
	@echo   build-runner      Run Pigeon, build_runner generators and gen-l10n
	@echo   format            Format Dart sources under lib and test
	@echo   fix               Apply Dart fixes and then format sources
	@echo   gen-icons         Generate icon fonts
	@echo   test              Run the root app and internal Dart/Flutter package tests
	@echo   test-ci           Run Dart/Flutter tests with machine-readable results
	@echo   test-native       Run native tests for the current desktop host
	@echo "  test-linux        Run GTK C++ tests; requires a display or xvfb-run"
	@echo   test-windows      Run Win32 C++ tests with CMake and CTest
	@echo   test-macos        Run app-hosted XCTest with Xcode
	@echo   test-all          Run Dart/Flutter tests and current-host native tests
	@echo   gen               Run the main generation workflow
	@echo   verify-generated  Ensure normalized/generated files are up to date
	@echo   verify-submodules Show recursive submodule status
	@echo   aio               Run generation, fixes, and generation verification
	@echo   aio-full          Run aio plus test-all
	@echo "  sync-rules        Distribute rule references to AI tools (SYNC_RULES_FILE=docs/rules/rules.md)"
	@echo "  gen-screenshot-data    Generate seed JSON for screenshots (all langs, default config)"
	@echo "  gen-natural-sort-data  Generate seed JSON for natural-sort testing (zh+en, 39 groups)"

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

test-ci:
	@$(MELOS) run test-ci

# C++ suites compile the package's native implementation directly; they do not
# need a Flutter app build. CTest >= 3.21 provides JUnit output for CI reporting.
test-linux:
ifeq ($(HOST_PLATFORM),Linux)
	@cmake -S "$(NATIVE_TEST_PACKAGE)/linux/test" -B "$(NATIVE_BUILD_DIR)/linux" -DCMAKE_BUILD_TYPE=Debug
	@cmake --build "$(NATIVE_BUILD_DIR)/linux" --config Debug
	@cmake -E make_directory "$(NATIVE_RESULTS_DIR)"
	@ctest --test-dir "$(NATIVE_BUILD_DIR)/linux" -C Debug --output-on-failure --no-tests=error --timeout 60 --output-junit "$(abspath $(NATIVE_RESULTS_DIR))/native_test_linux.xml"
else
	@echo ERROR: test-linux requires a Linux host
	@exit 1
endif

test-windows:
ifeq ($(OS),Windows_NT)
	@cmake -S "$(NATIVE_TEST_PACKAGE)/windows/test" -B "$(NATIVE_BUILD_DIR)/windows"
	@cmake --build "$(NATIVE_BUILD_DIR)/windows" --config Debug
	@cmake -E make_directory "$(NATIVE_RESULTS_DIR)"
	@ctest --test-dir "$(NATIVE_BUILD_DIR)/windows" -C Debug --output-on-failure --no-tests=error --timeout 60 --output-junit "$(abspath $(NATIVE_RESULTS_DIR))/native_test_windows.xml"
else
	@echo ERROR: test-windows requires a Windows host
	@exit 1
endif

# These tests inspect MainFlutterWindow and need the initialized Flutter app.
# Disable signing so the test build does not need a developer certificate/profile.
test-macos:
ifeq ($(HOST_PLATFORM),Darwin)
	@"$(LOCAL_FLUTTER)" build macos --debug --config-only --flavor f_dev
	@mkdir -p "$(NATIVE_RESULTS_DIR)"
	@rm -rf "$(NATIVE_RESULTS_DIR)/macos.xcresult"
	@set -o pipefail; xcodebuild test \
		-workspace macos/Runner.xcworkspace -scheme f_dev \
		-configuration Debug-f_dev -destination 'platform=macOS' \
		-derivedDataPath "$(NATIVE_BUILD_DIR)/macos" \
		-resultBundlePath "$(NATIVE_RESULTS_DIR)/macos.xcresult" \
		-only-testing:RunnerTests -parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee "$(NATIVE_RESULTS_DIR)/macos.log"
else
	@echo ERROR: test-macos requires a macOS host
	@exit 1
endif

test-native:
ifeq ($(OS),Windows_NT)
	@$(SUBMAKE) test-windows
else ifeq ($(HOST_PLATFORM),Linux)
	@$(SUBMAKE) test-linux
else ifeq ($(HOST_PLATFORM),Darwin)
	@$(SUBMAKE) test-macos
else
	@echo ERROR: no native test target for this host
	@exit 1
endif

test-all:
	@$(SUBMAKE) test
	@$(SUBMAKE) test-native

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

gen-natural-sort-data:
	@$(LOCAL_DART) run tools/bin/gen_screenshot_data.dart \
		--config tools/config/screenshot_seed_natural_sort.yaml \
		--all-langs --no-repeat

aio:
	@$(SUBMAKE) gen
	@$(SUBMAKE) fix
	@$(SUBMAKE) verify-generated

aio-full:
	@$(SUBMAKE) aio
	@$(SUBMAKE) test-all
