class Xfsprogs < Formula
  desc "XFS user space tools"
  homepage "http://xfs.org/index.php/Getting_the_latest_source_code"
  url "git://oss.sgi.com/xfs/cmds/xfsprogs", :tag => 'v4.3.0'
  sha256 ""

  depends_on "libtool" => :build
  depends_on "automake" => :build
  depends_on "autoconf" => :build

  def install
    system "make", "configure"
    system "./configure", "--disable-blkid",
                          "--disable-gettext",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

end
