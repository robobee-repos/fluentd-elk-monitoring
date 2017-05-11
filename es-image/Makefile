REPOSITORY := erwinnttdata
NAME := elasticsearch-logging
VERSION ?= 5.4.0-1.0.5

include docker_make_utils/Makefile.help
include docker_make_utils/Makefile.functions
include docker_make_utils/Makefile.image

build: _build ##@targets Builds the docker image.
.PHONY: build

clean: _clean ##@targets Removes the build docker image.
.PHONY: clean

deploy: _deploy ##@targets Deployes the docker image to the repository.
.PHONY: deploy

rebuild: _rebuild ##@targets Rebuilds the docker image to the repository.
.PHONY: rebuild
