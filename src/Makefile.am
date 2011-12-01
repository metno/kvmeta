SUBDIRS=dbscript \
        hist_dbscript \
        stinfosys2kvalobs \
        klima2kvalobs \
        stinfosys2kvalobs/stinfosys2station_param

#bindir =$(pkglibdir)/bin

EXTRA_DIST=kvget-metadata-cron.in

dist_bin_SCRIPTS = kvget-metadata-cron \
                   kvget-metadata
                   
kvget-metadata-cron:	kvget-metadata-cron.in
	sed s,__KVCONFIG__,$(KVCONFIG), $< \
    | sed s,__PKGLIBBINDIR__,$(bindir),  > $@
