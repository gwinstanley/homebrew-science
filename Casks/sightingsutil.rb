cask 'sightingsutil' do

  appname = 'SightingsUtil'
  appnameLC = appname.downcase

  arch arm: 'arm64', intel: 'x86_64'
  classifier = on_arch_conditional arm: '', intel: '-intel'
  version '5.0.3'
  sha256 arm:   '64834e776323dd551d607a1657c02ea61c6111cfd7a6cef20b993ab74a47b02a',
         intel: 'ea760c70cd3af8833cbe86d544bfb35ef7a3345beadd80ac3e5209d51c42c337'

  url "https://www.pelagicon.com/software/#{appnameLC}/#{appname}-#{version}#{classifier}.dmg"
  name appname
  desc 'Utility for ecologists to assist in managing organism sightings databases'
  homepage "https://www.pelagicon.com/software/#{appnameLC}/"

  depends_on macos: '>= :big_sur'

  app "#{appname}.app"

  data_dir = File.expand_path("~/Library/Application Support/#{appname}")
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shim_script = "#{staged_path}/#{appnameLC}.sh"
  binary shim_script, target: "#{token}"

  preflight do
    IO.write shim_script, <<~EOS
      #!/bin/sh
      open "#{appdir}/#{appname}.app" &
    EOS
    File.chmod 0755, shim_script
  end

  postflight do
    require 'open-uri'
    require 'json'
    require 'openssl'
    Dir.mkdir(data_dir) unless File.exists?(data_dir)
    checksumFile = "#{data_dir}/.checksums.txt"
    File.delete(checksumFile) if File.exists?(checksumFile)
    # Download additional dependent plugins
    fh = URI.open("https://www.pelagicon.com/software/#{appnameLC}/version.php?type=dmg")
    json = JSON.parse(fh.read)
    plugins = json['plugins']
    plugins.each do |key, val|
      url = val['url']
      checksum = val['sha256']
      jar = url.gsub(/^.+\//, '')
      pluginFile = "#{data_dir}/#{jar}"
      puts "Downloading plugin file: #{jar}"
      IO.copy_stream(URI.open(url), pluginFile)
      # Validate checksum
      sha = OpenSSL::Digest::SHA256.new(File.binread(pluginFile)).to_s
      if sha == checksum
        File.open(checksumFile, 'a') { |f| f.puts "#{checksum}  #{jar}" }
      else
        puts "Failed checksum match for downloaded plugin: #{jar}"
        File.delete(pluginFile)
      end
    end
  end

  uninstall quit: ["com.pelagicon.#{appnameLC}", "pelagicon.#{appnameLC}.app.gui.fx"],
            trash: ["~/Library/Application Support/#{appname}/*.jar", "~/Library/Application Support/#{appname}/.checksums.txt"]

  zap trash: data_dir

end
