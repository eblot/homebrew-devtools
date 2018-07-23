class Jimtcl < Formula
  desc "A small footprint implementation of the Tcl programming language"
  homepage "http://jim.tcl.tk/"
  url "git://repo.or.cz/jimtcl.git", :tag => "0.78"
  version "0.78"
  # sha256 ""
  # depends_on "cmake" => :build

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install" 
  end

end

