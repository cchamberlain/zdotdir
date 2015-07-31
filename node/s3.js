#!/usr/bin/env node

/**
 * Clones a GitHub repo or all of a users GitHub repos
 * @module clone
 */

module.exports = clone
clone.Q = cloneQ
clone.sync = cloneSync

if (!module.parent) clone.sync(process.argv)

var logger = require('./tools/log')
  , bash = require('./tools/bash')
  , path = require('path')
  , join = path.join
  , vasync = require('vasync')
  , vforeach = vasync.forEachParallel
  , vwaterfall  = vasync.waterfall
  , format = require('util').format
  , env = require('./env')
  , request = require('request')
  , mkdirp = require('mkdirp')
  , yargs = require('yargs')
    .usage('usage: $0 [-s/--sync] [-p/--path] [-b/--branch] [-v/--version] [-o/--organization] username|organization[/repo]')
    .option('s'
    , { alias: 'sync'
      , demand: true
      , default: false
      , describe: 'clone to sync root'
      , type: 'boolean'
    })
    .option('p'
    , { alias: 'path'
      , demand: true
      , default: env.SRC_ROOT
      , describe: 'path to clone into'
      , type: 'string'
    })
    .option('b'
    , { alias: 'branch'
      , demand: true
      , default: 'master'
      , describe: 'the branch to checkout'
      , type: 'string'
    })
    .option('v'
    , { alias: 'version'
      , demand: false
      , describe: 'the annotated version to checkout'
      , type: 'string'
    })
    .option('o'
    , { alias: 'organization'
      , demand: false
      , default: false
      , describe: 'specifies to use organizations instead of usernames'
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
      mkdirp(ctx.rootDirectory, function (err) {
        if (err) onError(err)
        else _clone(ctx, cb)
      })
    }
  })

  function onError (err) {
    log.error(err, messages.errorOccurred)
    cb(err)
  }
}

function _clone (ctx, cb) {
  if(ctx.strategy === 'F') {
    github(githubArgs(), function(err, urls) {
      if(err) onError(err)
      else orchestrateParallel(urls, cb)
    })

    function githubArgs() {
      return ctx.argv.organization ? ['-o', basename] : ['-u', basename]
    }
  }
  else if(ctx.strategy === 'P') {
    log.debug(orchestrate(getUrl(ctx.basename, ctx.repo), cb))
  }

  function orchestrateParallel(urls, cbOrchestrate) {
    var vArgs = { 'func': orchestrate
                , 'inputs': urls }
    log.debug(vforeach(vArgs, cbOrchestrate))
  }

  function orchestrate(url, cbOrchestrate) {
    var repo = path.basename(url, '.git')
      , flow =
        [ function cloneUrl(_cb) { bash(commands.clone(url), ctx.rootDirectory, _cb) }
        , function onClone(_cb) { bash(commands.fetch(), repo, _cb) }
        , function onFetch(_cb) { bash(commands.checkout(ctx.argv), repo, _cb) }
        ]
    vwaterfall(flow, function(err) {
      cbOrchestrate(err, repo)
    })
  }
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
    stdout = bash.sync(commands.fetch(), ctx.repo)
    log.info(stdout, messages.fetchFinished)
    stdout = bash.sync(commands.checkout(ctx.argv), ctx.repo)
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

  /** returns object with strategy 'F' [full clone] or 'P' [repo clone] */
  function getStrategy(arg) {
    var splitIndex = arg.indexOf('/')
    if(splitIndex === -1) {
      return  { strategy: 'F'
              , basename: arg
              }
    } else {
      var argSplit = arg.split(splitIndex)
      return  { strategy: 'P'
              , basename: argSplit[0]
              , repo: argSplit[1]
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
    return join(env.SRC_ROOT, strategy.basename)
  }
}

function getUrl(basename, repo, token) {
  token = token ? format('%s@', token) : ''
  return format('https://%sgithub.com/%s/%s', token, basename, repo)
}
