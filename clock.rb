require 'clockwork'
require './lib/poll'

module Clockwork
  every(15.minutes, 'poll.aoc', skip_first_run: true) { Poll.run }
end
