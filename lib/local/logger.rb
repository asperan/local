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

require 'logger'

# Logger module. It allows to log to multiple locations at once.
module LocalLogger
  DEFAULT_LOG_FILE_PATH = './local.log'

  log_file = File.open(ENV['LOG_FILE_PATH'] || DEFAULT_LOG_FILE_PATH, File::CREAT | File::WRONLY | File::APPEND)

  LOGGERS = [
    Logger.new($stderr),
    Logger.new(log_file),
  ].freeze

  def self.log(severity, message)
    LOGGERS.each { |element| element.log(severity, message) }
  end

  def self.fatal(message)
    log(Logger::FATAL, message)
  end

  def self.error(message)
    log(Logger::ERROR, message)
  end

  def self.warning(message)
    log(Logger::WARN, message)
  end

  def self.info(message)
    log(Logger::INFO, message)
  end

  def self.debug(message)
    log(Logger::DEBUG, message)
  end

  at_exit do
    LOGGERS.each(&:close)
  end
end
