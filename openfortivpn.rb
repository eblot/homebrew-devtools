class Openfortivpn < Formula
  desc "Client for PPP+SSL Fortinet VPN tunnel services."

  homepage "https://github.com/fretn/openfortivpn"
  url "https://github.com/fretn/openfortivpn.git"
  version "1.1.3"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "openssl"

  def install
    openssl = Formulary.factory 'openssl'
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
