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

	it := string(data)
	hosts := make([dynamic]string)
	defer delete(hosts)

	for line in strings.split_lines_iterator(&it) {
		// ignore empty lines and commented lines
		if line == "" || strings.has_prefix(line, "#") {
			continue
		}
		// expect every line to be of the form
		// 0.0.0.0 some.fqdn
		_, _, host := strings.partition(line, " ")
		append(&hosts, host)
	}

	unbound_builder := strings.builder_make()
	defer strings.builder_destroy(&unbound_builder)

	for host in hosts {
		defer free_all(context.temp_allocator)
		strings.write_string(&unbound_builder, format_unbound(host))
	}

	// IDEA wrather than hard code output paths, I could take an argument
	// for what format I want and redirect the output to the desired file
	// and orchestrate all this via make
	ok = os.write_entire_file("unbound/unbound.blocklist", unbound_builder.buf[:])
	if !ok {
		fmt.eprintln("Failed to write unbound/unbound.blocklist")
		os.exit(1)
	}
}

format_unbound :: proc(host: string) -> string {
	return fmt.tprintf("local-zone: \"%s\" always_refuse\n", host)
}

format_unbound_nx_domain :: proc(host: string) -> string {
	return fmt.tprintf("local-zone: \"%s\" always_nxdomain\n", host)
}

format_dnsmasq :: proc(host: string) -> string {
	return fmt.tprintf("address=/%s/0.0.0.0\n", host)
}

format_dnsmasq_server :: proc(host: string) -> string {
	return fmt.tprintf("server=/%s/\n", host)
}

format_bind :: proc(host: string) -> string {
	return fmt.tprintf("zone \"%s\" { type master; notify no; file \"null.zone.file\"; };\n", host)
}

format_bind_nxdomain :: proc(host: string) -> string {
	return fmt.tprintf("%s CNAME . \n*.%s CNAME .\n", host, host)
}
