#!/usr/bin/env node

/**
 * Clones a GitHub repo or all of a users GitHub repos
 * @module clone
 */

module.exports = clone
clone.Q = cloneQ
clone.sync = cloneSync

var path = require('path')
  , join = path.join
  , resolve = path.resolve
  , env = require('./env')
  , logger = require('./tools/logger')
  , bash = require('./tools/bash')
  , vasync = require('vasync')
  , vforeach = vasync.forEachParallel
  , vwaterfall  = vasync.waterfall
  , format = require('util').format
  , request = require('request')
  , mkdirp = require('mkdirp')
  , chalk = require('chalk')
  , yargs = require('yargs')
    .usage('usage: node clone [-s/--sync] [-p/--path] [-b/--branch] [-v/--version] [-o/--organization] username|organization[/repo]')
    .demand(1)
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


function clone (args, log, cb) {
  var ctx = buildContext(args)

  if(typeof log === 'function') {
    cb = log
    log = null
    logger.Q('clone').then(setupClone).then(onError)
  } else {
    setupClone(log)
  }

  function setupClone(_log) {
    log = _log
    mkdirp(ctx.rootDirectory, function (err) {
      if (err) onError(err)
      else _clone(ctx, log, cb)
    })
  }

  function onError (err) {
    ;(log && log.error(err, messages.errorOccurred))
    cb(err)
  }
}

function _clone (ctx, log, cb) {
  var basename = ctx.strategy.basename
  if(ctx.strategy.type === 'F') {
    var githubArgs = ctx.argv.organization ? ['-o', basename] : ['-u', basename]
    github.Q(githubArgs)
      .then(function(urls) {
        log.debug(cloneAll(urls, cb))
      })
      .then(onError)
  }
  else if(ctx.strategy.type === 'S') {
    var url = getUrl(basename, ctx.strategy.repo)
    log.debug(cloneSingle(url, cb))
  }

  function cloneAll(urls, _cb) {
    var vArgs = { 'func': cloneSingle
                , 'inputs': urls }
    log.debug(vforeach(vArgs, _cb))
  }

  function cloneSingle(url, _cb) {
    var repo = path.basename(url, '.git')
      , repoPath = join(ctx.rootDirectory, repo)
      , flow = getFlow(url, repoPath)
    vwaterfall(flow, function(err) {
      _cb(err, repo)
    })
  }

  function getFlow(url, repoPath) {
    return  [ function gitClone(_cb) { bash(commands.clone(url), ctx.rootDirectory, _cb) }
            , function gitFetch(_cb) { bash(commands.fetch(), repoPath, _cb) }
            , function gitCheckout(_cb) { bash(commands.checkout(ctx.argv), repoPath, _cb) }
            ]
  }
}

function cloneQ (args, log) {
  return Q.nfbind(clone)(args, log)
}

function cloneSync (args, log) {
  var ctx = buildContext(args)
  if(!log) log = logger.sync('clone')
  log.trace(env, 'env')
  log.trace(ctx, 'cloneSync context')

  try {
    if(ctx.strategy.type === 'F') {

    } else if(ctx.strategy.type === 'S') {
      cloneSingle(getUrl(ctx.strategy.basename, ctx.strategy.repo))
    }
  } catch (err) {
    log.error(err, messages.errorOccurred)
  }

  function cloneSingle(url) {
    var repo = path.basename(url, '.git')
      , repoPath = join(ctx.rootDirectory, repo)
    log.debug(mkdirp.sync(ctx.rootDirectory), 'mkdirp %s', ctx.rootDirectory)
    log.debug(bash.sync(commands.clone(url), ctx.rootDirectory), messages.cloneFinished)
    log.debug(bash.sync(commands.fetch(), repoPath), messages.fetchFinished)
    log.debug(bash.sync(commands.checkout(ctx.argv), repoPath), messages.checkoutFinished)
  }
}

function buildContext (args) {
  var argv = yargs.parse(args)
    , strategy = getStrategy(argv)
  return  { argv: argv
          , strategy: strategy
          , rootDirectory: getRootDirectory()
          }

  /** returns object with strategy type 'F' [full clone] or 'S' [single clone] */
  function getStrategy(argv) {
    var arg = argv._[0]
      , splitIndex = arg.indexOf('/')

    return splitIndex === -1 ?
      { type: 'F', basename: arg } :
      { type: 'S'
      , basename: arg.slice(0, splitIndex)
      , repo: arg.slice(splitIndex + 1)
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

if (!module.parent) clone.sync(process.argv.slice(2))
