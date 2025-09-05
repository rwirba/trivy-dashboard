# -------- settings --------
IMG              ?= trivy-dashboard:ubi9
NAME             ?= trivy-dashboard
PORT             ?= 8080
REPORTS_DIR      ?= /srv/trivy/reports           # host path where your JSON folders live
CONTEXT          ?= .
CONTAINERFILE    ?= Containerfile.ubi9

# add :z on SELinux hosts (kept by default)
VOLUME_OPTS      ?= -v $(REPORTS_DIR):/data/reports:ro,z

# -------- targets --------
.PHONY: all build run stop rm logs reload ps systemd-install systemd-remove

all: build run

build:
	@echo ">>> Building $(IMG)"
	podman build -t $(IMG) -f $(CONTAINERFILE) $(CONTEXT)

run:
	@echo ">>> Starting $(NAME) on :$(PORT)"
	podman run -d --name $(NAME) \
		-p $(PORT):8080 \
		$(VOLUME_OPTS) \
		--read-only \
		--security-opt no-new-privileges=true \
		localhost/$(IMG)

stop:
	- podman stop $(NAME)

rm: stop
	- podman rm $(NAME)

logs:
	podman logs -f $(NAME)

reload:
	# Rebuild and replace the container without changing data volume
	$(MAKE) build
	- podman rm -f $(NAME)
	$(MAKE) run

ps:
	podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"

systemd-install:
	@echo ">>> Installing systemd unit for $(NAME)"
	podman generate systemd --new --name $(NAME) --files --restart-policy=always
	sudo mv container-$(NAME).service /etc/systemd/system/$(NAME).service
	sudo systemctl daemon-reload
	sudo systemctl enable --now $(NAME)
	@echo ">>> Installed: systemctl status $(NAME)"

systemd-remove:
	- sudo systemctl disable --now $(NAME)
	- sudo rm -f /etc/systemd/system/$(NAME).service
	- sudo systemctl daemon-reload
