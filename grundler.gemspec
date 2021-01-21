require_relative "lib/grundler/version"

Gem::Specification.new do |spec|
  spec.name          = "grundler"
  spec.version       = Grundler::VERSION
  spec.authors       = ["Johan Halse"]
  spec.email         = ["johan@hal.se"]

  spec.summary       = "The no-faff frontend bundler"
  spec.description   = "Grundler is the simplest (as in most understandable) way to install npm packages."
  spec.homepage      = "https://github.com/johanhalse/grundler"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/johanhalse/grundler"
  spec.metadata["changelog_uri"] = "https://github.com/johanhalse/grundler/CHANGES.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "down", "~> 5.2.0"
  spec.add_dependency "http", "~> 4.3.0"
end
