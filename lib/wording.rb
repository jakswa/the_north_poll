# frozen_string_literal: true

# a class to take in AOC JSON and decide how to word messages
class Wording
  ProblemStar = Struct.new(:day, :get_star_ts)
  Member = Struct.new(:name, :total_stars, :problem_stars)

  def initialize(member_attr_json)
    @members = member_attr_json.map do |member_attrs|
      probs = (member_attrs['completion_day_level'] || [])&.filter do |_problem, stars|
        stars.find { |_star, star_attrs| Time.at(star_attrs&.dig('get_star_ts') || 0) > stars_since }
      end
      problem_stars = probs.flat_map {|day, stars| stars.map {|star| ProblemStar.new(day, star['get_star_ts']) }}

    end
  end
end
