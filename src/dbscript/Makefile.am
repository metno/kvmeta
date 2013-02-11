bindir =$(pkglibdir)/bin
pkglibexecdir=$(pkglibdir)/lib/perl

nodist_bin_SCRIPTS =\
	run_checks_all \
	run_station_param_all \
	run_algorithm_all \
	run_metadata \
	run_metadata_mini \
	run_QC1-4 \
	run_QC1-3 \
	run_QC1-1 \
	run_QC1-1_all \
	run_checks_sensor

dist_bin_SCRIPTS = \
	run_station \
	run_types \
	run_param \
	run_operator \
	run_obs_pgm \
	run_station_metadata \
	run_model \
	run_qcx_info \
	checks_auto \
	dbQC1-1 \
	dbQC1-3 \
	dbQC1-4 \
	dbQC1-4_cat \
	algorithm_all \
	station_param_all \
	checks_all \
	station_param2kvalobsdb \
	checks2kvalobsdb \
	checks_sensor \
	print_station_param_auto_path.pl \
        ../kvinstall_metadata 

nodist_pkglibexec_SCRIPTS = \
	dbQC.pm 

dist_pkglibexec_SCRIPTS = \
	intodb.pm \
	trim.pm \
	logdbQC.pm \
	station_param.pm

run_metadata:	run_metadata.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@

run_metadata_mini:	run_metadata_mini.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@

run_QC1-1_all:	run_QC1-1_all.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
   | sed s,__PERL5LIB__,$(pkglibexecdir), \
   | sed s,__PKGLIBBINDIR__,$(bindir),  > $@

run_QC1-1: run_QC1-1.in
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@

run_QC1-3: run_QC1-3.in
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@ 	

run_QC1-4: run_QC1-4.in
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@ 	

dbQC.pm: dbQC.pm.in
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@

run_algorithm_all: run_algorithm_all.in
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@

run_station_param_all: run_station_param_all.in 
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@

run_checks_all: run_checks_all.in 
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@

run_checks_sensor: run_checks_sensor.in 
	sed s,__PKGLIBBINDIR__,$(bindir), $< > $@


EXTRA_DIST = run_metadata.in.sh run_metadata_mini.in.sh run_QC1-1_all.in.sh run_QC1-1.in run_QC1-3.in run_QC1-4.in dbQC.pm.in \
	run_station_param_all.in run_algorithm_all.in run_checks_all.in run_checks_sensor.in

CLEANFILES= $(nodist_bin_SCRIPTS) $(nodist_pkglibexec_SCRIPTS)
