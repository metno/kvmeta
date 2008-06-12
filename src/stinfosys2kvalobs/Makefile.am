pkglibdir = `$(KVCONFIG) --pkglibdir`
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

$KVALOBS/bin/stkv_cron/station2kvalobs.pl -1 > $DUMPDIR/station.utf-8
$KVALOBS/bin/stkv_cron/obs_pgm2kvalobs_new.pl -1 > $DUMPDIR/obs_pgm.out
$KVALOBS/bin/stkv_cron/param2kvalobs.pl       > $DUMPDIR/param.utf-8
$KVALOBS/bin/stkv_cron/message_format_stdump.pl > $DUMPDIR/message_format.utf-8


pkglibexec_SCRIPTS = \
   stinfosysdb.pm \
   stinfosys.pm \
   wmonr_stinfosys2kvalobs.pm \
   conf.pm
