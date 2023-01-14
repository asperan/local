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
# The Cop ClassLength is disabled because to keep short the lines, I must create new lines.
# rubocop:disable Metrics/ClassLength
class CertificateManager
  # ca_paths, if not nil, must be an hash with 2 symbols: `key` and `crt`.
  # If ca_paths is nil, assume the certificate is self-signed.
  def initialize(directory_path, name, certificate_configuration, ca_paths = nil)
    expanded_directory_path = File.expand_path(directory_path)
    FileUtils.mkdir_p expanded_directory_path
    @base_name = "#{expanded_directory_path}/#{name}"
    @certificate_configuration = certificate_configuration
    @ca_paths = ca_paths
  end

  def check_certificate
    LocalLogger.info "Checking certificate #{certificate}..."
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

  def private_key = "#{@base_name}.key"

  def certificate = "#{@base_name}.crt"

  private

  def csr = "#{@base_name}.csr"

  def ca_sign_options = "-CA #{@ca_paths[:crt]} -CAkey #{@ca_paths[:key]} -CAcreateserial"

  def config_file ="#{@base_name}.cnf"

  def key_exist?
    File.exist?(private_key)
  end

  def generate_key
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
    expiration_date = `date -d "#{certificate_expiration_date}" +%s`.strip.to_i
    current_date < expiration_date
  end

  def certificate_expiration_date
    `openssl x509 -noout -text -in #{certificate} | grep 'Not After' | cut -d ':' -f 2-`.strip
  end

  def create_certificate_signing_request
    subject = "/C=#{@certificate_configuration[:country_code]}" \
              "/ST=#{@certificate_configuration[:state]}" \
              "/L=#{@certificate_configuration[:locality]}" \
              "/O=#{@certificate_configuration[:organization_name]}" \
              "/OU=#{@certificate_configuration[:organizational_unit_name]}" \
              "/CN=#{@certificate_configuration[:common_name]}" \
              "/emailAddress=#{@certificate_configuration[:email]}"
    command_string = 'openssl req -new ' \
                     "-key '#{private_key}' " \
                     "-out '#{csr}' " \
                     "-subj '#{subject}' " \
                     "#{@ca_paths.nil? ? '' : add_subject_alt_name('reqexts', 'config')} "
    exec_system_command(
      command_string,
      "Signing request '#{csr}' generated.",
      "Failed to signing request '#{csr}'."
    )
  end

  def extract_certificate_signing_request
    command_string = "openssl x509 -x509toreq -in '#{certificate}' -signkey '#{private_key}' -out '#{csr}'"
    exec_system_command(
      command_string,
      "Signing request '#{csr}' extracted from expired certificate.",
      "Failed to extract Signing request '#{csr}'."
    )
  end

  def create_certificate
    sign_options = if @ca_paths.nil?
                     "-signkey '#{private_key}'"
                   else
                     ca_sign_options
                   end
    command_string = 'openssl x509 -req ' \
                     "-days '#{@certificate_configuration[:valid_for]}' " \
                     "-in '#{csr}' #{sign_options} " \
                     "-out '#{certificate}' " \
                     "#{@ca_paths.nil? ? '' : add_subject_alt_name('extensions', 'extfile')} " \
                     '2> /dev/null'
    exec_system_command(
      command_string,
      "Certificate '#{certificate}' renewed.",
      "Failed to renew certificate '#{certificate}'."
    )
  end

  def delete_certificate_signing_request
    LocalLogger.info 'Cleaning temp files...'
    FileUtils.rm_f(csr)
    FileUtils.rm_f(config_file)
    LocalLogger.info 'Temp files removed.'
  end

  def add_subject_alt_name(ext_option, config_option)
    san_string = 'subjectAltName="' \
                 "DNS:#{@certificate_configuration[:common_name]}," \
                 "DNS:www.#{@certificate_configuration[:common_name]}" \
                 '"'
    File.open(config_file, File::CREAT | File::TRUNC | File::WRONLY) do |file|
      file.write(`cat /etc/ssl/openssl.cnf`, "\n[SAN]\n#{san_string}")
    end
    "-#{ext_option} SAN -#{config_option} #{config_file}"
  end

  # Exec a command with `system`. Prints `ok_message` when the command is executed correctly;
  # `ko_message` when the command fails; and a general message when the command execution fails.
  def exec_system_command(command, ok_message, ko_message)
    case system(command)
    when true
      LocalLogger.info ok_message
    when false
      LocalLogger.error ko_message
      LocalLogger.error "Command '#{command}' failed."
      exit 1
    when nil
      LocalLogger.error "Cannot run command '#{command}'."
      exit 1
    end
  end
end
# rubocop:enable Metrics/ClassLength
