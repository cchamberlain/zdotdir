#!/usr/bin/env node

module.exports = zsh
zsh.Q = zshQ
zsh.sync = zshSync

if(!module.parent) zsh.sync(process.argv)

var Q = require('q')
  , cp = require('child_process')
  , exec = cp.exec
  , execSync = cp.execSync
  , format = require('util').format

function zsh(command, opts, cb) {
  if(typeof opts === 'function') {
    cb = opts;
    opts = {};
  }
  opts = normalizeOpts(opts, cb)
  exec(wrapCommand(command), opts, cb)
}

function zshQ(command, opts) {
  return Q.nfbind(zsh)(command, opts)
}

function zshSync(command, opts) {
  opts = normalizeOpts(opts)
  return execSync(wrapCommand(command), opts)
}

function normalizeOpts(opts) {
  /** convenience to allow opts to be set as common param current working directory */
  if(typeof opts === 'string') {
    opts = { cwd: opts }
  }
  opts = opts || {}
  opts.encoding = 'utf-8'
}

function wrapCommand(command) {
  return format('zsh -c "%s"', command)
}