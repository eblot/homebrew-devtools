class OpenocdNrf52 < Formula
  desc "On-chip debugging, in-system programming and boundary-scan testing"
  homepage "https://sourceforge.net/projects/openocd/"

  head do
    url "https://github.com/eblot/openocd.git", :branch => "nrf52"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "texinfo" => :build
  end

  option "without-hidapi", "Disable building support for devices using HIDAPI (CMSIS-DAP)"
  option "without-libftdi", "Disable building support for libftdi-based drivers (USB-Blaster, ASIX Presto, OpenJTAG)"
  option "without-libusb",  "Disable building support for all other USB adapters"

  depends_on "pkg-config" => :build
  depends_on "libusb"
  depends_on "libftdi"
  depends_on "hidapi"

  def install
    # all the libusb and hidapi-based drivers are auto-enabled when
    # the corresponding libraries are present in the system
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-ftdi
    ]

    ENV["CCACHE"] = "none"

    system "./bootstrap"
    system "./configure", *args
    system "make", "install"
  end
end
