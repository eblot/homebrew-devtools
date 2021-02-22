class Openfpgaloader < Formula
  desc "Universal utility for programming FPGA"
  homepage "https://github.com/trabucayre/openFPGALoader"
  license "GNU Affero General Public License v3.0"
  url "https://github.com/trabucayre/openFPGALoader/archive/v0.2.5.tar.gz"
  sha256 "4e8ac66ce9a450b783bb3c11f0f74103381f67677374cb53359fefb97e3cf87f"
  head "https://github.com/trabucayre/openFPGALoader.git"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconfig" => :build
  
  depends_on "libftdi"
  depends_on "libusb"

  def install
    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *std_cmake_args
      system "ninja", "install"
    end
  end
end
