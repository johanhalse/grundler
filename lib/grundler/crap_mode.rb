require_relative "mode"

class CrapMode < Mode
  def write
    notify
    File.write(file_path, process(untar))
  rescue Mode::NoEntryPointError
    puts "\e[31mNo entry point found for file #{@version["name"]}\e[0m"
  end

  private

  def notify
    super

    puts "\e[36mPackage #{@version["name"]} has no module defined and will be written in compatibility mode."
    puts "If that doesn't work, you should consider opening a pull request to add ES module support."
    puts "The package repository is here: #{@version.dig("repository", "url")}\e[0m"
  end

  def process(str)
    %(
      var module = { exports: {} };
      (function(){#{str}}).call(window);
      export default module.exports;
    )
  end
end
