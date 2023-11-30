# frozen_string_literal: true

require 'active_support/all'
require 'net/http'
require 'json'

require_relative './post_message'

# A poller class that does aoc/discord HTTP
class Poll
  # required ENV vars here
  AOC_SESSION_COOKIE = ENV.fetch('AOC_SESSION_COOKIE')
  DISCORD_URI = URI(ENV.fetch('DISCORD_WEBHOOK_URL'))

  # other constants here
  AOC_URL_TEMPLATE = 'https://adventofcode.com/%s/leaderboard/private/view/%s.json'
  DEFAULT_AOC_YEAR = ENV.fetch('AOC_YEAR', 1.month.ago.year)

  def self.interval_with_jitter(year, index)
    # older years have lower priority, get bigger poll intervals
    interval = (15 * (Time.now.year - year + 1)).minutes

    # space out the herd over time, otherwise fast-firing http clumps
    interval + (rand(15) + index).seconds
  end

  def self.run(...)
    new(...).run
  end

  # leaderboard is only required if you don't pass one in
  def initialize(year: DEFAULT_AOC_YEAR, time_window: nil, leaderboard: ENV.fetch('AOC_LEADERBOARD'))
    @aoc_year = year
    @leaderboard = leaderboard
    @time_window = time_window
  end

  def run
    members_changed = aoc_json['members'].filter do |_member_id, attrs|
      last_star = attrs['last_star_ts']
      last_star && Time.at(last_star) > stars_since
    end

    return if members_changed.empty?

    content = members_changed.map { |_id, member_attrs| content_for(member_attrs) }
    PostMessage.send(content)
  end

  private

  def content_for(member_attrs)
    msg = "- #{member_attrs['name']} is now up to #{member_attrs['stars']} stars for #{@aoc_year}!"

    changed_problems(member_attrs).each do |problem, stars|
      msg << "\n  - Day #{problem}: :star:"
      msg << ':star2:' if stars.length == 2
    end
    msg
  end

  # @return [Array<problem, star_count>] a list of problems that
  #   stars have appeared on within the last time_window
  def changed_problems(member)
    member['completion_day_level']&.filter do |_problem, stars|
      stars.find { |_star, star_attrs| Time.at(star_attrs&.dig('get_star_ts') || 0) > stars_since }
    end || []
  end

  def aoc_json
    return @aoc_json if defined?(@aoc_json)

    req = Net::HTTP::Get.new(aoc_uri)
    req['Cookie'] = AOC_SESSION_COOKIE

    res = Net::HTTP.start(aoc_uri.hostname, aoc_uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    @aoc_json = JSON.parse(res.body)
  end

  # ie 15.minutes.ago
  def stars_since
    @time_window ||=
      begin
        arr = ENV.fetch('TIME_WINDOW', '15-minutes')
                 .split('-').tap { |win| win[0] = win[0].to_i }
        arr[0].send(arr[1])
      end
    @time_window.ago
  end

  def aoc_uri
    @aoc_uri ||= URI(format(AOC_URL_TEMPLATE, @aoc_year, @leaderboard))
  end
end
