bindir =$(pkglibdir)/bin
pkglibexecdir=$(pkglibdir)/lib/perl

nodist_bin_SCRIPTS = \
	run_stinfosys2hist_kvalobs_new \
	run_stinfosys2kvalobs_new

dist_bin_SCRIPTS =  \
	station2kvalobs.pl \
   obs_pgm2kvalobs_new.pl \
   param2kvalobs.pl \
   message_format_stdump.pl \
   test_wmonr_stinfosys2kvalobs.pl \
   hp.pl \
   station_info_avg2kvalobs.pl

#  obs_pgm2kvalobs.pl    
#   intodb_stinfosys2kvalobs.pl 

dist_pkglibexec_SCRIPTS = \
   stinfosysdb.pm \
   stinfosys.pm \
   wmonr_stinfosys2kvalobs.pm \
   conf.pm \
   st_time.pm

EXTRA_DIST = run_stinfosys2hist_kvalobs_new.in run_stinfosys2kvalobs_new.in

CLEANFILES= $(nodist_bin_SCRIPTS)

run_stinfosys2kvalobs_new:	run_stinfosys2kvalobs_new.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@

run_stinfosys2hist_kvalobs_new:	run_stinfosys2hist_kvalobs_new.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@
   