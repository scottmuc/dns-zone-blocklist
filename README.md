[![.github/workflows/build.yaml](https://github.com/scottmuc/dns-zone-blocklist/actions/workflows/build.yaml/badge.svg)](https://github.com/scottmuc/dns-zone-blocklist/actions/workflows/build.yaml)

# DNS Zone Blocklist Generator

**Credit goes to oznu that set this up here: https://github.com/oznu/dns-zone-blacklist**

This project generates a zone file for [BIND](https://en.wikipedia.org/wiki/BIND), [Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) and [Unbound](https://en.wikipedia.org/wiki/Unbound_(DNS_server)) DNS servers using data from the [StevenBlack/hosts](https://github.com/StevenBlack/hosts) project. The generated zone files can be used to block ads and malware for an entire network when used with a local DNS server.

DNS based ad blockers can support wildcard entries. This tool filters out any subdomains of known adware or malware domains, reducing the number of zone entries required from **171,070** down to **106,064**.

| DNS Server | Response Type | Download  | SHA256 Checksum |
| ---------- |:-------------:|:---------:|:---------------:|
| BIND | 0.0.0.0 | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/bind/zones.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/bind/zones.blocklist.checksum) |
| BIND (RPZ) | NXDOMAIN | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/bind/bind-nxdomain.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/bind/bind-nxdomain.blocklist.checksum) |
| Dnsmasq | 0.0.0.0 | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/dnsmasq/dnsmasq.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/dnsmasq/dnsmasq.blocklist.checksum) |
| Dnsmasq | NXDOMAIN | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/dnsmasq/dnsmasq-server.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/dnsmasq/dnsmasq-server.blocklist.checksum) |
| Unbound | 0.0.0.0 | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/unbound/unbound.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/unbound/unbound.blocklist.checksum) |
| Unbound | NXDOMAIN | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/unbound/unbound-nxdomain.blocklist) | [link](https://raw.githubusercontent.com/scottmuc/dns-zone-blocklist/master/unbound/unbound-nxdomain.blocklist.checksum) |

## Building the blocklist

The blocklist can be generated using [Node.js 8.4.0](https://nodejs.org) or later.

Install:

```
git clone https://github.com/scottmuc/dns-zone-blocklist.git
cd dns-zone-blocklist

npm install
```

Then build:

```
node build.js
```

The compiled blocklist files will be saved to the `./bind`, `./dnsmasq` and `./unbound` a directories in the root of the project.

### Custom Entries

Custom entries can be added to the custom.blocklist.json file in the root of this project before building.

### Allowlist

Any domains you wish to exclude from the blocklist can be added to the custom.allowlist.json file in the root of this project before building.
