# The North Poll

An Advent of Code HTTP poller, this checks for new stars on
a configured leaderboard and posts to a configured discord
or slack webhook.

## Poll Windows

By default it will poll each year, but older years will
have larger poll intervals. The intervals start at 15min,
and each older year adds 15min. In 2023, the year 2015
is polled every 2h15m.

## Environment Variables

- `AOC_SESSION_COOKIE` is set to value of your
  adventofcode.com session (found in browser dev console)
  - NOTE: it includes the starting `session=` piece
- `AOC_LEADERBOARD` is set to the private leaderboard
  that you would like to stalk. You can find this on the
  end of the URL when viewing the leaderboard
  (`.../private/view/<leaderboard>`).
- one of:
  - `SLACK_WEBHOOK_URL` is a legacy slack webhook url
  - `DISCORD_WEBHOOK_URL` is a discord webhook url

## Deployment

There is a fly.toml and Dockerfile showing how I deployed
this to fly.io. You want a single machine running, and 
you don't want it to automatically stop while idle.

The steps for initially deploying are:
1. run `fly launch` to create an app
2. set environment variables using `fly secrets set VAR=val`
3. run `fly deploy` and hope no errors show up in `fly logs`
