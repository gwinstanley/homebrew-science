cask 'mantautil' do

  version '4.2.1'
  sha256 'd4befcc475ee501835c59179d4dc025f260746b40c4190493936fd16ec439256'

  url "https://www.pelagicon.com/software/mantautil/mantautil-#{version}.dmg"
  name 'MantaUtil'
  homepage 'https://www.pelagicon.com/software/mantautil/'

  depends_on macos: '>= 10.11'

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
