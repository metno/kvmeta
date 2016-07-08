CREATE TABLE checks_description (
	qcx         TEXT NOT NULL,
	description TEXT NOT NULL,
	UNIQUE ( qcx )
);

CREATE TABLE checks_semi_auto (
	stationid INTEGER NOT NULL,
	qcx       TEXT NOT NULL,
	medium_qcx TEXT NOT NULL,
	language  INTEGER NOT NULL,
	checkname TEXT DEFAULT NULL,
	checksignature TEXT DEFAULT NULL,
        active   TEXT DEFAULT '* * * * *',   
	fromtime TIMESTAMP NOT NULL,
	UNIQUE ( stationid, qcx, language, fromtime )
);

CREATE TABLE checks_semi_auto_test (
	stationid INTEGER NOT NULL,
	qcx       TEXT NOT NULL,
	medium_qcx TEXT NOT NULL,
	language  INTEGER NOT NULL,
	checkname TEXT DEFAULT NULL,
	checksignature TEXT DEFAULT NULL,
        active   TEXT DEFAULT '* * * * *',   
	fromtime TIMESTAMP NOT NULL,
	UNIQUE ( stationid, qcx, language, fromtime )
);

CREATE TABLE station_param_nonhour_klima (
	stationid INTEGER NOT NULL,
	paramid   INTEGER NOT NULL,
	level	  INTEGER DEFAULT 0,	 
	sensor	  CHAR(1) DEFAULT '0',
	fromday	  INTEGER NOT NULL,
	today	  INTEGER NOT NULL,
        qcx       TEXT NOT NULL,
	metadata  TEXT DEFAULT NULL,
        desc_metadata TEXT DEFAULT NULL,
        fromtime TIMESTAMP NOT NULL,
	UNIQUE ( stationid, paramid, level, sensor, fromday, today, qcx, fromtime )
);
