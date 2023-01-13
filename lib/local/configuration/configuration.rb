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

require 'psych'
require 'local/logger'
require 'local/configuration/duration'
require 'local/configuration/configuration_error'
require 'local/configuration/email_checker'
require 'local/configuration/validity_parser'

# Container for the runtime configuration.
module Configuration
  module CheckMode
    SERIAL = 0
    PARALLEL = 1
  end

  DEFAULT_SLEEP_DURATION = Duration.from('10 minutes')

  # The configuration starts with some default values
  @@configuration = {
    base_folder: '/data',
    use_subfolders: true,
    sleep_time: DEFAULT_SLEEP_DURATION,
    ca_configuration: {},
    certificate_configurations: [],
  }

  def self.get
    @@configuration
  end

  def self.load
    config = Psych.safe_load_file(ENV.fetch('CONFIG_PATH'), symbolize_names: true)
    @@configuration.update(Loader.new.parse_configuration(config))
  rescue KeyError
    LocalLogger.warning(
      'Failed to retrieve environmental variable "CONFIG_PATH". The default configuration will be used.'
    )
  end

  # The Configuration Loader class. Only for private use.
  class Loader
    include EmailChecker
    include ValidityParser

    def parse_configuration(configuration_hash)
      config = {}
      @field_manager.each do |element|
        field_name = element[:field_name]
        extractor = element[:extractor]
        check = element[:check]
        if configuration_hash.include? field_name
          config[field_name] = extract_field_from(configuration_hash, field_name, extractor, check)
        end
      end
      config
    end

    private

    # This constructor creates and initializes the lambdas used by the loader,
    # that creates a big method, but it is actually simple.
    # rubocop:disable Metrics/MethodLength
    def initialize
      @extractors = {
        identity: ->(v) { v },
        duration: ->(s) { Duration.from(s) },
        certificate_validity: lambda do |s|
          result = accept_validity s
          result[1].to_i unless result.nil?
        end,
        ca_configuration: ->(h) { parse_ca_specs(h) },
        certificate_specs: ->(a) { parse_certificate_specs(a) },
      }.freeze

      @checks = {
        always_accept: ->(_) { true },
        not_nil: ->(v) { !v.nil? },
        boolean: ->(v) { [true, false].include? v },
        email: ->(email) { accept_email? email },
      }.freeze

      @field_manager = [
        {
          field_name: :base_folder,
          extractor: @extractors[:identity],
          check: @checks[:always_accept],
        },
        {
          field_name: :use_subfolders,
          extractor: @extractors[:identity],
          check: @checks[:boolean],
        },
        {
          field_name: :sleep_time,
          extractor: @extractors[:duration],
          check: @checks[:not_nil],
        },
        {
          field_name: :ca_configuration,
          extractor: @extractors[:ca_configuration],
          check: @checks[:always_accept],
        },
        {
          field_name: :certificate_configurations,
          extractor: @extractors[:certificate_specs],
          check: @checks[:always_accept],
        },
      ].freeze
    end
    # rubocop:enable Metrics/MethodLength

    def extract_field_from(hash, field_name, extractor, result_check)
      result = extractor[hash[field_name]]
      raise ConfigurationError.new(field_name, hash[field_name]) unless result_check[result]

      result
    end

    def parse_ca_specs(ca_configuration)
      ca_configuration[:valid_for] =
        extract_field_from(ca_configuration, :valid_for, @extractors[:certificate_validity], @checks[:not_nil])
      ca_configuration[:email] =
        extract_field_from(ca_configuration, :email, @extractors[:identity], @checks[:email])
      ca_configuration
    end

    def parse_certificate_specs(certificate_specs)
      certificate_specs.map do |element|
        element[:valid_for] =
          extract_field_from(element, :valid_for, @extractors[:certificate_validity], @checks[:not_nil])
        element[:email] =
          extract_field_from(element, :email, @extractors[:identity], @checks[:email])
        element
      end
    end
  end
  private_constant :Loader
end
