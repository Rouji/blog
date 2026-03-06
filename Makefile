ifeq ($(shell command -v podman),)
    CONTAINER_RUNTIME := docker
else
    CONTAINER_RUNTIME := podman
endif

build:
	$(CONTAINER_RUNTIME) run --rm -v ./:/src docker.io/hugomods/hugo:exts-non-root -- build --noBuildLock
