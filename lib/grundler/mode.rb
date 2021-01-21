require "rubygems/package"
require "zlib"

class Mode
  class NoEntryPointError < StandardError; end

  def initialize(cli, version)
    @cli = cli
    @version = version
  end

  private

  def notify
    puts "Installing #{@version["name"]} #{@version["version"]}"
  end

  def untar
    tar = Gem::Package::TarReader.new(Zlib::GzipReader.open(tempfile.path))
    file = tar.find { |f| f.full_name == index_file }
    tar.close

    raise NoEntryPointError if file.nil?

    file.read
  end

  def tempfile
    Down::Http.download(@version.dig("dist", "tarball"))
  end

  def file_path
    file_path = "#{@cli.nodule_path}/#{@version["name"]}.js"
    FileUtils.mkdir_p(File.dirname(file_path))
    file_path
  end

  def index_file
    @index_file ||= Pathname.new(index_file_path).cleanpath.to_s
  end

  def index_file_path
    return "package/#{@version["module"]}" if @version["module"]
    return "package/#{@version["exports"]}" if @version["exports"]
    return "package/#{@version["main"]}" if @version["main"]

    "package/index.js"
  end
end
