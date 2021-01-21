require "grundler/good_mode"
require "grundler/crap_mode"

module Grundler
  module Commands
    module Common
      def initialize(cli)
        @cli = cli
      end

      def module?(version)
        !version["module"].nil? || version["type"] == "module"
      end

      def latest_version(package_name)
        package_metadata = JSON.parse(HTTP.get("https://registry.npmjs.org/#{package_name}").to_s)
        latest_version_number = package_metadata.dig("dist-tags", "latest")
        package_metadata["error"] || package_metadata.dig("versions", latest_version_number)
      end

      def install(version)
        return no_such_package if version == "Not found"

        if module?(version)
          GoodMode.new(@cli, version).write
        else
          CrapMode.new(@cli, version).write
        end

        version
      end

      def no_such_package
        puts "That package could not be found in the npm repository!"
      end
    end
  end
end
