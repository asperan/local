# LoCAl is a simple Certificate Authority bot.
# Copyright (C) 2023  Alex Speranza

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# frozen_string_literal: true

# Time interval with a unit.
class Duration
  DURATION_PATTERN = /(\d+) (ms|milliseconds|s|seconds|m|minutes|h|hours|d|days)/

  # Module with some time units. The value of the constants represents the number of seconds in 1 Unit.
  module Unit
    MILLISECOND = 1.0 / 1000
    SECOND = 1.0
    MINUTE = 60.0
    HOUR = MINUTE * 60
    DAY = HOUR * 24
  end

  def initialize(value, unit)
    @value = value
    @unit = unit
  end

  def self.from(str)
    DURATION_PATTERN.match(str) do |match|
      return nil if match.nil?

      value = match[1].to_i
      unit = case match[2]
             when 'ms', 'milliseconds'
               Unit::MILLISECOND
             when 's', 'seconds'
               Unit::SECOND
             when 'm', 'minutes'
               Unit::MINUTE
             when 'h', 'hours'
               Unit::HOUR
             when 'd', 'days'
               Unit::DAY
             end
      Duration.new(value, unit)
    end
  end

  def seconds
    @value * @unit
  end
end
