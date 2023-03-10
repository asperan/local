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

require_relative 'lib/local/version'

Gem::Specification.new do |spec|
  spec.name = 'local'
  spec.version = Local::VERSION
  spec.authors = [
    'Alex Speranza',
  ]
  spec.email = [
    'alex.speranza@studio.unibo.it',
  ]

  spec.summary = 'Local Certificate Authority with auto renewal'
  spec.description = 'LoCAl is a local certificate authority which can generate and renew certificates.'
  spec.homepage = 'https://github.com/asperan/local'
  spec.required_ruby_version = '>= 3.1.2'
  spec.license = 'AGPL-3.0-or-later'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob("#{File.expand_path(__dir__)}/lib/**/*.rb")
  spec.bindir = 'bin'
  spec.executables = [
    'local',
  ]
  spec.require_paths = [
    'lib',
  ]

  spec.add_dependency 'logger', '~> 1.5.3'
  spec.add_dependency 'psych', '~> 5.0.1'
end
