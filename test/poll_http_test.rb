# frozen_string_literal: true

require 'poll'

class PollHttpTest < TLDR
  BLANK_BODY = %[{"members":[]}]
  DUSTY_BODY = %[{"members":{"1": { "name": "dusty", "last_star_ts": #{5.years.ago.to_i}}}}]

  def stub_and_run(aoc_body: BLANK_BODY, member: 'dusty', leaderboard:)
    aoc_http = stub_request(:get, /adventofcode.*#{leaderboard}/).to_return(body: aoc_body)
    discord_http = stub_request(:post, /discord/).with(body: /#{member}/).to_return(status: 201)
    Poll.run(leaderboard:)
    [aoc_http, discord_http]
  end

  def test_no_members
    aoc_http, discord_http = stub_and_run(leaderboard: 'nomemberstest')
    assert_requested(aoc_http)
    assert_not_requested(discord_http)
  end

  def test_single_dusty_member
    aoc_http, discord_http = stub_and_run(aoc_body: DUSTY_BODY, leaderboard: 'dustytest')
    assert_requested(aoc_http)
    assert_not_requested(discord_http)
  end

  def test_active_member
    aoc_http, discord_http = stub_and_run(aoc_body: active_body, member: 'activia', leaderboard: 'activetest')
    assert_requested(aoc_http)
    assert_requested(discord_http)
  end

  private

  def active_body
    completion = %["completion_day_level": { "1": {"1": {"get_star_ts":#{5.seconds.ago.to_i}}}}]
    %[{"members":{"1": { "name": "activia", "last_star_ts": #{5.seconds.ago.to_i}, #{completion} }}}]
  end
end
