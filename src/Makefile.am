SUBDIRS=dbscript \
        hist_dbscript \
        stinfosys2kvalobs \
        klima2kvalobs \
        stinfosys2kvalobs/stinfosys2station_param

#bindir =$(pkglibdir)/bin

EXTRA_DIST=kvget-metadata-cron.in

dist_bin_SCRIPTS = kvget-metadata-cron \
                   kvget-metadata \
                   kvget-metadata-instance \
                   insert_update_delete_table.pl \
                   insert_update_delete_table_speed.pl \
                   kvget-metadata_insert_update_delete \
                   kvget-utesperring \
                   kvinstall_metadata \
                   Kvutil.pm

kvget-metadata-cron:	kvget-metadata-cron.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
    | sed s,__PKGLIBBINDIR__,$(bindir),  > $@
