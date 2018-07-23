class OpenocdNrf52 < Formula
  desc "On-chip debugging, in-system programming and boundary-scan testing"
  homepage "https://sourceforge.net/projects/openocd/"

  head do
    url "https://github.com/eblot/openocd.git", :branch => "nrf52-wdog"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "texinfo" => :build
    depends_on "pkg-config" => :build

    depends_on "libusb"
    depends_on "libftdi"
    depends_on "hidapi"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-verbose
      --enable-verbose-jtag-io
      --enable-verbose-usb-io
      --enable-verbose-usb-comms
      --enable-ftdi
      --enable-cmsis-dap
      --enable-jlink
      --disable-doxygen-html
      --disable-doxygen-pdf
      --disable-werror
      --disable-dummy
      --disable-stlink
      --disable-ti-icdi
      --disable-ulink
      --disable-usb-blaster-2
      --disable-ft232r
      --disable-vsllink
      --disable-xds110
      --disable-osbdm
      --disable-opendous
      --disable-aice
      --disable-usbprog
      --disable-rlink
      --disable-armjtagew
      --disable-kitprog
      --disable-usb-blaster
      --disable-presto
      --disable-openjtag
      --disable-parport
      --disable-jtag_vpi
      --disable-amtjtagaccel
      --disable-zy1000-master
      --disable-zy1000
      --disable-ep93xx
      --disable-at91rm9200
      --disable-bcm2835gpio
      --disable-imx_gpio
      --disable-gw16012
      --disable-oocd_trace
      --disable-buspirate
      --disable-sysfsgpio
      --disable-minidriver-dummy
      --disable-remote-bitbang
    ]

    ENV["CCACHE"] = "none"

    system "./bootstrap"
    system "./configure", *args
    system "make", "install"
    system "mv #{prefix}/bin/openocd #{prefix}/bin/openocd-nrf52"
  end
end
