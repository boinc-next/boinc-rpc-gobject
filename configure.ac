AC_INIT([boinc-gobject],
        [1.0],
        [https://github.com/skybon/boinc-gobject/issues],
        [boinc-gobject],
        [https://github.com/skybon/boinc-gobject])

# This is used to identify a set of API compatible beatween versions
# - If new versions are compatible with the actual one, just leave this untouched
# - If new version breaks API change it in order to allow paralled installations
#   with old versions. Change name of pc files to use a new API too.
API_VERSION=1.0
AC_SUBST([API_VERSION])

AM_INIT_AUTOMAKE([-Wno-portability])

AC_CONFIG_MACRO_DIR([m4])

GOBJECT_INTROSPECTION_CHECK([1.30.0])

LT_INIT

VALAC_CHECK

PKG_CHECK_MODULES(BOINC_GOBJECT, [
  glib-2.0
  gobject-2.0
  gxml-0.10
])

AC_CONFIG_FILES([
  Makefile
  src/Makefile
  src/boinc-gobject-1.0.pc
])

AC_OUTPUT
