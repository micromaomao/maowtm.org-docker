#!/usr/bin/env node
const Maowtm = require('./index')
Maowtm({
  db: 'mongodb://mw-mongo/maowtm',
  redis: 'mw-redis',
  elasticsearch: 'mw-es:9200',
  listen: [
    '0.0.0.0'
  ],
  ssl: {
    key: './maowtm.org/local-dev-cert/server.key',
    cert: './maowtm.org/local-dev-cert/server.crt'
    // ca: 'x3.crt'
  },
  apps: [
    {
      hostname: 'schsrch.xyz',
      init: require('schsrch')
    }
  ],
  rbs: [
    // {
    //   path: '/awesome/app/',
    //   dir: path.join(__dirname, '../some-static-stuff/')
    // }
  ],
	callback: err => {
    if (err) {
      console.error(err)
      process.exit(1)
      process.kill(process.pid, 'SIGKILL')
    }
    setTimeout(() => {
      process.setgid('www')
      process.setuid('www')
      console.log('uid and gid set to www.')
    }, 100)
  }
})
