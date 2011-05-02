#
#
#

sys 　　　= require 'sys'
events = require 'events'
util 　　= require 'util'
OAuth 　= require('oauth').OAuth

class TwitterUserstream extends events.EventEmitter
  constructor: (args, initializer) ->
    events.EventEmitter.call this
    
    @consumerKey 　　　　　　= args.consumerKey
    @consumerSecret 　　　= args.consumerSecret
    @accessToken 　　　　　　= args.accessToken
    @accessTokenSecret = args.accessTokenSecret
    
    if initializer
      initializer(this)
  
  requestTokenUrl: 'https://twitter.com/oauth/request_token'
  accessTokenUrl:  'https://twitter.com/oauth/access_token'
  oauthVersion:    '1.0a'
  signatureMethod: 'HMAC-SHA1'
  requestUri:      'https://userstream.twitter.com/2/user.json'
  
  createClient: ->
    new OAuth @requestTokenUrl, @accessTokenUrl, @consumerKey, @consumerSecret, @oauthVersion, null, @signatureMethod
  
  
  createRequest: ->
    client = @createClient()
    client.get @requestUri, @accessToken, @accessTokenSecret
  
  
  parseResponse: (chunk) ->
    elements = chunk.toString().split("\r").map((str) -> if str == "\n" then "" else str)
    lastIndex = elements.length - 1
    
    residue = @residue
    if residue
      elements[0] = residue + elements[0]
    
    @residue = elements[lastIndex]
    
    elements.slice(0, lastIndex).filter((str) -> str && str != "\n")
  
  parseEvent: (eventText) ->
    try
      return JSON.parse(eventText)
    catch e
      @emit("parseError", e, eventText)
  
  dispatchEvent: (eventObject) ->
    if eventObject.friends
      @emit("friends", eventObject)
    else if eventObject.delete
      @emit("delete", eventObject)
    else if (eventObject.event == "follow")
      @emit("follow", eventObject)
    else if (eventObject.event == "favorite")
      @emit("favorite", eventObject)
    else
      @emit("tweet", eventObject)
  
  start: ->
    request = @createRequest()
    request.on "response", (response) =>
      response.on "data", (chunk) =>
        eventObjects = @parseResponse(chunk)
        eventObjects.forEach (evt) =>
          obj = @parseEvent(evt)
          @dispatchEvent(obj)
      
      response.on "end", =>
        @emit("end")
    request.end();


module.exports.TwitterUserstream = TwitterUserstream
