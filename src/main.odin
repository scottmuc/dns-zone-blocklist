package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	// path is relative to PWD
	hostsPath := "git/StevenBlack/hosts/hosts"

	// https://odin-lang.org/news/read-a-file-line-by-line/
	data, ok := os.read_entire_file(hostsPath, context.allocator)
	if !ok {
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		fmt.println(line)
	}
}
