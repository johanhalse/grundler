require_relative "test_helper"
require_relative "setup"

class GrundlerTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  include Setup

  def test_that_it_has_a_version_number
    refute_nil ::Grundler::VERSION
  end

  def test_add_with_no_arguments
    ARGV.replace %w[add]

    assert_output("Must specify a package name!\n") { Grundler::CLI.new }
  end

  def test_add_without_lockfile
    ARGV.replace %w[add ky]

    stub_npm("https://registry.npmjs.org/ky", "ky.json")
    stub_npm_file("https://registry.npmjs.org/ky/-/ky-0.26.0.tgz", "ky-0.26.0.tgz")

    assert_output("Installing ky 0.26.0\n") { Grundler::CLI.new }
    assert_equal(File.read("nodules/ky.js"), "Lorem ipsum\n")
    assert_equal JSON.parse(File.read("package.json")), {
      "dependencies" => {
        "ky" => "0.26.0"
      }
    }
  end

  def test_remove_without_lockfile
    ARGV.replace %w[remove]

    assert_output("No #{Grundler::LOCKFILE_PATH} file found!\n") { Grundler::CLI.new }
  end

  def test_remove_with_no_arguments
    ARGV.replace %w[remove]

    create_lockfile_with_packages({ debounce: "1.0.0" })

    assert_output("Must specify a package name!\n") { Grundler::CLI.new }
  end

  def test_remove_package
    ARGV.replace %w[remove debounce]

    create_lockfile_with_packages({ debounce: "1.0.0", ky: "0.26.0" })
    copy_nodule("debounce.js")
    copy_nodule("ky.js")

    assert_output("Removing debounce\n") { Grundler::CLI.new }
    assert !File.exist?("nodules/debounce.js")
    assert File.exist?("nodules/ky.js")
    assert_equal(File.read("package.json"), "{\n  \"dependencies\": {\n    \"ky\": \"0.26.0\"\n  }\n}")
  end

  def test_remove_last_package
    ARGV.replace %w[remove debounce]

    create_lockfile_with_packages({ debounce: "1.0.0" })
    copy_nodule("debounce.js")

    assert_output("Removing debounce\n") { Grundler::CLI.new }
    assert !File.exist?("nodules/debounce.js")
    assert_equal(File.read("package.json"), "{\n  \"dependencies\": {\n  }\n}")
    assert !File.exist?("nodules")
  end

  def test_add_with_no_entrypoint
    ARGV.replace %w[add extend]

    stub_npm("https://registry.npmjs.org/extend", "extend.json")
    stub_npm_file("https://registry.npmjs.org/extend/-/extend-3.0.2.tgz", "extend-3.0.2.tgz")

    expected_output = <<~OUTPUT
      Installing extend 3.0.2
      \e[36mPackage extend has no module defined and will be written in compatibility mode.
      If that doesn't work, you should consider opening a pull request to add ES module support.
      The package repository is here: git+https://github.com/justmoon/node-extend.git\e[0m
      \e[31mNo entry point found for file extend\e[0m
    OUTPUT

    assert_output(expected_output) { Grundler::CLI.new }
  end

  def test_add_nonexistent_package
    ARGV.replace %w[add nonexistent]
    stub_npm("https://registry.npmjs.org/nonexistent", "nonexistent.json")

    assert_output("That package could not be found in the npm repository!\n") { Grundler::CLI.new }
  end

  def test_add_both_existing_and_nonexistent_package
    ARGV.replace %w[add nonexistent ky]
    stub_npm("https://registry.npmjs.org/nonexistent", "nonexistent.json")
    stub_npm("https://registry.npmjs.org/ky", "ky.json")
    stub_npm_file("https://registry.npmjs.org/ky/-/ky-0.26.0.tgz", "ky-0.26.0.tgz")

    assert_output("That package could not be found in the npm repository!\nInstalling ky 0.26.0\n") do
      Grundler::CLI.new
    end
  end

  def test_install_without_lockfile
    ARGV.replace %w[install]

    assert_output("No #{Dir.pwd}/package.json file found!\n") { Grundler::CLI.new }
  end

  def test_install
    ARGV.replace %w[install]

    create_lockfile_with_packages({ debounce: "1.0.0", ky: "0.26.0" })
    stub_npm("https://registry.npmjs.org/ky", "ky.json")
    stub_npm_file("https://registry.npmjs.org/ky/-/ky-0.26.0.tgz", "ky-0.26.0.tgz")
    stub_npm("https://registry.npmjs.org/debounce", "debounce.json")
    stub_npm_file("https://registry.npmjs.org/debounce/-/debounce-1.0.0.tgz", "debounce-1.0.0.tgz")

    expected_output = <<~OUTPUT
      Installing debounce 1.0.0
      \e[36mPackage debounce has no module defined and will be written in compatibility mode.
      If that doesn't work, you should consider opening a pull request to add ES module support.
      The package repository is here: git://github.com/component/debounce\e[0m
      Installing ky 0.26.0
    OUTPUT

    assert_output(expected_output) { Grundler::CLI.new }
    assert_equal JSON.parse(File.read("package.json")), {
      "dependencies" => {
        "debounce" => "1.0.0",
        "ky" => "0.26.0"
      }
    }
  end

  def test_install_with_nonexistent_package
    ARGV.replace %w[install]

    create_lockfile_with_packages({ nonexistent: "1.0.0" })
    stub_npm("https://registry.npmjs.org/nonexistent", "nonexistent.json")

    assert_output("That package could not be found in the npm repository!\n") { Grundler::CLI.new }
  end

  def test_update_without_lockfile
    ARGV.replace %w[update]

    assert_output("No #{Dir.pwd}/package.json file found!\n") { Grundler::CLI.new }
  end

  def test_update
    ARGV.replace %w[update]

    create_lockfile_with_packages({ debounce: "0.9.0", ky: "0.25.0" })
    stub_npm("https://registry.npmjs.org/ky", "ky.json")
    stub_npm_file("https://registry.npmjs.org/ky/-/ky-0.26.0.tgz", "ky-0.26.0.tgz")
    stub_npm("https://registry.npmjs.org/debounce", "debounce.json")
    stub_npm_file("https://registry.npmjs.org/debounce/-/debounce-1.2.1.tgz", "debounce-1.0.0.tgz")

    expected_output = <<~OUTPUT
      Installing debounce 1.2.1
      \e[36mPackage debounce has no module defined and will be written in compatibility mode.
      If that doesn't work, you should consider opening a pull request to add ES module support.
      The package repository is here: git://github.com/component/debounce.git\e[0m
      Installing ky 0.26.0
    OUTPUT

    assert_output(expected_output) { Grundler::CLI.new }
    assert_equal JSON.parse(File.read("package.json")), {
      "dependencies" => {
        "debounce" => "1.2.1",
        "ky" => "0.26.0"
      }
    }
  end

  def test_custom_nodule_path
    ARGV.replace %w[install]

    File.write(
      Grundler::LOCKFILE_PATH,
      JSON.pretty_generate(dependencies: { ky: "0.26.0" }, nodulePath: "./another_path")
    )

    stub_npm("https://registry.npmjs.org/ky", "ky.json")
    stub_npm_file("https://registry.npmjs.org/ky/-/ky-0.26.0.tgz", "ky-0.26.0.tgz")

    assert_output("Installing ky 0.26.0\n") { Grundler::CLI.new }
    assert File.exist?("package.json")
    assert File.exist?("another_path/ky.js")
    assert !File.exist?("nodules/ky.js")

    FileUtils.rm_rf("another_path")
  end

  def test_unrecognized_command
    ARGV.replace %w[wat]

    expected_output = Grundler::Commands::Help.help_text
    assert_output(expected_output) { Grundler::CLI.new }
  end

  def test_version_not_found
    ARGV.replace %w[install]

    create_lockfile_with_packages({ debounce: "1.9.0" })
    stub_npm("https://registry.npmjs.org/debounce", "debounce.json")

    assert_output("That package could not be found in the npm repository!\n") { Grundler::CLI.new }
  end

  def teardown
    remove_nodule_folder
    remove_lockfile
  end
end
