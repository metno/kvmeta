bindir =$(pkglibdir)/bin
pkglibexecdir=$(pkglibdir)/lib/perl

nodist_bin_SCRIPTS =\
	hist_run_metadata

dist_bin_SCRIPTS = \
	hist_run_station \
	hist_run_types \
	hist_run_obs_pgm \
	hist_run_station_metadata 

hist_run_metadata:	hist_run_metadata.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@



EXTRA_DIST = hist_run_metadata.in.sh

CLEANFILES= $(nodist_bin_SCRIPTS)
