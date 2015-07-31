#!/usr/bin/env node

module.exports = bash
bash.Q = bashQ
bash.sync = bashSync


var Q = require('q')
  , logger = require('./logger').sync
  , cp = require('child_process')
  , exec = cp.exec
  , execSync = cp.execSync
  , format = require('util').format

function bash(command, opts, log, cb) {
  if(typeof log === 'function') {
    cb = log
    log = resolveLogger(log)
  }
  if(typeof opts === 'function') {
    cb = opts;
    opts = {};
    log = resolveLogger(log)
  }
  opts = normalizeOpts(opts, cb)
  exec(wrapCommand(command), opts, function(err, stdout, stderr) {
    if(err) {
      log.error(err)
      cb(err)
    }
    else {
      log.debug(stderr)
      log.debug(stdout)
    }
  })
}

function bashQ(command, opts, log) {
  return Q.nfbind(bash)(command, opts, log)
}

function bashSync(command, opts, log) {
  opts = normalizeOpts(opts)
  log = resolveLogger(log)
  log.debug(opts, 'bash options')
  return execSync(wrapCommand(command), opts)
}

function normalizeOpts(opts) {
  /** convenience to allow opts to be set as common param current working directory */
  if(typeof opts === 'string') {
    opts = { cwd: opts }
  }
  opts = opts || {}
  opts.encoding = 'utf8'
  return opts
}

function resolveLogger(log) {
  return log || logger('bash')
}

function wrapCommand(command) {
  return format('bash -c "%s"', command)
}

if(!module.parent) bash.sync(process.argv)
