require 'clockwork'
require './lib/poll'

module Clockwork
  every(15.minutes, 'poll.aoc') { Poll.run }
end
