class Openfortivpn < Formula
  desc "Client for PPP+SSL Fortinet VPN tunnel services."

  homepage "https://github.com/adrienverge/openfortivpn"
  head "https://github.com/adrienverge/openfortivpn.git"

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
