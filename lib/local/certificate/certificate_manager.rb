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

require 'fileutils'
require 'local/logger'

# This class check the validity of a certificate, given a configuration.
class CertificateManager
  # TODO: add toggle for certificate self-signed or CA-signed
  def initialize(directory_path, name, certificate_configuration)
    FileUtils.mkdir_p directory_path
    @base_name = File.expand_path("#{directory_path}/#{name}")
    @certificate_configuration = certificate_configuration
    # @self_sign = self_sign
  end

  def check_certificate
    generate_key unless key_exist?

    if certificate_valid?
      LocalLogger.info "Certificate '#{certificate}' is still valid. Nothing to be done."
    else
      LocalLogger.info "Certificate '#{certificate} is invalid. It will be renewed."
      if File.exist?(certificate)
        extract_certificate_signing_request
      else
        create_certificate_signing_request
      end
      create_certificate
      delete_certificate_signing_request
    end
  end

  private

  def private_key = "#{@base_name}.key"

  def csr = "#{@base_name}.csr"

  def certificate = "#{@base_name}.crt"

  def key_exist?
    File.exist?(private_key)
  end

  def generate_key
    LocalLogger.info 'Generating private key'
    command_string = "openssl genrsa -out #{private_key} 4096 2> /dev/null"
    exec_system_command(
      command_string,
      "Private key for '#{private_key}' generated.",
      "Failed to generate key for '#{private_key}'."
    )
  end

  def certificate_valid?
    return false unless File.exist?(certificate)

    current_date = `date +%s`.strip.to_i
    # TODO: Line below is too long
    expiration_date = `date -d "$(openssl x509 -noout -text -in #{certificate} | grep 'Not After' | cut -d ':' -f 2-)" +%s`.strip.to_i
    current_date < expiration_date
  end

  def create_certificate_signing_request
    subject = "/C=#{@certificate_configuration[:country_code]}" \
              "/ST=#{@certificate_configuration[:state]}" \
              "/L=#{@certificate_configuration[:locality]}" \
              "/O=#{@certificate_configuration[:organization_name]}" \
              "/OU=#{@certificate_configuration[:organizational_unit_name]}" \
              "/CN=#{@certificate_configuration[:common_name]}" \
              "/emailAddress=#{@certificate_configuration[:email]}"
    command_string = "openssl req -new -key '#{private_key}' -out '#{csr}' -subj '#{subject}'"
    exec_system_command(
      command_string,
      "Signing request '#{csr}' generated.",
      "Failed to signing request '#{csr}'."
    )
  end

  def extract_certificate_signing_request
    # TODO: study how a CA-signed certificate csr extraction works
    command_string = "openssl x509 -x509toreq -in '#{certificate}' -signkey '#{private_key}' -out '#{csr}'"
    exec_system_command(
      command_string,
      "Signing request '#{csr}' extracted from expired certificate.",
      "Failed to extract Signing request '#{csr}'."
    )
  end

  def create_certificate
    # TODO: Line below is too long.
    # TODO: Divide self-signing and CA signing
    command_string = "openssl x509 -req -days '#{@certificate_configuration[:valid_for]}' -in '#{csr}' -signkey '#{private_key}' -out '#{certificate}'"
    exec_system_command(
      command_string,
      "Certificate '#{certificate}' renewed.",
      "Failed to renew certificate '#{certificate}'."
    )
  end

  def delete_certificate_signing_request
    LocalLogger.info 'Cleaning the old Certificate Signing Request'
    FileUtils.rm_f(csr)
    LocalLogger.info 'Old CSR removed'
  end

  # Exec a command with `system`. Prints `ok_message` when the command is executed correctly;
  # `ko_message` when the command fails; and a general message when the command execution fails.
  def exec_system_command(command, ok_message, ko_message)
    case system(command)
    when true
      LocalLogger.info ok_message
    when false
      LocalLogger.error ko_message
      exit 1
    when nil
      LocalLogger.error "Cannot run command '#{command}'."
      exit 1
    end
  end
end
