bin_SCRIPTS = run_metadata

run_metadata:	run_metadata.in.sh
	sed s,__KVCONFIG__,$(KVCONFIG), $< > $@

pkglibexecdir=$(libexecdir)/kvalobs

pkglibexec_SCRIPTS = \
	run_station \
	run_types \
	run_param \
	run_obs_pgm \
	run_model \
	run_qcx_info \
	run_QC1-1 \
	run_QC1-3 \
	run_QC1-4 \
	checks_auto \
	run_algorithm_all \
	run_station_param_all \
	run_checks_all \
	intodb.pm \
	dbQC.pm \
	trim.pm \
	logdbQC.pm \
	dbQC1-1 \
	dbQC1-3 \
	dbQC1-4 \
	dbQC1-4_cat \
	run_algorithm_all \
	run_station_param_all \
	run_checks_all \
	algorithm_all \
	station_param_all \
	checks_all \
	station_param.pm
	