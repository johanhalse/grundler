require_relative "common"

module Grundler
  module Commands
    class Remove
      include Common

      def initialize(cli, packages, json_writer)
        super(cli)
        unless File.exist?(Grundler::LOCKFILE_PATH)
          puts "No #{Grundler::LOCKFILE_PATH} file found!"
          return
        end

        if packages.empty?
          puts "Must specify a package name!"
          return
        end

        json_writer.remove(delete(packages))
      end

      private

      def delete(packages)
        packages.each do |package|
          puts "Removing #{package}"
          FileUtils.rm "#{@cli.nodule_path}/#{package}.js" if File.exist?("#{@cli.nodule_path}/#{package}.js")
          remove_directory_if_empty(package)
        end

        packages.map { |package| [package, package] }.to_h
      end

      def remove_directory_if_empty(package)
        dirname = File.dirname("#{@cli.nodule_path}/#{package}.js")
        FileUtils.rm_rf dirname if Dir.exist?(dirname) && Dir.empty?(dirname)
      end
    end
  end
end
