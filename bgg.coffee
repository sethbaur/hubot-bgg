# Description:
#   Allows hubot to seach BGG database
#
# Dependencies:
#   "xml2js": "0.4.4"
#
# Commands:
#   hubot boardgame <query> - search for a board game by name
#
# Author:
#   sethbaur

module.exports = (robot) ->
  parseString = require('xml2js').parseString

  robot.respond /boardgame (.*)$/i, (msg) ->
    query = encodeURIComponent(msg.match[1])
    url = "http://www.boardgamegeek.com/xmlapi/search?search=#{query}"
    msg.http(url)
      .get() (err, _, body) ->
        return msg.send "Sorry, bgg failed" if err
        parseString body, (err, result) ->
          if result.boardgames.boardgame
            id = result.boardgames.boardgame[0].$.objectid
            url = "http://www.boardgamegeek.com/xmlapi2/thing?type=boardgame&id=#{id}"
            msg.http(url)
              .get() (err, _, body) ->
                parseString body, (err, result) ->
                  game = result.items.item[0]
                  name = game.name[0].$.value
                  year = game.yearpublished[0].$.value
                  info = name + " (#{year}), designed by "
                  designers = []
                  mechanics = []
                  for link in game.link
                    if link.$.type == "boardgamedesigner"
                      designers.push link.$.value
                    if link.$.type == "boardgamemechanic"
                      mechanics.push link.$.value
                  info += designers.join(", ")
                  msg.send info
                  msg.send "Mechanics: #{mechanics.join(', ')}"
                  msg.send "http://boardgamegeek.com/boardgame/#{id}"
          else
            msg.send "Hmm, sorry, couldn't find that game."
