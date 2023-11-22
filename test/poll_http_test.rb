# frozen_string_literal: true

require 'poll'

class PollHttpTest < TLDR
  BLANK_BODY = %[{"members":[]}]
  DUSTY_BODY = %[{"members":{"1": { "last_star_ts": #{5.years.ago.to_i}}}}]

  def teardown
    super
    WebMock.reset!
  end

  def stub_and_run(aoc_body: BLANK_BODY)
    @aoc_http = stub_request(:get, /adventofcode/).to_return(body: aoc_body)
    @discord_http = stub_request(:post, /discord/).to_return(status: 201)
    Poll.run(leaderboard: 'fake123leaderboard')
  end

  def test_no_members
    stub_and_run
    assert_requested(@aoc_http)
    assert_not_requested(@discord_http)
  end

  def test_single_dusty_member
    stub_and_run(aoc_body: DUSTY_BODY)
    assert_requested(@aoc_http)
    assert_not_requested(@discord_http)
  end

  def test_active_member
    stub_and_run(aoc_body: active_body)
    assert_requested(@aoc_http)
    assert_requested(@discord_http)
  end

  private

  def active_body
    completion = %["completion_day_level": { "1": {"1": {"get_star_ts":#{5.seconds.ago.to_i}}}}]
    %[{"members":{"1": { "last_star_ts": #{5.seconds.ago.to_i}, #{completion} }}}]
  end
end
