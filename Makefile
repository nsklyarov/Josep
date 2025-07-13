.PHONY: build test run clean deps

OS_NAME := $(shell uname 2>/dev/null || echo Unknown)
ifeq ($(OS),Windows_NT)
  PLATFORM := windows
else ifeq ($(OS_NAME),Linux)
  PLATFORM := unix
else ifeq ($(OS_NAME),Darwin)
  PLATFORM := unix
else
  $(error Unsupported platform)
endif

SCRIPTS_DIR := scripts/$(PLATFORM)

build:
	@$(SCRIPTS_DIR)/build$(if $(findstring windows,$(PLATFORM)),.bat,.sh)

test:
	@$(SCRIPTS_DIR)/run_tests$(if $(findstring windows,$(PLATFORM)),.bat,.sh)

run:
	@$(SCRIPTS_DIR)/run_sample$(if $(findstring windows,$(PLATFORM)),.bat,.sh)

clean:
	@$(SCRIPTS_DIR)/clean$(if $(findstring windows,$(PLATFORM)),.bat,.sh)

deps:
	@$(SCRIPTS_DIR)/install_dependencies$(if $(findstring windows,$(PLATFORM)),.bat,.sh)
