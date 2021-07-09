class Xc3sprog < Formula
  desc "Suite of utilities for programming Xilinx FPGAs, CPLDs, and EEPROMs"
  homepage "https://sourceforge.net/projects/xc3sprog/"

  url "https://svn.code.sf.net/p/xc3sprog/code/trunk", :revision => "795"
  version "r795"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconfig" => :build
  
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  patch :DATA

  def install
    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *(std_cmake_args)
      system "ninja"
      system "ninja", "install"
    end
  end
end

__END__
Index: CMakeLists.txt
===================================================================
--- a/CMakeLists.txt  (revision 795)
+++ b/CMakeLists.txt  (working copy)
@@ -99,9 +99,11 @@
    set (CONDITIONAL_FILES ${CONDITIONAL_FILES} "libusb_dyn.c")
 else("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    pkg_check_modules(LIBUSB_COMPAT REQUIRED libusb)
-   include_directories(${LIBUSB_INCLUDE_DIRS})
+   include_directories(${LIBUSB_INCLUDE_DIRS} ${LIBUSB_COMPAT_INCLUDE_DIRS})
+   link_directories(${LIBUSB_LIBRARY_DIRS})
+   link_directories(${LIBUSB_COMPAT_LIBRARY_DIRS})
+   link_directories(${LIBFTDI_LIBRARY_DIRS})
    set(CONDITIONAL_LIBS ${CONDITIONAL_LIBS} usb usb-1.0)
-
 endif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
 
 if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
