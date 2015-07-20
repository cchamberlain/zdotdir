#!/usr/bin/env node

module.exports = logger
logger.Q = loggerQ
logger.sync = loggerSync

var bunyan = require('bunyan')
  , Q = require('q')

function logger(name, cb) {
    cb(null, createLogger(name))
}

function loggerQ(name) {
  return Q.nfbind(logger)(name)
}

function loggerSync(name) {
  return createLogger(name)
}

function createLogger (name) {
  return bunyan.createLogger(
    { name: name
    , streams:  [ stdOutLogger() ]
    })
}

function stdOutLogger () {
  return  { "level": process.env.ZOS_LOGLEVEL || "info"
          , "stream": process.stdout
          }
}

if(!module.parent) logger.sync(process.argv.slice(2))
