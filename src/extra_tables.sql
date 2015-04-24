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
