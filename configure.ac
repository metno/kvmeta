AC_PREREQ([2.59])
AC_INIT([kvalobs_metadata], [2.0.0], [kvoss@met.no])
AM_INIT_AUTOMAKE

AC_CONFIG_MACRO_DIR([m4])


AC_CONFIG_FILES([
	Makefile
	src/Makefile
	src/dbscript/Makefile
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
AC_SUBST(KVCONFIG)
if test -z $KVCONFIG; then
	AC_MSG_ERROR([Unable to find kvconfig. Set --with-kvalobs correctly and try again.])
fi
if test ! -x $KVCONFIG; then
	AC_MSG_ERROR([Unable to find kvconfig. Set --with-kvalobs correctly and try again.])
fi


AC_OUTPUT
