# Install needed packages
pacman -S --needed p7zip && \
pacman -S --needed wget && \
pacman -S --needed base-devel && \
pacman -S --needed ${MINGW_PACKAGE_PREFIX}-gcc && \
pacman -S --needed ${MINGW_PACKAGE_PREFIX}-make

# Download source
_wxwidgets_version=3.2.1
wget --no-clobber https://github.com/wxWidgets/wxWidgets/releases/download/v${_wxwidgets_version}/wxWidgets-${_wxwidgets_version}.7z

_COMPILER_NAME="gcc"

_COMPILER_MACHINE=`gcc -dumpmachine`
#echo $_COMPILER_MACHINE

case "${_COMPILER_MACHINE}" in
  i686-w64-mingw32)
    _COMPILER_SUFFIX=""
  ;;

  x86_64-w64-mingw32)
    _COMPILER_SUFFIX="_x64"
  ;;
esac
#echo $_COMPILER_SUFFIX

_COMPILER_VERSION=`gcc -dumpversion | tr -d '.'`
#echo $_COMPILER_VERSION # 12.2.0

_COMPILER_FULL_VERSION=$_COMPILER_VERSION$_COMPILER_SUFFIX

echo $_COMPILER_FULL_VERSION # 1220_x64

if [ ! -d wxWidgets-${_wxwidgets_version} ]; then
  mkdir -p wxWidgets-${_wxwidgets_version} && \
  cd wxWidgets-${_wxwidgets_version} && \
  7za x ../wxWidgets-${_wxwidgets_version}.7z && \
  cd ..
fi

cd wxWidgets-${_wxwidgets_version} && \
sed --in-place "s/#define wxUSE_GRAPHICS_DIRECT2D 0/#define wxUSE_GRAPHICS_DIRECT2D 1/" include/wx/msw/setup.h
cd build/msw && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=release CFG="mono" && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=debug CFG="mono" && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=0 SHARED=1 UNICODE=1 BUILD=release && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=0 SHARED=1 UNICODE=1 BUILD=debug && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=0 SHARED=0 UNICODE=1 BUILD=release && \
mingw32-make -f makefile.gcc SHELL=cmd.exe \
  CFLAGS="" CPPFLAGS="" LDFLAGS="" \
  CXXFLAGS=-fno-keep-inline-dllexport \
  COMPILER_VERSION=$_COMPILER_FULL_VERSION \
  MONOLITHIC=0 SHARED=0 UNICODE=1 BUILD=debug

mkdir -p ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_Dev/lib
cp -R ../../lib/gcc${_COMPILER_FULL_VERSION}_dll/ \
  ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_Dev/lib/gcc${_COMPILER_FULL_VERSION}_dll/

mkdir -p ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_static_Dev/lib
cp -R ../../lib/gcc${_COMPILER_FULL_VERSION}_lib/ \
  ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_static_Dev/lib/gcc${_COMPILER_FULL_VERSION}_lib/

mkdir -p ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_mono_Dev/lib
cp -R ../../lib/gcc${_COMPILER_FULL_VERSION}_dllmono/ \
  ../../../wxMSW-${_wxwidgets_version}_gcc${_COMPILER_FULL_VERSION}_mono_Dev/lib/gcc${_COMPILER_FULL_VERSION}_dllmono/
