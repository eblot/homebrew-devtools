class Judy < Formula
  desc "Judy is a general purpose dynamic array library"
  homepage "https://judy.sourceforge.net"
  url "https://sourceforge.net/projects/judy/files/judy/Judy-1.0.5/Judy-1.0.5.tar.gz/download"
  sha256 "d2704089f85fdb6f2cd7e77be21170ced4b4375c03ef1ad4cf1075bd414a63eb"

  # man page generation rules are broken, don't care as this package is only
  # used as a gtkwave dependency
  patch :DATA

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

end

__END__
diff --git a/Makefile.am b/Makefile.am
index 75e6968..885175a 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -10,7 +10,7 @@ AUTOMAKE_OPTIONS = foreign
 # test (for libJudy).
 #SUBDIRS = src tool doc test make_includes
 #SUBDIRS = src/JudyCommon src/JudyL src/Judy1 src/JudySL src/JudyHS src/obj
-SUBDIRS = src tool doc test
+SUBDIRS = src tool test
 
 # These files will be included in our tarballs, even though automake knows
 # nothing else about them.
diff --git a/Makefile.in b/Makefile.in
index 1c3f29a..9c62eeb 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -193,7 +193,7 @@ AUTOMAKE_OPTIONS = foreign
 # test (for libJudy).
 #SUBDIRS = src tool doc test make_includes
 #SUBDIRS = src/JudyCommon src/JudyL src/Judy1 src/JudySL src/JudyHS src/obj
-SUBDIRS = src tool doc test
+SUBDIRS = src tool test
 
 # These files will be included in our tarballs, even though automake knows
 # nothing else about them.
