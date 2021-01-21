require_relative "mode"

class GoodMode < Mode
  def write
    notify
    File.write(file_path, untar)
  rescue Mode::NoEntryPointError
    puts "\e[31mNo entry point found for file #{@version["name"]}\e[0m"
  end
end
