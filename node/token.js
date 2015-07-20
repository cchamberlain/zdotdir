#!/usr/bin/env node

/**
 * Gets a GitHub token for a user
 * @module token
 */

module.exports = token
token.Q = tokenQ
token.sync = tokenSync

if (!module.parent) token.sync(process.argv)

var logger = require('./tools/log')
  , bash = require('./tools/bash')
  , join = require('path').join
  , async = require('async')
  , format = require('util').format
  , env = require('./env')
  , mkdirp = require('mkdirp')
  , yargs = require('yargs')
    .usage('usage: $0 [-s/--sync] [-p/--path] [-b/--branch] [-v/--version] username[/project]')
    .option('s'
    , { alias: 'sync'
      , demand: true
      , default: false
      , describe: 'clone to sync root'
      , type: 'boolean'
    })
    .demand(1)
  , commands =
    { clone: function (url) { return format('git clone %s', url) }
    , fetch: function () { return 'git fetch --all' }
    , checkout: function (argv) {
        return argv.version ?
          format('git checkout -f %s', argv.version) :
          format('git checkout %s', argv.branch)
      }
  }
  , messages =
    { cloneFinished: 'clone step finished'
    , fetchFinished: 'fetch step finished'
    , checkoutFinished: 'checkout step finished'
    , errorOccurred: 'an error occurred during clone.js execution'
    }

function clone (args, cb) {
  var ctx = buildContext(args)
  logger('clone', function (err) {
    if (err) onError(err)
    else {
      mkdirp(rootDirectory, function (err) {
        if (err) onError(err)
        else _clone(ctx, cb)
      })
    }
  })
}

function _clone (ctx, cb) {
}

function cloneQ (args) {
  return Q.nfbind(clone)(args)
}

function cloneSync (args) {
  var ctx = buildContext(args)
    , stdout = ''
    , log = logger.sync('clone')

  try {
    mkdirp.sync(ctx.rootDirectory)
    stdout = bash.sync(commands.clone(ctx.url), ctx.rootDirectory)
    log.info(stdout, messages.cloneFinished)
    stdout = bash.sync(commands.fetch(), ctx.projectDirectory)
    log.info(stdout, messages.fetchFinished)
    stdout = bash.sync(commands.checkout(ctx.argv), ctx.projectDirectory)
    log.info(stdout, messages.checkoutFinished)
  } catch (err) {
    log.error(err, messages.errorOccurred)
    throw err
  }
}

function buildContext (args) {
  var argv = yargs.parse(args)
    , strategy = getStrategy(argv._[0])
    , rootDirectory = getRootDirectory()

  return  { argv: argv
          , strategy: strategy
          , rootDirectory: rootDirectory
          }

  /** returns object with strategy 'U' [full user clone] or 'P' [project clone] */
  function getStrategy(arg) {
    var splitIndex = arg.indexOf('/')
    if(splitIndex === -1) {
      return  { strategy: 'U'
              , username: arg
              }
    } else {
      var argSplit = arg.split(splitIndex)
      return  { strategy: 'P'
              , username: argSplit[0]
              , project: argSplit[1]
              }
    }
  }

  /**
   * returns path of [-s] env.SYNC_ROOT, [-p] argv.path, or
   * defaults to env.SRC_ROOT/username
   */
  function getRootDirectory () {
    if (argv.sync) return env.SYNC_ROOT
    if (argv.path) return argv.path
    return join(env.SRC_ROOT, strategy.username)
  }
}

function getUrl(username, project, token) {
  token = token ? format('%s@', token) : ''
  return format('https://%sgithub.com/%s/%s', token, username, project)
}
