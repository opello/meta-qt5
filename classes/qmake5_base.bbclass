# This is useful for target recipes to reference native mkspecs
QMAKE_MKSPEC_PATH_NATIVE = "${STAGING_LIBDIR_NATIVE}/${QT_DIR_NAME}"
QMAKE_MKSPEC_PATH_TARGET = "${STAGING_LIBDIR}/${QT_DIR_NAME}"

QMAKE_MKSPEC_PATH = "${QMAKE_MKSPEC_PATH_TARGET}"
QMAKE_MKSPEC_PATH_class-native = "${QMAKE_MKSPEC_PATH_NATIVE}"

# hardcode linux, because that's what 0001-Add-linux-oe-g-platform.patch adds
OE_QMAKE_PLATFORM_NATIVE = "linux-oe-g++"
OE_QMAKE_PLATFORM = "linux-oe-g++"

# Add -d to show debug output from every qmake call, but it prints *a lot*
OE_QMAKE_DEBUG_OUTPUT = "-d"

# Paths in .prl files contain SYSROOT value
SSTATE_SCAN_FILES += "*.pri *.prl"

EXTRA_OEMAKE = " MAKEFLAGS='${PARALLEL_MAKE}'"

EXTRA_ENV = 'QMAKE="${OE_QMAKE_QMAKE} ${OE_QMAKE_DEBUG_OUTPUT} -after \
             INCPATH+=${STAGING_INCDIR}/freetype2 LIBS+=-L${STAGING_LIBDIR}" \
             LINK="${CXX} -Wl,-rpath-link,${STAGING_LIBDIR}" \
             STRIP="${OE_QMAKE_STRIP}" \
             MAKE="make -e ${PARALLEL_MAKE}"'

export OE_QMAKESPEC = "${QMAKE_MKSPEC_PATH_NATIVE}/mkspecs/${OE_QMAKE_PLATFORM_NATIVE}"
export OE_XQMAKESPEC = "${QMAKE_MKSPEC_PATH}/mkspecs/${OE_QMAKE_PLATFORM}"
export OE_QMAKE_QMAKE = "${STAGING_BINDIR_NATIVE}/${QT_DIR_NAME}/qmake"
export OE_QMAKE_COMPILER = "${CC}"
export OE_QMAKE_CC = "${CC}"
export OE_QMAKE_CFLAGS = "${CFLAGS}"
export OE_QMAKE_CXX = "${CXX}"
export OE_QMAKE_CXXFLAGS = "${CXXFLAGS}"
export OE_QMAKE_LINK = "${CXX}"
export OE_QMAKE_LDFLAGS = "${LDFLAGS}"
export OE_QMAKE_AR = "${AR}"
export OE_QMAKE_STRIP = "echo"
export QT_CONF_PATH = "${WORKDIR}/qt.conf"
export QT_DIR_NAME ?= "qt5"

# do not export STRIP to the environment
STRIP[unexport] = "1"

do_generate_qt_config_file() {
    cat > ${WORKDIR}/qt.conf <<EOF
[Paths]
Prefix = ${prefix}
Binaries = ${bindir}/${QT_DIR_NAME}
Libraries = ${libdir}
Headers = ${includedir}/${QT_DIR_NAME}
Data = ${datadir}/${QT_DIR_NAME}
ArchData = ${libdir}/${QT_DIR_NAME}
LibraryExecutables = ${libdir}/${QT_DIR_NAME}/libexec
Imports = ${libdir}/${QT_DIR_NAME}/imports
Qml2Imports = ${libdir}/${QT_DIR_NAME}/qml
Plugins = ${libdir}/${QT_DIR_NAME}/plugins
Documentation = ${docdir}/${QT_DIR_NAME}
HostData = ${QMAKE_MKSPEC_PATH_TARGET}
HostBinaries = ${bindir}/${QT_DIR_NAME}
HostSpec = ${OE_QMAKESPEC}
TartgetSpec = ${OE_XQMAKESPEC} 
ExternalHostBinaries = ${STAGING_BINDIR_NATIVE}/${QT_DIR_NAME}
Sysroot = ${STAGING_DIR_TARGET}
EOF
}
#
# Allows to override following values (as in version 5.0.1)
# Prefix The default prefix for all paths.
# Documentation The location for documentation upon install.
# Headers The location for all headers.
# Libraries The location of installed libraries.
# LibraryExecutables The location of installed executables required by libraries at runtime.
# Binaries The location of installed Qt binaries (tools and applications).
# Plugins The location of installed Qt plugins.
# Imports The location of installed QML extensions to import (QML 1.x).
# Qml2Imports The location of installed QML extensions to import (QML 2.x).
# ArchData The location of general architecture-dependent Qt data.
# Data The location of general architecture-independent Qt data.
# Translations The location of translation information for Qt strings.
# Examples The location for examples upon install.
# Tests The location of installed Qt testcases.
# Settings The location for Qt settings. Not applicable on Windows.

# For bootstrapped
# Sysroot The location of target sysroot
# HostPrefix The prefix for host tools when cross compiling (building tools for both systems)
# HostBinaries The location where to install host tools
# HostData The location where to install host data
# ExternalHostBinaries The location where we already have host tools (when cross compiling, but reusing existing tools)
# TargetSpec The location where to install target mkspec
# HostSpec The location where to install host mkspec

addtask generate_qt_config_file after do_patch before do_configure
