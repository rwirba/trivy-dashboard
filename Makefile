# ===== Trivy Dashboard (UBI9 Nginx) =====
IMAGE       ?= trivy-dashboard:ubi9
DOCKERFILE  ?= Dockerfile
CONTAINER   ?= trivy-dashboard
HOST_PORT   ?= 8080

# Change this to wherever your reports live on the host.
# The container serves them at http://localhost:8080/reports/
HOST_REPORTS ?= /srv/trivy/reports

# Use :Z for SELinux hosts (OK on non-SELinux too).
VOLUME_FLAGS = -v $(HOST_REPORTS):/usr/share/nginx/html/reports:ro,Z

.PHONY: help build rebuild run up stop rm logs sh ps open inspect clean

help:
	@echo "Targets:"
	@echo "  make build     - Build $(IMAGE) using $(DOCKERFILE)"
	@echo "  make rebuild   - Rebuild without cache"
	@echo "  make run/up    - Run container on port $(HOST_PORT), mount $(HOST_REPORTS) -> /reports"
	@echo "  make stop      - Stop container"
	@echo "  make rm        - Remove container"
	@echo "  make logs      - Tail logs"
	@echo "  make sh        - Shell into running container"
	@echo "  make ps        - Show container status"
	@echo "  make open      - Print URL to open"
	@echo "  make inspect   - Print effective config"
	@echo "  make clean     - Stop & remove container"

build:
	podman build -t $(IMAGE) -f $(DOCKERFILE) .

rebuild:
	podman build --no-cache -t $(IMAGE) -f $(DOCKERFILE) .

run up: stop rm
	podman run -d --name $(CONTAINER) \
		-p $(HOST_PORT):8080 \
		$(VOLUME_FLAGS) \
		$(IMAGE)
	@echo "Serving on http://localhost:$(HOST_PORT)  (reports at /reports)"

stop:
	-@podman stop $(CONTAINER) >/dev/null 2>&1 || true

rm:
	-@podman rm $(CONTAINER)   >/dev/null 2>&1 || true

logs:
	podman logs -f $(CONTAINER)

sh:
	podman exec -it $(CONTAINER) /bin/bash

ps:
	podman ps --filter "name=$(CONTAINER)"

open:
	@echo "Open: http://localhost:$(HOST_PORT)"

inspect:
	@echo "IMAGE       = $(IMAGE)"
	@echo "DOCKERFILE  = $(DOCKERFILE)"
	@echo "CONTAINER   = $(CONTAINER)"
	@echo "HOST_PORT   = $(HOST_PORT)"
	@echo "HOST_REPORTS= $(HOST_REPORTS)"

clean: stop rm

