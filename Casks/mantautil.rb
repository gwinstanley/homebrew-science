cask 'mantautil' do

  version '4.2.1'
  sha256 'f1f4d63e3a1ac31e3253a399a202da84a093e97963a978bdf5d90b86d8479d4a'

  url "https://www.pelagicon.com/software/mantautil/mantautil-#{version}.dmg"
  name 'MantaUtil'
  homepage 'https://www.pelagicon.com/software/mantautil/'

  depends_on macos: '>= :mavericks'

  app 'MantaUtil.app'

  data_dir = File.expand_path("~/Library/Application Support/MantaUtil")

  postflight do
    require 'open-uri'
    require 'json'
    Dir.mkdir("#{data_dir}") unless File.exists?("#{data_dir}")
    # Download additional dependent modules.
    base_url = 'https://www.pelagicon.com/software/mantautil'
    fh = open("#{base_url}/version.php")
    json = JSON.parse(fh.read)
    mods = json['modules']
    mods.each do |mod|
      jar = "#{mod[0]}-#{mod[1]}.jar"
      puts "Downloading module file: #{jar}"
      IO.copy_stream(open("#{base_url}/modules/#{jar}"), "#{data_dir}/#{jar}")
    end
  end

  uninstall quit:  'org.marinemegafauna.mantautil',
            trash: '~/Library/Application Support/MantaUtil/*.{jar,log}'

  zap trash: data_dir

end
