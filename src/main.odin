package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	data, ok := os.read_entire_file(os.stdin)
	if !ok {
		fmt.eprintln("Failed to read hosts from stdin")
		os.exit(1)
	}
	defer delete(data)

	if len(os.args) != 2 {
		fmt.eprintln("Did not specify type of filter")
		os.exit(1)
	}

	filter_name := os.args[1]
	if filter_name == "bind_nxdomain" {
		fmt.println("$TTL 60")
		fmt.println("@ IN SOA localhost. dns-zone-blocklist. (2 3H 1H 1W 1H)")
		fmt.println("dns-zone-blocklist. IN NS localhost.\n")
	}

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if line == "" || strings.has_prefix(line, "#") {
			continue
		}
		// expect every line to be of the form
		// 0.0.0.0 some.fqdn
		_, _, host := strings.partition(line, " ")

		switch filter_name {
		case "unbound":
			fmt.printf("local-zone: \"%s\" always_refuse\n", host)
		case "unbound_nxdomain":
			fmt.printf("local-zone: \"%s\" always_nxdomain\n", host)
		case "dnsmasq":
			fmt.printf("address=/%s/0.0.0.0\n", host)
		case "dnsmasq_server":
			fmt.printf("server=/%s/\n", host)
		case "bind":
			fmt.printf("zone \"%s\" { type master; notify no; file \"null.zone.file\"; };\n", host)
		case "bind_nxdomain":
			fmt.printf("%s CNAME . \n*.%s CNAME .\n", host, host)
		}
	}
}
