require_relative "common"

module Grundler
  module Commands
    class Add
      include Common

      def initialize(cli, packages, json_writer)
        super(cli)
        if packages.empty?
          puts "Must specify a package name!"
          return
        end

        json_writer.add(added_packages(packages))
      end

      private

      def added_packages(packages)
        packages
          .map { |package_name| install(latest_version(package_name)) }
          .compact
          .map { |package| [package["name"], package["version"]] }
          .to_h
      end
    end
  end
end
