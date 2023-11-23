# frozen_string_literal: true

require 'clockwork'
require_relative 'poll'

# A standard clockwork config file. See gem docs for more.
module Clockwork
  (2015..2023).each.with_index do |year, index|
    interval = Poll.interval_with_jitter(year, index)
    task_name = "poll.aoc.#{year}.#{interval.iso8601}"

    every(interval, task_name, skip_first_run: true) do
      Poll.run(year: year.to_s, time_window: interval.minutes)
    end
  end
end
