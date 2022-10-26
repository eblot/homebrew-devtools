class Urjtag < Formula
  desc "OUniversal JTAG library, server and tools"
  homepage "http://urjtag.org/" # no HTTPS!
  url "https://sourceforge.net/projects/urjtag/files/urjtag/2021.03/urjtag-2021.03.tar.xz"
  sha256 "b0a2eaa245513af096dc4d770109832335c694c6c12aa5e92fefae8685416f1c"

  depends_on "gettext"
  depends_on "readline"
  depends_on "libftdi"
  depends_on "libusb"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-python
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
