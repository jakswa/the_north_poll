# frozen_string_literal: true

require 'poll'

class PollTest < TLDR
  def test_interval_for_2023
    interval = Poll.interval_with_jitter(2023, 0)
    assert(interval >= 15.minutes)
    assert(interval < (15.minutes + 30.seconds))
  end

  def test_interval_for_2015
    interval = Poll.interval_with_jitter(2015, 0)
    expected_min = 9 * 15.minutes
    assert(interval >= expected_min)
    assert(interval < (expected_min + 30.seconds))
  end
end
