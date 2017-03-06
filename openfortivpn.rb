class Openfortivpn < Formula
  desc "Client for PPP+SSL Fortinet VPN tunnel services."

  homepage "https://github.com/adrienverge/openfortivpn"
  url "https://github.com/adrienverge/openfortivpn/archive/v1.3.0.tar.gz"
  head "https://github.com/adrienverge/openfortivpn.git"
  sha256 "a7dee87a9ef56c5d5a5d7288ae047f51f29472b2156e7d59bf9301aad6ac44ce"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "openssl@1.1"

  def install
    openssl = Formulary.factory 'openssl@1.1'
    ENV['CFLAGS'] = "-I#{openssl}/include"
    system "autoreconf 2> /dev/null; true"
    system "automake", "--add-missing"
    system "autoreconf"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
