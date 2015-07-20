#!/usr/bin/env node

var format = require('util')
  , path = require('path')
  , join = path.join

  , HOME = process.env.HOME || process.env.USERPROFILE
  , SSH_ROOT = join(HOME, '.ssh')
  , NPMRC_PATH = join(HOME, '.npmrc')

  // ZDOTDIR: ROOT LOCAITON OF ZOS CONFIGURATION
  , ZDOTDIR = process.env.ZDOTDIR || join(HOME, '.zsh')

  // ZOS_ROOT: ROOT LOCATION OF ZOS OPERATING SYSTEM
  , ZOS_ROOT = process.env.ZOS_ROOT || join(HOME, 'zos')

  // SYNC_ROOT: USED TO SYNC SPECIFIC VERSIONS OF CODE
  , SYNC_ROOT = process.env.ZOS_SYNC_ROOT || join(ZOS_ROOT, 'sync')

  // BUILD_ROOT: USED TO BUILD SPECIFIC VERSIONS OF CODE
  , BUILD_ROOT = process.env.ZOS_BUILD_ROOT || join(ZOS_ROOT, 'build')

  // RELEASE_ROOT: USED TO PRUNE SPECIFIC CODE VERSION RELEASES
  , RELEASE_ROOT = process.env.ZOS_RELEASE_ROOT || join(ZOS_ROOT, 'release')

  // ARTIFACTS_ROOT: USED TO PACKAGE SPECIFIC RELEASES BY VERSION
  , ARTIFACTS_ROOT = process.env.ZOS_ARTIFACTS_ROOT || join(ZOS_ROOT, 'artifacts')

  // SRC_ROOT: USED TO CLONE SOURCE CODE FOR DEVELOPMENT
  , SRC_ROOT = process.env.ZOS_SRC_ROOT || join(HOME, 'src')

  , GITHUB_API_URL = process.env.ZOS_GITHUB_API_URL || 'https://api.github.com'

module.exports =
  { HOME: HOME
  , SSH_ROOT: SSH_ROOT
  , NPMRC_PATH: NPMRC_PATH
  , ZDOTDIR: ZDOTDIR
  , ZOS_ROOT: ZOS_ROOT
  , SYNC_ROOT: SYNC_ROOT
  , BUILD_ROOT: BUILD_ROOT
  , RELEASE_ROOT: RELEASE_ROOT
  , ARTIFACTS_ROOT: ARTIFACTS_ROOT
  , SRC_ROOT: SRC_ROOT
  , GITHUB_API_URL: GITHUB_API_URL
  }
