module Setup
  def create_lockfile_with_packages(packages)
    File.write(Grundler::LOCKFILE_PATH, JSON.pretty_generate(dependencies: packages))
  end

  def remove_lockfile
    FileUtils.rm(Grundler::LOCKFILE_PATH) if File.exist?(Grundler::LOCKFILE_PATH)
  end

  def remove_nodule_folder
    FileUtils.rm_rf(Grundler::DEFAULT_NODULE_PATH) if File.exist?(Grundler::DEFAULT_NODULE_PATH)
  end

  def stub_npm(url, file)
    stub_request(:get, url).to_return(status: 200, body: File.read("test/cassettes/#{file}"))
  end

  def stub_npm_file(url, file)
    stub_request(:get, url).to_return(status: 200, body: File.open("test/cassettes/#{file}"))
  end

  def copy_nodule(file)
    FileUtils.mkdir_p("nodules")
    FileUtils.cp("test/files/#{file}", "nodules/#{file}")
  end
end
