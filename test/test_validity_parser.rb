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
require 'local/configuration/validity_parser'

class TestValidityParser < Minitest::Test
  class TestedClass
    include ValidityParser
  end

  def setup
    @test_class = TestedClass.new
  end

  def test_normal_validity
    validity_string = '365 days'
    assert @test_class.accept_validity(validity_string)
  end

  def test_not_a_validity
    not_a_validity = 'test123'
    refute @test_class.accept_validity(not_a_validity)
  end

  def test_short_validity
    validity_string = '30 d'
    assert @test_class.accept_validity(validity_string)
  end
end
