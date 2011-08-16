SUBDIRS=dbscript \
        hist_dbscript \
        stinfosys2kvalobs \
        klima2kvalobs \
        stinfosys2kvalobs/stinfosys2station_param

bindir =$(pkglibdir)/bin

dist_bin_SCRIPTS = kvget_metadata_cron \
                   kvget_metadata
                   
kvget_metadata_cron:	kvget_metadata_cron.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
    | sed s,__PKGLIBBINDIR__,$(bindir),  > $@
