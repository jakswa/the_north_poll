# frozen_string_literal: true

require 'net/http'

class PostMessage
  def self.send(text)
    if ENV['SLACK_WEBHOOK_URL']
      payload = { text:, icon_url: 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
                  username: 'The North Poll' }
      Net::HTTP.post(
        URI(ENV['SLACK_WEBHOOK_URL']),
        payload.to_json,
        'Content-Type' => 'application/json'
      )
    elsif ENV['DISCORD_WEBHOOK_URL']
      discord_uri = URI(ENV['DISCORD_WEBHOOK_URL'])
      discord_req = Net::HTTP::Post.new(discord_uri)
      discord_req.set_form_data(content: text)
      Net::HTTP.start(discord_uri.hostname, discord_uri.port, use_ssl: true) do |http|
        http.request(discord_req)
      end
    else
      raise 'set SLACK_WEBHOOK_URL or DISCORD_WEBHOOK_URL'
    end
  end
end
