package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

import vmem "core:mem/virtual"

main :: proc() {
	// This creates a growing virtual memory arena. It uses virtual memory and
	// can grow as things are added to it.
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)

	data, ok := os.read_entire_file(os.stdin, arena_alloc)
	ensure(ok == nil)
	defer vmem.arena_destroy(&arena)

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

	hosts_to_allow := []string{ "local", "localhost", "localhost.localdomain", "broadcasthost", "sbc" }

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if line == "" || strings.has_prefix(line, "#") {
			continue
		}
		// expect every line to be of the form
		// 0.0.0.0 some.fqdn
		// or
		// 0.0.0.0 some.fqdn #and some comment
		// 0.0.0.0 some.fqdn # and some comment
		ip_domain, _, _ := strings.partition(line, "#")
		_, _, host := strings.partition(ip_domain, " ")
		host = strings.trim_right_space(host)

		if slice.contains(hosts_to_allow, host) {
			continue
		}

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
