class Mptp < Formula
  # cite Kapli_2017: "https://doi.org/10.1093/bioinformatics/btx025"
  desc "mPTP - a tool for single-locus species delimitation"
  homepage "https://github.com/Pas-Kapli/mptp"
  url "https://github.com/Pas-Kapli/mptp/archive/v0.2.4.tar.gz"
  sha256 "31467d9a98356679f5ee0f417fc8b6b76a0cd3743bd57a29ebff8b43c201abd6"
  head "https://github.com/Pas-Kapli/mptp.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison"
  depends_on "flex"
  depends_on "gsl" => :recommended

  def install
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/mptp --version")
  end
end
