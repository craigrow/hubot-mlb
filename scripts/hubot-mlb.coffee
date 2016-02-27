# Description:
#   Get the score of your favorite MLB team's latest game
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   how bout|about them|those <team name> - tells you how your team did yesterday
#
# Author:
#	craigrow

module.exports = (robot) ->
  robot.hear /how (about|bout) (them|those) (.*)/i, (msg) ->
    team = msg.match[1]

    city = getCity(team)

    day = getDay() - 1
    month = getMonth()
    year = getYear()

    msg.http('http://mlb.mlb.com/gdcross/components/game/mlb/year_' + year + '/month_' + month + '/day_' + day + '/master_scoreboard.json')
      .get() (err, res, body) ->
        if res.statusCode is 404
          msg.send "Sorry, it appears there were no games yesterday"
          return
        result = JSON.parse(body)

        i = 0

        while result.data.games.game[i].home_team_city != city & result.data.games.game[i].away_team_city != city
            i++
            if result.data.games.game[i] is undefined
              break

        if result.data.games is undefined or result.data.games.game[i] is undefined
          msg.send "The " + team + " did not play yesterday"
        else
          away_team_city = result.data.games.game[i].away_team_city
          away_team_score = result.data.games.game[i].linescore.r.away
          home_team_city = result.data.games.game[i].home_team_city
          home_team_score = result.data.games.game[i].linescore.r.home

          #debug
          #msg.send "visitor: " + away_team_city
          #msg.send "home: " + home_team_city
          #debug

          winner = findWinner(home_team_city, home_team_score, away_team_city, away_team_score, city)

          msg.send "The " + team + " " + winner + " yesterday"

          gamescore = away_team_city + " "  + away_team_score + " at " + home_team_city + " " + home_team_score

          msg.send gamescore

  getDay = () ->
    today = new Date
    dd = today.getDate()
    if dd < 10
      dd = '0' + dd
    else dd

  getMonth = () ->
    today = new Date
    mm = today.getDate() + 1
    if mm < 10
      mm = '0' + mm
    else mm

  getYear = () ->
    today = new Date
    yyyy = today.getFullYear()

  getCity = (team) ->
    if team is "Mariners" or team is "mariners"
      city = "Seattle"
    else if team is "Angels" or team is "angels"
      city = "LA Angels"
    else if team is "Astros" or team is "astros"
      city = "Houston"
    else if team is "Rangers" or team is "rangers"
      city = "Texas"
    else if team is "Royals" or team is "royals"
      city = "Kansas City"
    else if team is "Twins" or team is "twins"
      city = "Minnesota"
    else if team is "White Sox" or team is "white sox"
      city = "Chi White Sox"
    else if team is "Tigers" or team is "tigers"
      city = "Detroit"
    else if team is "Indians" or team is "indians"
      city = "Cleveland"
    else if team is "Orioles" or team is "orioles"
      city = "Baltimore"
    else if team is "Red Sox" or team is "red sox" or team is "sox" or team is "Sox"
      city = "Boston"
    else if team is "Yankees" or team is "yankees"
      city = "NY Yankees"
    else if team is "Blue Jays" or team is "blue jays" or team is "Jays" or team is "jays"
      city = "Toronto"
    else if team is "Rays" or "rays"
      city = "Tampa Bay"
    else if team is "Dodgers" or team is "dodgers"
      city = "LA Dodgers"
    else if team is "Giants" or team is "giants"
      city = "San Francisco"
    else if team is "Padres" or team is "padres"
      city = "San Diego"
    else if team is "Rockies" or team is "rockies"
      city = "Colorado"
    else if team is "Reds" or team is "reds"
      city = "Cincinnati"
    else if team is "Cubs" or team is "cubs" or team is "cubbies" or team is "Cubbies"
      city = "Chi Cubs"
    else if team is "Brewers" or "brewers"
      city = "Milwaukee"
    else if team is "Cardinals" or team is "cardinals" or team is "cards" or team is "Cards"
      city = "St. Louis"
    else if team is "Pirates" or team is "pirates"
      city = "Pittsburgh"
    else if team is "Phillies" or team is "phillies"
      city = "Philadelphia"
    else if team is "Mets" or team is "mets"
      city = "NY Mets"
    else if team is "Braves" or team is "braves"
      city = "Atlanta"
    else if team is "Marlins" or team is "marlins"
      city = "Miami"
    else if team is "Nationals" or "nationals" or "Nats" or "nats"
      city = "Washington"
    else
      city = "I don't know the " + team

  findWinner = (home_team_city, home_team_score, away_team_city, away_team_score, city) ->
    if home_team_score > away_team_score and home_team_city is city
      "won"
    else if home_team_score > away_team_score and away_team_city is city
      "lost"
    else if away_team_score > home_team_score and home_team_city is city
      "lost"
    else if away_team_score > home_team_score and away_team_city is city
      "won"
    else
      "error"