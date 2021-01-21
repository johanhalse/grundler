require "http"
require "down/http"

require_relative "grundler/version"
require_relative "grundler/package_json_writer"
require_relative "grundler/commands/add"
require_relative "grundler/commands/install"
require_relative "grundler/commands/update"
require_relative "grundler/commands/remove"
require_relative "grundler/commands/help"

module Grundler
  DEFAULT_NODULE_PATH = "#{Dir.pwd}/nodules".freeze
  LOCKFILE_PATH = "#{Dir.pwd}/package.json".freeze
  COMMANDS = %w[add install update remove help].freeze

  class CLI
    def initialize
      json_writer = PackageJsonWriter.new(lockfile_path)
      Grundler::Commands.const_get(current_command).new(self, arguments, json_writer)
    end

    def current_command
      COMMANDS.find { |c| ARGV.first == c }&.capitalize || "Help"
    end

    def arguments
      @switches = ARGV.select { |a| a[0] == "-" }

      ARGV.drop(1) - @switches
    end

    def nodule_path
      @nodule_path ||=
        (JSON.parse(File.read(LOCKFILE_PATH))["nodulePath"] if File.exist?(LOCKFILE_PATH)) ||
        DEFAULT_NODULE_PATH
    end

    def lockfile_path
      LOCKFILE_PATH
    end
  end
end
