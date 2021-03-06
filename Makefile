#
# Variables
#

# Go Packages
PKGS = \
	cmd/gpio \
	cmd/sipo \
	cmd/battcaverna 
ARMPKGS = $(PKGS:%=arm-%)
BUILDPKGS = $(PKGS:%=build-%)
DEBUGPKGS = $(PKGS:%=debug-%)

# Programs
INSTALL ?= /usr/bin/install

# Misc
SHELL = /bin/bash
VERSION = $(shell git describe --long --dirty --always) ($(shell env TZ=UTC git log -1 --format="%cd" --date=iso-local))
INFO = @printf "\e[01;32m*** Make: $@\e[00m\n"
BUILD = go build -ldflags '-X "main.version=$(VERSION)"'

#
# Build
#

# default
all: $(BUILDPKGS)

$(BUILDPKGS):
	$(INFO)
	cd $(@:build-%=%) && $(BUILD)

.PHONY: all $(BUILDPKGS)

# ARM
arm: $(ARMPKGS)

$(ARMPKGS):
	$(INFO)
	cd $(@:arm-%=%) && GOARCH=arm GOARM=7 GOOS=linux $(BUILD)

.PHONY: arm $(ARMPKGS)

# debug
debug: $(DEBUGPKGS)

$(DEBUGPKGS):
	$(INFO)
	cd $(@:debug-%=%) && $(BUILD) -race

.PHONY: debug $(DEBUGPKGS)

# test
test: 
	go test -race ./... | grep --line-buffered -v 'no test files'

.PHONY: test

# cover
initcover:
	@echo "mode: count" > cover.out

cover: initcover
	go test -race -coverprofile=cover.out ./...

coveralls: cover
	goveralls -coverprofile=cover.out -service=circle-ci -repotoken=$(COVERALLS_TOKEN)

.PHONY: initcover cover coveralls

#
# Help
#

help:
	# Common targets:
	# all     - Build all executables for the current architecture
	# debug   - Like "all" but also enables Go's race detector
	# arm     - Build ARM executables#
	# Test targets:
	# test      - Run tests
	# cover     - Run tests collecting coverage information
	# coveralls - Sends coverage data to Coveralls
	#
	# Release targets:
	# install       - Build ARM executables and copies them in repositories used to produce microSD cards
	# release       - Commit binaries copied over by the "install" target
	# release-amend - Amend release
	#
	
.PHONY: help