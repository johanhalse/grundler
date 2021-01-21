require "json"

module Grundler
  class PackageJsonWriter
    def initialize(path)
      @path = path
    end

    def add(packages)
      write(existing_packages.merge(packages))
    end

    def remove(packages)
      write(
        existing_packages.delete_if { |k, _v| packages.include?(k) }
      )
    end

    def existing_packages
      existing_content["dependencies"]
    end

    private

    def write(packages)
      File.write(
        @path,
        JSON.pretty_generate(
          existing_content.merge({ "dependencies" => packages })
        )
      )
    end

    def existing_content
      @existing_content ||= load_existing_content
    end

    def load_existing_content
      JSON.parse(File.read(@path))
    rescue StandardError
      { "dependencies" => {} }
    end
  end
end
