AC_PREREQ([2.59])
AC_INIT([kvalobs_metadata], [2.0.0], [kvoss@met.no])
AM_INIT_AUTOMAKE

AC_CONFIG_MACRO_DIR([m4])


AC_CONFIG_FILES([
	Makefile
	src/Makefile
	src/dbscript/Makefile
	src/dbscript/run_QC1-1
	src/stinfosys2kvalobs/Makefile
])


#KV_KVALOBS # doesn't work
AC_ARG_WITH( 
	[kvalobs],
	[AS_HELP_STRING([--with-kvalobs=KVALOBS_EXEC_PREFIX],[Kvalobs exec prefix. Defaults to $prefix])],
	[
		KVCONFIG=${withval}/bin/kvconfig
	],
	[
		KVCONFIG=`which kvconfig`
	]
)

AC_ARG_ENABLE( 
	[kvconfig-check],
	[AS_HELP_STRING([--disable-kvconfig-check],[Disable the existence check for kvconfig, assume it will be available at runtime. It is proably wise to use --with-kvalobs to specify where kvconfig is to be found. Default is enabled.])],
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
