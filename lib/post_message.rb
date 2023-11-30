# frozen_string_literal: true

require 'net/http'

# helper to do HTTP to slack/discord
class PostMessage
  def self.send_slack(text)
    payload = { text:, icon_emoji: ':santa:',
                username: 'The North Poll' }
    resp = Net::HTTP.post(
      URI(ENV['SLACK_WEBHOOK_URL']),
      payload.to_json,
      'Content-Type' => 'application/json'
    )
    raise "slack API error: #{resp.body}" unless resp.code.to_i.between?(200, 299)

    resp
  end

  def self.send_discord(text)
    discord_uri = URI(ENV['DISCORD_WEBHOOK_URL'])
    discord_req = Net::HTTP::Post.new(discord_uri)
    discord_req.set_form_data(content: text)
    Net::HTTP.start(discord_uri.hostname, discord_uri.port, use_ssl: true) do |http|
      http.request(discord_req)
    end
  end

  def self.send(text)
    if ENV['SLACK_WEBHOOK_URL']
      send_slack(text)
    elsif ENV['DISCORD_WEBHOOK_URL']
      send_discord(text)
    else
      raise 'set SLACK_WEBHOOK_URL or DISCORD_WEBHOOK_URL'
    end
  end
end
