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
require 'local/email_checker'

class TestEmailChecker < Minitest::Test
  class TestedClass
    include EmailChecker
  end

  def setup
    @test_class = TestedClass.new
  end

  def test_normal_address
    address = 'alex.speranza@studio.unibo.it'
    assert @test_class.valid?(address)
  end

  def test_not_an_address
    not_an_address = 'test123'
    refute @test_class.valid?(not_an_address)
  end
end
