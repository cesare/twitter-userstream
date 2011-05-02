#!/usr/bin/env coffee

TwitterUserstream = require('twitter-userstream').TwitterUserstream
settings = require './twitter-settings'
sys = require 'sys'
util = require 'util'

us = new TwitterUserstream settings.tokens, (us) ->
  show = (title, data) ->
    sys.puts "--- " + title + " ---"
    sys.puts util.inspect(data, false, null)
    sys.puts ""
  
  us.on "friends", (data) ->
    sys.puts "--- friends ---"
    sys.puts "Total " + data.friends.length + " friends"
    sys.puts ""
  
  us.on "tweet", (tweet) -> show "tweet", tweet
  us.on "follow", (data) -> show "follow", data
  us.on "delete", (data) -> show "delete", data

us.start()
