SB_HOSTS_REPO = https://github.com/StevenBlack/hosts.git
SB_HOST_PATH = git/StevenBlack/hosts
ODIN = ~/workspace/Odin/odin 

.PHONY: update

run: $(SB_HOST_PATH)
	$(ODIN) run ./src < $(SB_HOST_PATH)/hosts

$(SB_HOST_PATH):
	mkdir -p git/StevenBlack
	git clone --depth 1 $(SB_HOSTS_REPO) $(SB_HOST_PATH)

update:
	cd $(SB_HOST_PATH) && git pull
