class Mptp < Formula
  # cite Kapli_2017: "https://doi.org/10.1093/bioinformatics/btx025"
  desc "mPTP - a tool for single-locus species delimitation"
  homepage "https://github.com/Pas-Kapli/mptp"
  url "https://github.com/Pas-Kapli/mptp/archive/v0.2.5.tar.gz"
  sha256 "403cda3243ff45939ca9c5099e7d71f917f648a2cb49dfcc80843c0c37db9add"
  head "https://github.com/Pas-Kapli/mptp.git"

  # Fix reporting of macOS aarch64
  patch :DATA

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison"
  depends_on "flex"
  depends_on "gsl" => :recommended

  def install
    ENV.O3
    ENV.deparallelize do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/mptp --version")
  end
end

__END__
diff --git a/src/mptp.h b/src/mptp.h
index 77629d9..0480b08 100644
--- a/src/mptp.h
+++ b/src/mptp.h
@@ -65,6 +65,9 @@

 #ifdef __APPLE__
 #define PROG_OS "osx"
+#ifdef __aarch64__
+#define PROG_CPU "aarch64"
+#endif
 #include <sys/resource.h>
 #include <sys/sysctl.h>
 #endif
