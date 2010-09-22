bindir =$(pkglibdir)/bin
pkglibexecdir=$(pkglibdir)/lib/perl

nodist_bin_SCRIPTS = \
	run_klima2kvalobs

dist_bin_SCRIPTS =  \
	range_check/RANGE_CHECK2station_param.pl \
   range_check/RANGE_CHECK.sql \
   range_check/RANGE_PARAM_GROUPS.sql

EXTRA_DIST = run_klima2kvalobs.in

CLEANFILES= $(nodist_bin_SCRIPTS)

run_klima2kvalobs:	run_klima2kvalobs.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@
