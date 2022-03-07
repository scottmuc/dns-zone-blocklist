#!/usr/bin/env bats

@test "test bind-nxdomain.blocklist is valid bind conf" {
  run named-checkconf bind/zones.blocklist
  [ "$status" -eq 0 ]
}

@test "test bind-nxdomain.blocklist is a valid bind zone file" {
  run named-checkzone dns-zone-blocklist bind/bind-nxdomain.blocklist
  [ "$status" -eq 0 ]
}

@test "test dnsmasq.blocklist is valid dnsmasq conf" {
  run dnsmasq --test --conf-file=dnsmasq/dnsmasq.blocklist
  [ "$status" -eq 0 ]
}

@test "test dnsmasq-server.blocklist is valid dnsmasq conf" {
  run dnsmasq --test --conf-file=dnsmasq/dnsmasq-server.blocklist
  [ "$status" -eq 0 ]
}

@test "test unbound.blocklist is valid unbound conf" {
  run unbound-checkconf conf/unbound.conf
  [ "$status" -eq 0 ]
}

@test "test unbound-nxdomain.blocklist is valid unbound conf" {
  run unbound-checkconf conf/unbound-nxdomain.conf
  [ "$status" -eq 0 ]
}
