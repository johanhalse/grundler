require_relative "common"

module Grundler
  module Commands
    class Install
      include Common

      def initialize(cli, _arguments, _json_writer)
        super(cli)
        unless File.exist?(Grundler::LOCKFILE_PATH)
          puts "No #{Grundler::LOCKFILE_PATH} file found!"
          return
        end

        loaded_versions = JSON.parse(File.read(Grundler::LOCKFILE_PATH))["dependencies"]
        loaded_versions.each { |k, v| install(specific_version(k, v)) }
      end

      private

      def specific_version(package_name, version_number)
        package_metadata = JSON.parse(HTTP.get("https://registry.npmjs.org/#{package_name}").to_s)
        package_metadata.dig("versions", version_number.delete_prefix("^")) || "Not found"
      end
    end
  end
end
