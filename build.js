'use strict'

const fs = require('fs')
const ejs = require('ejs')
const path = require('path')
const crypto = require('crypto')
const rp = require('request-promise')
const tlds = require('tlds')

class Blocklist {
  constructor () {
    this.allowlist = require('./custom.allowlist')
    this.blocklist = require('./custom.blocklist')

    this.formats = [
      {
        type: 'bind',
        filename: 'zones.blocklist',
        template: 'zone "<%= host %>" { type master; notify no; file "null.zone.file"; };'
      },
      {
        type: 'bind',
        filename: 'bind-nxdomain.blocklist',
        template: '<%= host %> CNAME .\n*.<%= host %> CNAME .',
        header: `$TTL 60\n@ IN SOA localhost. dns-zone-blocklist. (2 3H 1H 1W 1H)\ndns-zone-blocklist. IN NS localhost.`
      },
      {
        type: 'dnsmasq',
        filename: 'dnsmasq.blocklist',
        template: 'address=/<%= host %>/0.0.0.0'
      },
      {
        type: 'dnsmasq',
        filename: 'dnsmasq-server.blocklist',
        template: 'server=/<%= host %>/'
      },
      {
        type: 'unbound',
        filename: 'unbound.blocklist',
        template: 'local-zone: "<%= host %>" always_refuse'
      },
      {
        type: 'unbound',
        filename: 'unbound-nxdomain.blocklist',
        template: 'local-zone: "<%= host %>" always_nxdomain'
      }
    ]
  }

  async build () {
    let hosts = await rp.get('https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts')
    let stats = await rp.get('https://raw.githubusercontent.com/StevenBlack/hosts/master/readmeData.json', {json: true})

    // Filter the original hosts file
    hosts
      .split('\n')
      .map(x => x.trim())
      .filter(x => !(x === '' || x.charAt(0) === '#'))
      .map(x => x.split(' ')[1])
      .filter(x => !this.allowlist.includes(x))
      .sort((a, b) => a.length - b.length)
      .map(host => {
        if (!this.blocklist.find(x => host.slice(-Math.abs(x.length + 1)) === '.' + x) && !tlds.includes(host)) {
          this.blocklist.push(host)
        }
      })

    // Build a zone blocklist for each format type
    this.formats.forEach((format) => {
      let zoneFile = this.blocklist.map(x => ejs.render(format.template, {host: x})).join('\n')

      if (format.header) {
        zoneFile = format.header + '\n\n' + zoneFile
      }

      let sha256 = crypto.createHash('sha256').update(zoneFile).digest('hex')
      let dest = path.resolve(__dirname, `${format.type}/${format.filename}`)

      fs.writeFileSync(`${dest}.checksum`, sha256)
      console.log(`${format.filename} checksum is ${sha256}`)

      fs.writeFileSync(`${dest}`, zoneFile)
      console.log(`${this.blocklist.length} ${format.filename} zones saved to ${dest}`)
    })

    // Update the README.md file
    let readmeTemplate = fs.readFileSync(path.resolve(__dirname, 'README.template.md'), 'utf8')
    let readme = ejs.render(readmeTemplate, {
      hosts: stats.base.entries.toLocaleString(),
      zones: this.blocklist.length.toLocaleString()
    })

    fs.writeFileSync(path.resolve(__dirname, 'README.md'), readme)
  }
}

const blocklist = new Blocklist()

blocklist.build()
