kvlibdir = `$(KVCONFIG) --libdir`
pkglibdir=$kvlibdir/kvalobs

bindir =$(pkglibdir)/bin

bin_SCRIPTS = run_stinfosys2hist_kvalobs_new \
              run_stinfosys2kvalobs_new \
              station2kvalobs.pl \
              obs_pgm2kvalobs_new.pl \
              param2kvalobs.pl \
              message_format_stdump.pl \
              intodb_stinfosys2kvalobs.pl \
              obs_pgm2kvalobs.pl \
              test_wmonr_stinfosys2kvalobs.pl 

run_metadata:	run_metadata.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< > $@

#pkglibexecdir=$(libexecdir)/kvalobs
pkglibexecdir=$(pkglibdir)/lib/perl

pkglibexec_SCRIPTS = \
   stinfosysdb.pm \
   stinfosys.pm \
   wmonr_stinfosys2kvalobs.pm \
   conf.pm
