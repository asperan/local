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

require 'local/version'
require 'local/logger'
require 'local/configuration/configuration'
require 'local/certificate/certificate_manager'

# Entrypoint of the program
module Local
  class Error < StandardError; end

  def self.main
    LocalLogger.info 'Daemon started.'
    Configuration.load
    LocalLogger.info 'Configuration loaded.'
    @@configuration = Configuration.get
    cycle
  end

  CA_NAME = 'ca'

  def self.cycle
    LocalLogger.info 'Object initialization started.'
    ca_man = CertificateManager.new(directory_path(CA_NAME), CA_NAME, @@configuration[:ca_configuration])
    ca_paths = { key: ca_man.private_key, crt: ca_man.certificate }
    certificate_managers = @@configuration[:certificate_configurations].map do |element|
      expanded_cn = expand_cn(element[:common_name])
      CertificateManager.new(directory_path(expanded_cn), expanded_cn, element, ca_paths)
    end
    LocalLogger.info 'Objects initialized.'

    loop do
      LocalLogger.info 'Validating certificates...'
      ca_man.check_certificate
      certificate_managers.each(&:check_certificate)
      LocalLogger.info 'Certificates checked, going to sleep...'
      sleep @@configuration[:sleep_time].seconds
    rescue Interrupt
      raise StopIteration
    end

    LocalLogger.info 'Program Interrupted.'
  end

  def self.directory_path(expanded_cn)
    "#{@@configuration[:base_folder]}/certificates" \
      "#{@@configuration[:use_subfolders] ? "/#{before_first_dot(expanded_cn)}" : ''}"
  end

  def self.before_first_dot(str)
    first_dot_index = str.index('.')
    return str if first_dot_index.nil?

    str[0, first_dot_index]
  end

  def self.expand_cn(common_name)
    if common_name.start_with?('*')
      common_name.sub('*', 'wildcard')
    else
      common_name
    end
  end
end
