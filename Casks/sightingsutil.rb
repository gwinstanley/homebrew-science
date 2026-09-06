cask 'sightingsutil' do

  appname = 'SightingsUtil'
  appnameLC = appname.downcase

  arch arm: 'arm64', intel: 'x86_64'
  classifier = on_arch_conditional arm: '', intel: '-intel'
  version '5.1.0'
  sha256 arm:   'd43a0b4c35417a35eb7c95b5e0424ee1afec7619f1b565be6f5189ac33e93128',
         intel: '2be4335123c1670e2d8aa2d8323756eda9409cacf6f1c0a31b2f478c2002c079'

  url "https://www.pelagicon.com/software/#{appnameLC}/#{appname}-#{version}#{classifier}.dmg"
  name appname
  desc 'Utility for ecologists to assist in managing organism sightings databases'
  homepage "https://www.pelagicon.com/software/#{appnameLC}/"

  depends_on macos: :big_sur

  app "#{appname}.app"

  verC = version.gsub(/^(\d+\.\d+).*/, '\1')
  data_dir = File.expand_path("~/Library/Application Support/#{appname}")
  shim_script = "#{staged_path}/#{appnameLC}.sh"
  binary shim_script, target: "#{token}"

  preflight_steps do
    write_file shim_script, <<~EOS
      #!/bin/sh
      open "{{appdir}}/#{appname}.app" &
    EOS
    set_permissions shim_script, "0755"
  end

  postflight_steps do
    run '/usr/bin/xattr', args: ['-r', '-d', 'com.apple.quarantine', "/Applications/#{appname}.app"], sudo: :if_needed
  end

  uninstall quit: ["com.pelagicon.#{appnameLC}"],
            trash: ["#{data_dir}/#{appname}-plugin-*-#{verC}*.jar"]

  zap trash: data_dir

  caveats "If installed for offline use ensure to run the application at least once while online first."

end
