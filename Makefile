SB_HOSTS_REPO = https://github.com/StevenBlack/hosts.git
SB_HOST_PATH = git/StevenBlack/hosts
ODIN = ~/workspace/Odin/odin 

.PHONY: update \
	 unbound unbound_nxdomain \
	 dnsmasq dnsmasq_server \
	 bind bind_nxdomain

all: unbound unbound_nxdomain \
	dnsmasq dnsmasq_server \
	bind bind_nxdomain

bind: $(SB_HOST_PATH)
	$(ODIN) run ./src -- bind \
		< $(SB_HOST_PATH)/hosts \
		> bind/zones.blocklist

bind_nxdomain: $(SB_HOST_PATH)
	$(ODIN) run ./src -- bind_nxdomain \
		< $(SB_HOST_PATH)/hosts \
		> bind/bind-nxdomain.blocklist

dnsmasq: $(SB_HOST_PATH)
	$(ODIN) run ./src -- dnsmasq \
		< $(SB_HOST_PATH)/hosts \
		> dnsmasq/dnsmasq.blocklist

dnsmasq_server: $(SB_HOST_PATH)
	$(ODIN) run ./src -- dnsmasq_server \
		< $(SB_HOST_PATH)/hosts \
		> dnsmasq/dnsmasq-server.blocklist

unbound: $(SB_HOST_PATH)
	$(ODIN) run ./src -- unbound \
		< $(SB_HOST_PATH)/hosts \
		> unbound/unbound.blocklist

unbound_nxdomain: $(SB_HOST_PATH)
	$(ODIN) run ./src -- unbound_nxdomain \
		< $(SB_HOST_PATH)/hosts \
		> unbound/unbound-nxdomain.blocklist

$(SB_HOST_PATH):
	mkdir -p git/StevenBlack
	git clone --depth 1 $(SB_HOSTS_REPO) $(SB_HOST_PATH)

update:
	cd $(SB_HOST_PATH) && git pull
