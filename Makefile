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
DESKTOP_WINDOW_CHROME_PACKAGE_DIR := packages/mhabit_desktop_window_chrome
NATIVE_TEST_BUILD_DIR := build/native-tests
NATIVE_TEST_RESULTS_DIR ?= build/test-results/native
FLAVOR ?= f_generic
IOS_TEST_DESTINATION ?=
SCRIPTS_PYTHON := poetry --directory scripts/python-scripts run python


.PHONY: help init bootstrap \
	normalize-l10n sync-native-l10n build-runner format fix gen-icons test gen \
	test-ci test-scripts test-native test-linux test-windows test-macos test-ios test-ios-integration test-all test-integration \
	verify-generated verify-submodules aio aio-full sync-rules unsync-rules \
	gen-screenshot-data gen-natural-sort-data

help:
	@echo Standardized automation entrypoints
	$(BLANK_LINE)
	@echo   init              Configure git hooks and aliases, initialize submodule, fetch packages
	@echo   bootstrap         Alias of init
	@echo   normalize-l10n    Normalize ARB resources
	@echo   sync-native-l10n  Fill missing native strings from configured ARB references
	@echo   build-runner      Run Pigeon, build_runner generators and gen-l10n
	@echo   format            Format Dart sources under lib and test
	@echo   fix               Apply Dart fixes and then format sources
	@echo   gen-icons         Generate icon fonts
	@echo   test              Run Dart/Flutter and iOS widget unit tests on macOS
	@echo   test-ci           Run Dart/Flutter tests with machine-readable results
	@echo   test-scripts      Run local development script tests with Poetry and pytest
	@echo   test-native       Run native tests for the current desktop host
	@echo "  test-linux        Run GTK C++ tests; requires a display or xvfb-run"
	@echo   test-windows      Run Win32 C++ tests with CMake and CTest
	@echo   test-macos        Run app-hosted XCTest with Xcode
	@echo "                    FLAVOR=f_generic (default), f_dev, or f_store"
	@echo   test-ios          Run isolated widget unit XCTest without building the app
	@echo   test-ios-integration  Build app/extension and run widget integration XCTest
	@echo "                    FLAVOR selects app variant; IOS_TEST_DESTINATION selects simulator"
	@echo   test-all          Run all unit tests, including Python and native unit suites
	@echo   test-integration  Run all integration suites supported on this host
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

sync-native-l10n:
	$(call run_script,sync_native_l10n)

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
ifeq ($(HOST_PLATFORM),Darwin)
	@$(SUBMAKE) test-ios
endif

test-ci:
	@$(MELOS) run test-ci

test-scripts:
	@$(SCRIPTS_PYTHON) -m pytest

# C++ suites compile the package's native implementation directly; they do not
# need a Flutter app build. CTest >= 3.21 provides JUnit output for CI reporting.
test-linux:
ifeq ($(HOST_PLATFORM),Linux)
	@cmake -S "$(DESKTOP_WINDOW_CHROME_PACKAGE_DIR)/linux/test" -B "$(NATIVE_TEST_BUILD_DIR)/linux" -DCMAKE_BUILD_TYPE=Debug
	@cmake --build "$(NATIVE_TEST_BUILD_DIR)/linux" --config Debug
	@cmake -E make_directory "$(NATIVE_TEST_RESULTS_DIR)"
	@ctest --test-dir "$(NATIVE_TEST_BUILD_DIR)/linux" -C Debug --output-on-failure --no-tests=error --timeout 60 --output-junit "$(abspath $(NATIVE_TEST_RESULTS_DIR))/native_test_linux.xml"
else
	@echo ERROR: test-linux requires a Linux host
	@exit 1
endif

test-windows:
ifeq ($(OS),Windows_NT)
	@cmake -S "$(DESKTOP_WINDOW_CHROME_PACKAGE_DIR)/windows/test" -B "$(NATIVE_TEST_BUILD_DIR)/windows"
	@cmake --build "$(NATIVE_TEST_BUILD_DIR)/windows" --config Debug
	@cmake -E make_directory "$(NATIVE_TEST_RESULTS_DIR)"
	@ctest --test-dir "$(NATIVE_TEST_BUILD_DIR)/windows" -C Debug --output-on-failure --no-tests=error --timeout 60 --output-junit "$(abspath $(NATIVE_TEST_RESULTS_DIR))/native_test_windows.xml"
else
	@echo ERROR: test-windows requires a Windows host
	@exit 1
endif

# These tests inspect the real MainFlutterWindow through a controlled Flutter
# host, so app-side chrome updates cannot race XCTest's decoration changes.
# Disable signing so the test build does not need a developer certificate/profile.
test-macos:
ifeq ($(HOST_PLATFORM),Darwin)
	@"$(LOCAL_FLUTTER)" build macos --debug --config-only --flavor "$(FLAVOR)"
	@mkdir -p "$(NATIVE_TEST_RESULTS_DIR)"
	@rm -rf "$(NATIVE_TEST_RESULTS_DIR)/macos.xcresult"
	@set -o pipefail; xcodebuild test \
		-workspace macos/Runner.xcworkspace -scheme "$(FLAVOR)" \
		-configuration "Debug-$(FLAVOR)" -destination 'platform=macOS' \
		-derivedDataPath "$(NATIVE_TEST_BUILD_DIR)/macos" \
		-resultBundlePath "$(NATIVE_TEST_RESULTS_DIR)/macos.xcresult" \
		-only-testing:RunnerTests -parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO FLUTTER_TARGET=test/native/macos_host.dart \
		2>&1 | tee "$(NATIVE_TEST_RESULTS_DIR)/macos.log"
else
	@echo ERROR: test-macos requires a macOS host
	@exit 1
endif

# Compile unit tests directly without preparing or building the Flutter app.
test-ios:
ifeq ($(HOST_PLATFORM),Darwin)
	@mkdir -p "$(NATIVE_TEST_RESULTS_DIR)"
	@rm -rf "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-unit.xcresult"
	@set -e -o pipefail; \
		destination="$(IOS_TEST_DESTINATION)"; \
		if [[ -z "$$destination" ]]; then destination="$$( $(SCRIPTS_PYTHON) bin/select_ios_simulator.py)"; fi; \
		xcodebuild test -project ios/HabitWidgetTests/HabitWidgetTests.xcodeproj \
		-scheme HabitWidgetTests -configuration Debug -destination "$$destination" \
		-derivedDataPath "$(NATIVE_TEST_BUILD_DIR)/ios-widget-unit" \
		-resultBundlePath "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-unit.xcresult" \
		-only-testing:HabitWidgetTests -parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- \
		2>&1 | tee "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-unit.log"
else
	@echo ERROR: test-ios requires a macOS host with Xcode and an iOS simulator
	@exit 1
endif

# Verify the actual HabitWidget app/extension products and file-backed components.
test-ios-integration:
ifeq ($(HOST_PLATFORM),Darwin)
	@case "$(FLAVOR)" in f_dev|f_generic|f_store|Runner) ;; *) echo "Unknown FLAVOR: $(FLAVOR)" >&2; exit 1 ;; esac
	@"$(LOCAL_FLUTTER)" build ios --simulator --debug --config-only --target lib/main.dart \
		$(if $(filter Runner,$(FLAVOR)),,--flavor "$(FLAVOR)")
	@mkdir -p "$(NATIVE_TEST_RESULTS_DIR)"
	@rm -rf "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-integration.xcresult"
	@set -e -o pipefail; \
		destination="$(IOS_TEST_DESTINATION)"; \
		if [[ -z "$$destination" ]]; then destination="$$( $(SCRIPTS_PYTHON) bin/select_ios_simulator.py)"; fi; \
		xcodebuild test -workspace ios/Runner.xcworkspace -scheme HabitWidgetIntegrationTests \
		-configuration "$(if $(filter Runner,$(FLAVOR)),Debug,Debug-$(FLAVOR))" -destination "$$destination" \
		-derivedDataPath "$(NATIVE_TEST_BUILD_DIR)/ios-widget-integration" \
		-resultBundlePath "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-integration.xcresult" \
		-only-testing:HabitWidgetIntegrationTests -parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- FLUTTER_TARGET=lib/main.dart \
		2>&1 | tee "$(NATIVE_TEST_RESULTS_DIR)/ios-widget-integration.log"
else
	@echo ERROR: test-ios-integration requires a macOS host with Xcode and an iOS simulator
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
	@$(SUBMAKE) test-scripts
	@$(SUBMAKE) test
ifeq ($(OS),Windows_NT)
	@$(SUBMAKE) test-windows
else ifeq ($(HOST_PLATFORM),Linux)
	@$(SUBMAKE) test-linux
endif

# Keep app builds out of the unit-test workflow. Register future platform
# integration suites (such as Android) here alongside the existing suites.
test-integration:
ifeq ($(HOST_PLATFORM),Darwin)
	@$(SUBMAKE) test-macos
	@$(SUBMAKE) test-ios-integration
else
	@echo No integration suites are configured for this host.
endif

gen:
	@$(SUBMAKE) normalize-l10n
	@$(SUBMAKE) sync-native-l10n
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
