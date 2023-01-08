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

require 'test_helper'
require 'local/duration'
require 'local/configuration_error'

class TestDuration < Minitest::Test
  def test_duration_in_seconds
    duration_string = '10 s'
    assert_equal 10, Duration.from(duration_string).seconds
  end

  def test_duration_in_different_unit
    duration_string = '10 minutes'
    assert_equal 600, Duration.from(duration_string).seconds
  end

  def test_duration_in_milliseconds
    duration_string = '50 ms'
    assert_equal 0.05, Duration.from(duration_string).seconds
  end

  def test_invalid_string
    duration_string = '10'
    assert_nil Duration.from(duration_string)
  end
end
