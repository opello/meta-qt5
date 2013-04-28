DESCRIPTION = "Native version of Qt/[X11|Mac|Embedded]"
DEPENDS = "zlib-native dbus-native"
SECTION = "libs"
HOMEPAGE = "http://qt-project.org"

INC_PR = "r1"

inherit native qmake5_base

QT_MODULE = "qtbase"

SSTATE_SCAN_FILES += "*.pri *.prl"

SRC_URI += " \
    file://0001-Add-linux-oe-g-platform.patch \
    file://0002-qlibraryinfo-allow-to-set-qt.conf-from-the-outside-u.patch \
    file://0003-Add-external-hostbindir-option.patch \
    file://0006-qt_functions-temporary-remove-isEmpty-check.patch \
    file://0008-configureapp-Prefix-default-LIBDIRS-and-INCDIRS-with.patch \
    file://0009-qt_module-Fix-pkgconfig-replacement.patch \
    file://0010-qmake-property-rename-QT_INSTALL_CONFIGURATION-to-QT.patch \
    file://0011-qt_module-Fix-paths-in-.prl-files.patch \
"

SEPB = "${WORKDIR}/build"
B = "${SEPB}"

EXTRA_ENV = 'MAKE="make -e ${PARALLEL_MAKE}"'
EXTRA_OEMAKE = " MAKEFLAGS='${PARALLEL_MAKE}'"

QT_CONF_PATH = "${B}/qt.conf"

do_generate_qt_config_file() {
    :
#    echo >> ${WORKDIR}/qt.conf
}

EXTRA_OECONF = " \
    -dont-process \
    -prefix ${prefix} \
    -sysroot ${STAGING_DIR_NATIVE} \
    -no-gcc-sysroot \
    -system-zlib \
    -no-libjpeg \
    -no-libpng \
    -no-gif \
    -no-accessibility \
    -no-cups \
    -no-nis \
    -no-gui \
    -no-qml-debug \
    -no-sql-mysql \
    -no-sql-sqlite \
    -no-opengl \
    -no-openssl \
    -no-xcb \
    -verbose \
    -release \
    -prefix ${prefix} \
    -bindir ${bindir}/${QT_DIR_NAME} \
    -libdir ${libdir} \
    -headerdir ${includedir}/${QT_DIR_NAME} \
    -archdatadir ${libdir}/${QT_DIR_NAME} \
    -datadir ${datadir}/${QT_DIR_NAME} \
    -docdir ${docdir}/${QT_DIR_NAME} \
    -no-glib \
    -no-iconv \
    -silent \
    -nomake examples \
    -nomake tests \
    -nomake demos \
    -no-rpath \
    -platform linux-oe-g++ \
"

do_configure_prepend() {
    # Similar logic is in autotools.bbclass
    if [ -d ${B} -a "${S}" != "${B}" ] ; then
        # Existing separate build directory, exists, remove
        rm -rf "${B}/*"
    fi  

    # Avoid setting QMAKE_LINK from LD (since we want the linker to be g++)
    unset LD

    (echo o; echo yes) | ${S}/configure ${EXTRA_OECONF} || die "Configuring qt failed. EXTRA_OECONF was ${EXTRA_OECONF}"
    bin/qmake ${OE_QMAKE_DEBUG_OUTPUT} ${S} -o Makefile || die "Configuring qt with qmake failed. EXTRA_OECONF was ${EXTRA_OECONF}"
}

do_install() {
    oe_runmake install INSTALL_ROOT=${D}
}