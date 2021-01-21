require_relative "common"

module Grundler
  module Commands
    class Update
      include Common

      def initialize(cli, _arguments, json_writer)
        super(cli)
        unless File.exist?(Grundler::LOCKFILE_PATH)
          puts "No #{Grundler::LOCKFILE_PATH} file found!"
          return
        end

        json_writer.add(
          json_writer.existing_packages
            .map { |k, v| update(k, latest_version(k), v) }
            .compact
            .to_h
        )
      end

      private

      def update(name, latest_version, current_version_number)
        if latest_version["version"] == current_version_number
          puts "#{latest_version["name"]} is already the latest version (#{current_version_number})"
          return
        end

        [name, install(latest_version)["version"]]
      end
    end
  end
end
