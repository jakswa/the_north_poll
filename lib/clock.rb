# frozen_string_literal: true

require 'clockwork'
require_relative 'poll'

# A standard clockwork config file. See gem docs for more.
module Clockwork
  (2015..2023).each.with_index do |year, index|
    time_window = Poll.interval_with_jitter(year, index)
    task_name = "poll.aoc.#{year}.#{time_window.iso8601}"

    every(time_window, task_name, skip_first_run: true) do
      Poll.run(year: year.to_s, time_window:)
    end
  end
end
