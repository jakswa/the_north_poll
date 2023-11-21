require 'clockwork'
require './lib/poll'

module Clockwork
  (2015..2023).each.with_index do |year, index|
    interval = 15 * (Time.now.year - year + 1) # extra 15min for each older year
    every(interval.minutes, "poll.aoc.#{year}", skip_first_run: true) do
      Poll.run(year: year.to_s, time_window: [interval, 'minutes'])
    end
  end
end
