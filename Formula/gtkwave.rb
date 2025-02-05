class Gtkwave < Formula
  desc "GTKWave is a fully featured GTK+ based wave viewer"
  homepage "https://gtkwave.sourceforge.net"
  url "https://gtkwave.sourceforge.net/gtkwave-gtk3-3.3.121.tar.gz"
  sha256 "54aa45788d6d52afb659c3aef335aafde0ef2c8990a7770f8eaa64e57f227346"

  depends_on "tcl-tk@8"
  depends_on "gtk+3"
  depends_on "gtk-mac-integration"
  depends_on "judy"
  depends_on "pkg-config" => :build

  # work around pkg-config that fails to return the expected "quartz" string
  # to trigger MAC_INTEGRATION w/ GTK3
  # workaround gtkwave and twinwave attempting to use X11 sockets w/ Cocoa
  # backend
  # workdaround gtkwave not importing gtkx.h since GTK3 version is not what is
  # expected.
  # there are likely much better ways to fix those issues, but I do hate
  # autoconf tools.
  patch :DATA

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-tcl=#{Formula["tcl-tk@8"].opt_prefix}/lib",
                          "--with-tk=#{Formula["tcl-tk@8"].opt_prefix}/lib",
                          "--enable-gtk3",
                          "--enable-judy"
    system "make", "install"
  end

end

__END__
diff --git a/configure b/configure
index b547ed7..d537be8 100755
--- a/configure
+++ b/configure
@@ -7362,7 +7362,7 @@ fi
         GTK_VER=`$PKG_CONFIG gtk+-3.0 --modversion`
 
         _gdk_tgt=`$PKG_CONFIG --variable=target gdk-3.0`
-        if test "x$_gdk_tgt" = xquartz; then
+        if true; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for GTK_MAC" >&5
diff --git a/src/main.c b/src/main.c
index 81bf505..6f819d9 100644
--- a/src/main.c
+++ b/src/main.c
@@ -23,6 +23,8 @@
 #else
 #if GTK_CHECK_VERSION(3,0,0)
 #include <gtk/gtkx.h>
+#elif defined(MAC_INTEGRATION)
+#include <gtk/gtkx.h>
 #endif
 #endif
 
@@ -40,7 +42,7 @@
 #include <sys/types.h>
 #endif
 
-#if !defined __MINGW32__
+#if !defined(__MINGW32__) && !defined(MAC_INTEGRATION)
 #define WAVE_USE_XID
 #else
 #undef WAVE_USE_XID
diff --git a/src/twinwave.c b/src/twinwave.c
index 590c7f6..87bd3fa 100644
--- a/src/twinwave.c
+++ b/src/twinwave.c
@@ -33,8 +33,8 @@
 
 #include "debug.h"
 
-static int use_embedded = 1;
-static int twinwayland = 0;
+static int use_embedded = 0;
+static int twinwayland = 1;
 
 #define XXX_GTK_OBJECT(x) x
 
@@ -143,6 +143,8 @@ if(GDK_IS_WAYLAND_DISPLAY(gdk_display_get_default()))
 	use_embedded = 0;
 	}
 #endif
+
+#ifndef MAC_INTEGRATION
 	{
 	xsocket[0] = gtk_socket_new ();
 	xsocket[1] = gtk_socket_new ();
@@ -152,6 +154,7 @@ if(GDK_IS_WAYLAND_DISPLAY(gdk_display_get_default()))
 
 if(!twinwayland)
 g_signal_connect(XXX_GTK_OBJECT(xsocket[0]), "plug-removed", G_CALLBACK(plug_removed), NULL);
+#endif
 
 #if GTK_CHECK_VERSION(3,0,0)
 main_vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
@@ -427,18 +430,7 @@ if(shmid >=0)
 				char **arglist = calloc(n_items, sizeof(char *));
 
 				sprintf(buf, "0+%08X", shmid);
-				if(use_embedded)
-					{
-#ifdef MAC_INTEGRATION
-					sprintf(buf2, "%x", gtk_socket_get_id (GTK_SOCKET(xsocket[0])));
-#else
-					sprintf(buf2, "%lx", (long)gtk_socket_get_id (GTK_SOCKET(xsocket[0])));
-#endif
-					}
-					else
-					{
-					sprintf(buf2, "%x", 0);
-					}
+				sprintf(buf2, "%x", 0);
 
 				arglist[0] = "gtkwave";
 				arglist[1] = "-D";
@@ -465,18 +457,7 @@ if(shmid >=0)
 			char **arglist = calloc(n_items, sizeof(char *));
 
 			sprintf(buf, "1+%08X", shmid);
-			if(use_embedded)
-				{
-#ifdef MAC_INTEGRATION
-				sprintf(buf2, "%x", gtk_socket_get_id (GTK_SOCKET(xsocket[1])));
-#else
-				sprintf(buf2, "%lx", (long)gtk_socket_get_id (GTK_SOCKET(xsocket[1])));
-#endif
-				}
-				else
-				{
-				sprintf(buf2, "%x", 0);
-				}
+			sprintf(buf2, "%x", 0);
 
 			arglist[0] = "gtkwave";
 			arglist[1] = "-D";
