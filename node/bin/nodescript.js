#!/usr/bin/env node

module.exports = ns
ns.Q = nsQ
ns.sync = nsSync

var path = require('path')
  , join = path.join
  , Q = require('q')
  , log = require('bunyan').createLogger({name: 'ns'})
  , ZDOTDIR = process.env.ZDOTDIR || join(HOME, '.zsh')
  , ZNODEDIR = join(ZDOTDIR, 'node')
  , yargs = require('yargs')
    .usage('ns <nodescript> [args]')
    .demand(1)

function ns(args, cb) {
  var argv = yargs.parse(args)
    , nodescript = requireNS(argv._[0])

  if(nodescript) cb(null, script)
  else cb('NODESCRIPT_NOT_FOUND')
}

function nsQ(args) {
  return Q.nfbind(ns)(args)
}

function nsSync(args) {
  var argv = yargs.parse(args)
    , nodescript = requireNS(argv._[0])
    , nodescriptSync = nodescript.sync

  if(nodescriptSync) nodescriptSync(argv._.slice(1))
  else process.exit(1)
}

function requireNS(nsName) {
  try {
    var nsPath = toAbsPath(nsName)
      , nodescript = require(nsPath)
    log.debug(nodescript, 'returning nodescript: %s', nsName)
    return nodescript
  }
  catch(err) {
    log.err(err, 'an error occurred during nodescript execution')
    return null
  }
}

function toAbsPath(nsName) {
  return join(ZNODEDIR, nsName)
}

if(!module.parent) ns.sync(process.argv.slice(2))
