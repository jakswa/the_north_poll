# frozen_string_literal: true

require 'net/http'
require 'json'

class Poll
  # required ENV vars here
  AOC_LEADERBOARD = ENV.fetch('AOC_LEADERBOARD')
  AOC_URL_TEMPLATE = 'https://adventofcode.com/%s/leaderboard/private/view/%s.json'
  DISCORD_URI = URI(ENV.fetch('DISCORD_WEBHOOK_URL'))

  # other constants here
  AOC_YEAR = ENV.fetch('AOC_YEAR', 1.month.ago.year)
  AOC_URI = URI(format(AOC_URL_TEMPLATE, AOC_YEAR, AOC_LEADERBOARD))
  TIME_WINDOW = ENV.fetch('TIME_WINDOW', '15-minutes')
    .split('-').tap { |arr| arr[0] = arr[0].to_i }

  def self.run(...)
    new(...).run
  end

  def run
    members_changed = aoc_json['members'].filter do |member_id, attrs|
      last_star = attrs['last_star_ts']
      last_star && Time.at(last_star) > stars_since
    end

    return if members_changed.empty?
    content = members_changed.map do |member_id, member_attrs|
      problem, stars = changed_problem(member_attrs)
      star_count_words = stars.length > 1 ? 'stars' : 'star'
      "#{member_attrs['name']} now has #{stars.length} #{star_count_words} on problem #{problem} (#{AOC_YEAR})"
    end
    
    puts "Done. HTTP #{get_discord_response(content.join("\n")).code}."
  end

  private

  # @return [Array<problem, star_count>] a list of problems that
  #   stars have appeared on within the last TIME_WINDOW
  def changed_problem(member)
    member['completion_day_level']&.find do |problem, stars|
      stars.find {|_star, star_attrs| Time.at(star_attrs&.dig('get_star_ts') || 0) > stars_since }
    end
  end

  def get_discord_response(content)
    discord_req = Net::HTTP::Post.new(DISCORD_URI)
    discord_req.set_form_data(content:)
    Net::HTTP.start(DISCORD_URI.hostname, DISCORD_URI.port, use_ssl: true) do |http|
      http.request(discord_req)
    end
  end

  def aoc_json
    return @aoc_json if defined?(@aoc_json)

    req = Net::HTTP::Get.new(AOC_URI)
    req['Cookie'] = ENV.fetch('AOC_SESSION_COOKIE')

    res = Net::HTTP.start(AOC_URI.hostname, AOC_URI.port, use_ssl: true) do |http|
      http.request(req)
    end

    @aoc_json = JSON.parse(res.body)
  end

  # ie 15.minutes.ago
  def stars_since
    TIME_WINDOW[0].send(TIME_WINDOW[1]).ago
  end
end
