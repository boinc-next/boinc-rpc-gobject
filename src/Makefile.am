boinc_gobjectdir = $(includedir)/boinc-gobject-1.0

# Empty variable to be added elements later
CLEANFILES=
BUILT_SOURCES=
AM_VALAFLAGS=

lib_LTLIBRARIES = libboinc-gobject-1.0.la

# Vala source code
sources = \
    client.vala    \
    models.vala \
    rpc.vala  \
    util.vala \
    $(NULL)

### General Compilation flags
AM_CPPFLAGS = \
	-I$(top_srcdir) \
	$(NULL)

AM_CFLAGS = \
	-g \
	$(BOINC_GOBJECT_CFLAGS) \
	$(VALA_CFLAGS) \
	$(NULL)

  # library flags
AM_VALAFLAGS += \
	$(ERROR_VALAFLAGS) \
	--library=boinc-1.0 \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
  -H boinc-gobject.h \
  --gir Boinc-1.0.gir \
  --pkg gobject-2.0 \
  --pkg gio-2.0 \
	--pkg gxml-0.10 \
	--includedir boinc-gobject \
	--vapi boinc-1.0.vapi \
	-C \
	$(NULL)

libboinc_gobject_1_0_la_SOURCES =           \
                        $(sources:.vala=.c) \
                        $(NULL)

libboinc_gobject_1_0_la_LIBADD =              \
                        $(BOINC_GOBJECT_LIBS) \
                        $(VALA_LIBS)          \
                        $(NULL)

vala-stamp: $(sources)
	@rm -f vala-temp
	@touch vala-temp
	$(VALAC) $(AM_VALAFLAGS) $^
	@mv -f vala-temp $@

$(sources:.vala=.c): vala-stamp
## Recover from the removal of $@
	@if test -f $@; then :; else \
		trap ’rm -rf vala-lock vala-stamp’ 1 2 13 15; \
		if mkdir vala-lock 2>/dev/null; then \
## This code is being executed by the first process.
			rm -f vala-stamp; \
			$(MAKE) $(AM_MAKEFLAGS) vala-stamp; \
			rmdir vala-lock; \
		else \
## This code is being executed by the follower processes.
## Wait until the first process is done.
			while test -d vala-lock; do sleep 1; done; \
## Succeed if and only if the first process succeeded.
			test -f vala-stamp; exit $$?; \
		fi; \
	fi

# .h header file
boinc-gobject.h: libboinc-gobject-1.0.la
boinc_gobjectdir= $(includedir)/boinc-gobject-$(API_VERSION)/boinc-gobject
boinc_gobject_HEADERS = boinc-gobject.h

# .vapi Vala API file
boinc-1.0.vapi: libboinc-gobject-1.0.la
vapidir = $(VAPIDIR)
dist_vapi_DATA = \
	boinc-$(API_VERSION).vapi \
	boinc-$(API_VERSION).deps \
	$(NULL)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = boinc-gobject-$(API_VERSION).pc

include $(INTROSPECTION_MAKEFILE)
if HAVE_INTROSPECTION

Boinc-1.0.typelib:
	g-ir-compiler \
		--shared-library=libboinc-gobject-1.0.so \
		--output=Boinc-1.0.typelib \
		Boinc-1.0.gir

girdir = $(datadir)/gir-1.0
gir_DATA = Boinc-1.0.gir

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = Boinc-1.0.typelib

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif
