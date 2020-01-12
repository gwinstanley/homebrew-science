class MarkOsx < Formula
  desc "MARK - parameter estimation for mark-recapture models"
  homepage "http://www.phidot.org/software/mark/"
  url "http://www.phidot.org/software/mark/downloads/files/mark.osx.zip"
  sha256 "3bee839243949b448e361ba71e33e8071aa0abf8bc69530dae7f8014d2f5b583"
  version "9.0"

  depends_on "gcc"

  def install
    libexec.install Dir["*"]
    File.chmod 0755, "#{libexec}/mark"
    FileUtils.mv "#{libexec}/mark", "#{libexec}/mark.64.osx"
    puts "Renamed mark => mark.64.osx"
    bin.mkpath
    puts "Creating shim script to call original binary"
    (prefix/"foo").write <<-EOS
#!/bin/sh
gccPrefix=$(/usr/local/bin/brew --prefix gcc)
dyld=$(/usr/bin/find -E -L "${gccPrefix}/lib/gcc" -depth 1 -type d -regex '.+/[0-9]+' -print | awk -F/ '{ print $NF, $0 }' | sort -n -k1 -r | head -n 1 | sed 's/^[0-9][0-9]* //')
cat <<EOF | tee > "#{bin}/mark"
#!/bin/sh
DYLD_LIBRARY_PATH=$dyld exec "#{libexec}/mark.64.osx" "\\$@"
EOF
    EOS
    File.chmod 0755, "#{prefix}/foo"
    system "#{prefix}/foo"
    File.chmod 0755, "#{bin}/mark"
    puts "Cleaning up installation residue"
    FileUtils.rm "#{prefix}/foo"
  end

  def caveats
    <<-EOS
The 'mark' binary depends on the dynamic libraries provided by the 'gcc' formula,
so if 'gcc' is upgraded this formula will need to be reinstalled to ensure it
references the correct libraries.
    EOS
  end

  test do
    assert_match /No input file was specified/, shell_output("#{bin}/mark")
  end
end
