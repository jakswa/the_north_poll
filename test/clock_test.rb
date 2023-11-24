# frozen_string_literal: true

require 'clock'

# this exists because I keep breaking these
class ClockTest < TLDR
  def events
    Clockwork.manager.instance_variable_get('@events')
  end

  def test_interval2015
    interval = events.find { |event| event.job.include?('2015') }
    assert interval.job.include?('PT135M')
  end

  def test_interval2023
    interval = events.find { |event| event.job.include?('2023') }
    assert interval.job.include?('PT15M')
  end
end
