
# Description:
#   Returns the URL of the first google hit for a query
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot google me <query> - Googles <query> & returns 1st result's URL
#
# Author:
#   searls

module.exports = (robot) ->
  robot.respond /(google)( me)? (.*)/i, (msg) ->
    googleMe msg, msg.match[3], (url) ->
      msg.send msg.message.user.name + ": Here you go! " + url

googleMe = (msg, query, callback) ->
  msg.http('http://www.google.ca/search')
    .query({q: query})
    .get() (err, res, body) ->
      callback body.match(/class="r"><a href="\/url\?q=([^"]*)(&amp;sa.*)">/)?[1] || "Sorry, Google had zero results for '#{query}'"
