AC_DEFUN([KV_KVALOBS],
[
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
])
