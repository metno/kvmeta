AC_PREREQ([2.59])
AC_INIT([kvalobs-metadata], [2.7.4-rc7], [kvoss@met.no])
AM_INIT_AUTOMAKE

#AC_CONFIG_MACRO_DIR([m4])


AC_CONFIG_FILES([
	Makefile
	src/Makefile
	src/dbscript/Makefile
	src/stinfosys2kvalobs/Makefile
	src/hist_dbscript/Makefile
	src/klima2kvalobs/Makefile
	src/stinfosys2kvalobs/stinfosys2station_param/Makefile
])


#KV_KVALOBS # doesn't work
AC_ARG_WITH( 
	[kvconfig-path],
	[AS_HELP_STRING([--with-kvconfig-path=KVALOBS_EXEC_PREFIX/bin],[Where is kvconfig. Default search the path on configure time.])],
	[
		KVCONFIG=${withval}/kvconfig
	],
	[
		KVCONFIG=`which kvconfig`
	]
)

AC_ARG_ENABLE( 
	[kvconfig-check],
	[AS_HELP_STRING([--disable-kvconfig-check],[Disable the existence check for kvconfig, assume it will be available at runtime. It is proably wise to use --with-kvconfig-path to specify where kvconfig is to be found. Default is enabled.])],
	[
		disable_kvconfig_check=${withval}
	],
	[
		disable_kvconfig_check=no
	]
)

AC_SUBST(KVCONFIG)
if test "x$disable_kvconfig_check" == "xno"; then 
	if test -z $KVCONFIG; then
		AC_MSG_ERROR([Unable to find kvconfig. Set --with-kvalobs correctly and try again.])
	fi
	if test ! -x $KVCONFIG; then
		AC_MSG_ERROR([Unable to find kvconfig. Set --with-kvalobs correctly and try again.])
	fi
fi

AC_OUTPUT
