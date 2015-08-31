require 'formula'

class NoFileStrategy <AbstractDownloadStrategy
    # Intended No-op
end

class SdkScript <Formula

  url 'none', :using => NoFileStrategy
  version '1.7.0'
  sha1 ''

  def stage(target=nil, &block)
    bin.mkpath
    path = bin+"sdk"
    path.write <<-EOS.undent
      #!/bin/sh
      
      usage()
      {
          echo ". sdk.sh [-h] [-f] [sdk_version]"
          echo "  Set up Neotion SDK toolchain"
          echo "    -h  Show this help message"
          echo "    -f  Force predefined versions over build default"
      }
      
      # test me with
      #   for v in 1 2 2q 2s 3; do . sdk.sh $v; done
      
      if [ "$1" = "-h" ]; then
          usage
          return 2>/dev/null || exit
      fi
      
      FORCE=0
      if [ "$1" = "-f" ]; then
          FORCE=1
      fi
      
      SDK_VERSION="$1"
      
      if [ -z "${SDK_VERSION}" ]; then
          SDKVER=`svn pg neo:sdk 2>/dev/null | head -1 | tr -d [[:space:]]`
          SDKNAME=`svn pg neo:sdkname 2>/dev/null | head -1 | cut -c1`
          if [ -n "${SDKVER}" -a -n "${SDKNAME}" ]; then
              SDK_VERSION="${SDKVER}${SDKNAME}"
          fi
      fi
      
      if [ -z "${SDK_VERSION}" ]; then
          usage
          return 2>/dev/null || exit
      fi
      
      unset NEOSDK_ARMCC_VER
      unset NEOSDK_ARMCL_VER
      unset NEOSDK_ARMBU_VER
      unset NEOSDK_CMAKE_VER
      unset NEOSDK_USE_NINJA
      
      case "${SDK_VERSION}" in
          1)
              ARCH="arm-eabi"
              NEOSDK_ARMCC_VER="4.6.4"
              NEOSDK_ARMBU_VER="2.21.1"
              CMAKE_VER="28"
              PYTHON_VER="26"
              ;;
          2)
              ARCH="arm-eabi"
              NEOSDK_ARMCC_VER="4.6.4"
              NEOSDK_ARMBU_VER="2.21.1"
              CMAKE_VER="28"
              PYTHON_VER="27"
              ;;
          2q|2Q)
              ARCH="arm-eabi"
              NEOSDK_ARMCC_VER="4.6.4"
              NEOSDK_ARMBU_VER="2.21.1"
              CMAKE_VER="28"
              PYTHON_VER="27"
              if [ ${FORCE} -gt 0 ]; then
                  export NEOSDK_CMAKE_VER="2.8.5"
                  export NEOSDK_USE_NINJA="1"
              fi
              ;;
          2[r-w]|2[R-W])
              ARCH="arm-eabi"
              NEOSDK_ARMCC_VER="4.9.1"
              NEOSDK_ARMBU_VER="2.24"
              CMAKE_VER="30"
              PYTHON_VER="27"
              ;;
          2[x-z]|2[X-Z])
              ARCH="arm-eabi"
              NEOSDK_ARMCC_VER="5.2.0"
              NEOSDK_ARMBU_VER="2.25"
              CMAKE_VER="33"
              PYTHON_VER="27"
              ;;
          3*)
              ARCH="arm-elf32-minix"
              NEOSDK_ARMCL_VER="3.5"
              NEOSDK_ARMBU_VER="2.25"
              CMAKE_VER="31"
              PYTHON_VER="27"
              ;;
          *)
              echo "Unsupported SDK variant: ${SDK_VERSION}" >&2
              return 2>/dev/null || exit
              ;;
      esac
      
      OPTPATH="/usr/local/opt"
      NEWPATH=""
      
      PREFIX=`echo "${ARCH}" | sed 's/elf32-//'g`
      
      # GCC compiler
      if [ -n "${NEOSDK_ARMCC_VER}" ]; then
          ARMCCVER=`echo "${NEOSDK_ARMCC_VER}" | cut -d. -f1-2 | tr -d .`
          ARMCCPATH="${OPTPATH}/${PREFIX}-gcc${ARMCCVER}/bin"
          NEWPATH="${ARMCCPATH}"
          if [ ${FORCE} -gt 0 ]; then
              export NEOSDK_ARMCC_VER
          fi
      fi
      
      # Clang compiler
      if [ -n "${NEOSDK_ARMCL_VER}" ]; then
          ARMCLVER=`echo "${NEOSDK_ARMCL_VER}" | cut -d. -f1-2 | tr -d .`
          ARMCLPATH="${OPTPATH}/${PREFIX}-clang${ARMCLVER}/bin"
          NEWPATH="${ARMCLPATH}"
          if [ ${FORCE} -gt 0 ]; then
              export NEOSDK_ARMCL_VER
          fi
      fi
      
      # Binutils
      ARMBUVER=`echo "${NEOSDK_ARMBU_VER}" | cut -d. -f1-2 | tr -d .`
      ARMBUPATTERN="${OPTPATH}/${PREFIX}-binutils${ARMBUVER}"
      ARMBUPATH=`ls -1d "${ARMBUPATTERN}"*/bin | tail -1`
      if [ ${FORCE} -gt 0 ]; then
          export NEOSDK_ARMBU_VER
      fi
      
      NEWPATH="${NEWPATH}:${ARMBUPATH}"
      
      # Minix host tools - if any
      case "${ARCH}" in
          *-minix)
              NEWPATH="${NEWPATH}:${OPTPATH}/minix-host-tools/bin"        
              ;;
      esac
      
      # Python
      NEWPATH="${NEWPATH}:/usr/local/py${PYTHON_VER}/bin"
      
      # CMake
      NEWPATH="${NEWPATH}:${OPTPATH}/cmake${CMAKE_VER}/bin"
      
      # Gettext
      GETTEXTPATH=`ls -1d /usr/local/Cellar/gettext/*/bin | tail -1`
      NEWPATH="${NEWPATH}:${GETTEXTPATH}"
      
      # Fallback to system paths
      SYSPATH=/usr/bin:/bin:/usr/sbin:/sbin
      NEWPATH="${NEWPATH}:/usr/local/bin:${SYSPATH}"
      
      # Now set the new path
      export PATH="${NEWPATH}"
      
      # Report selected versions
      PYTHONVERSTR="`python -V 2>&1 | head -1 | cut -d' ' -f2`"
      `which cmake >/dev/null`
      if [ $? -ne 0 ]; then
          echo "CMake not found" >&2
          return 1
      fi
      CMAKEVERSTR=`cmake --version 2>&1 | head -1 | sed s'/^[^0-9.]*//'`
      printf "SDK ${SDK_VERSION}: "
      if [ -n "${NEOSDK_ARMCC_VER}" ]; then
          `which ${ARCH}-gcc >/dev/null`
          if [ $? -ne 0 ]; then
              echo "${ARCH}-gcc not found" >&2
              return 1
          fi
          GCCVERSTR="`${ARCH}-gcc --version | head -1 | \\
                     sed 's/^.* \\([0-9\\.]\\{1,\\}\\)$/\\1/'`"
          printf "GCC v${GCCVERSTR}, ";
      fi
      if [ -n "${NEOSDK_ARMCL_VER}" ]; then 
          `which ${ARCH}-clang >/dev/null`
          if [ $? -ne 0 ]; then
              echo "${ARCH}-clang not found" >&2
              return 1
          fi
          CLANGVERSTR="`${ARCH}-clang --version | head -1 | \\
                       sed 's/^.* \\([0-9.]\\{1,\\}\\) .*$/\\1/'`"
          printf "Clang v${CLANGVERSTR}, "
      fi
      printf "Binutils v${NEOSDK_ARMBU_VER}, "
      printf "Python v${PYTHONVERSTR}, "
      printf "CMake v${CMAKEVERSTR}"
      printf "\\n"
    EOS
  end
end

