REPO_URL = https://github.com/StevenBlack/hosts.git
REPO_DIR = git/StevenBlack/hosts
ODIN = ~/workspace/Odin/odin 

.PHONY: update

run:
	$(ODIN) run ./src

git/SteveBlack/hosts:
	mkdir -p git/StevenBlack
	git clone $(REPO_URL) $(REPO_DIR)

update:
	cd $(REPO_DIR) && git pull
