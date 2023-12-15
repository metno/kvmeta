CREATE TABLE obs_pgm (
	stationid INTEGER NOT NULL,
	paramid	  INTEGER NOT NULL,
	level	  INTEGER NOT NULL,
        nr_sensor INTEGER DEFAULT 1,
	typeid    INTEGER NOT NULL,
	priority_message  BOOLEAN DEFAULT TRUE,
	collector BOOLEAN DEFAULT FALSE,
	kl00 BOOLEAN DEFAULT FALSE,
	kl01 BOOLEAN DEFAULT FALSE,
	kl02 BOOLEAN DEFAULT FALSE,
	kl03 BOOLEAN DEFAULT FALSE,
	kl04 BOOLEAN DEFAULT FALSE,
	kl05 BOOLEAN DEFAULT FALSE,
	kl06 BOOLEAN DEFAULT FALSE,	
	kl07 BOOLEAN DEFAULT FALSE,
	kl08 BOOLEAN DEFAULT FALSE,
	kl09 BOOLEAN DEFAULT FALSE,
	kl10 BOOLEAN DEFAULT FALSE,
	kl11 BOOLEAN DEFAULT FALSE,
	kl12 BOOLEAN DEFAULT FALSE,
	kl13 BOOLEAN DEFAULT FALSE,
	kl14 BOOLEAN DEFAULT FALSE,
	kl15 BOOLEAN DEFAULT FALSE,
	kl16 BOOLEAN DEFAULT FALSE,
	kl17 BOOLEAN DEFAULT FALSE,
	kl18 BOOLEAN DEFAULT FALSE,
	kl19 BOOLEAN DEFAULT FALSE,
	kl20 BOOLEAN DEFAULT FALSE,
	kl21 BOOLEAN DEFAULT FALSE,
	kl22 BOOLEAN DEFAULT FALSE,
	kl23 BOOLEAN DEFAULT FALSE,
	mon  BOOLEAN DEFAULT FALSE,
	tue  BOOLEAN DEFAULT FALSE,
	wed  BOOLEAN DEFAULT FALSE,
	thu  BOOLEAN DEFAULT FALSE,
	fri  BOOLEAN DEFAULT FALSE,
	sat  BOOLEAN DEFAULT FALSE,
	sun  BOOLEAN DEFAULT FALSE,
        fromtime TIMESTAMP NOT NULL,
        totime   TIMESTAMP DEFAULT NULL,
	UNIQUE ( stationid, typeid, paramid, level, fromtime )	
);

CREATE TABLE obs_pgm2  (
    stationid           INTEGER NOT NULL,
    paramid             INTEGER NOT NULL,
    level               INTEGER NOT NULL,
    typeid              INTEGER NOT NULL,
    sensor              INTEGER DEFAULT 0,
    priority_message    BOOLEAN DEFAULT TRUE,
    anytime             BOOLEAN DEFAULT FALSE,
    hour                BOOLEAN[24] DEFAULT '{FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE}',
    fromtime            TIMESTAMP NOT NULL,
    totime              TIMESTAMP DEFAULT NULL,
    UNIQUE ( stationid, paramid, level, typeid, sensor, fromtime )
);

CREATE TABLE station_metadata (
        stationid INTEGER NOT NULL,
        paramid INTEGER DEFAULT NULL,
        typeid INTEGER DEFAULT NULL,
        level INTEGER DEFAULT NULL,
        sensor CHAR(1) DEFAULT NULL,
        metadatatypename TEXT NOT NULL,
        metadata float NOT NULL,
        fromtime TIMESTAMP NOT NULL,
        totime TIMESTAMP DEFAULT NULL,
        UNIQUE ( stationid, paramid, typeid, level, sensor, metadatatypename, fromtime )
);

CREATE TABLE checks (
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

CREATE TABLE station_param (
	stationid INTEGER NOT NULL,
	paramid   INTEGER NOT NULL,
	level	  INTEGER DEFAULT 0,	 
	sensor	  CHAR(1) DEFAULT '0',
	fromday	  INTEGER NOT NULL,
	today	  INTEGER NOT NULL,
	hour      INTEGER DEFAULT -1,
        qcx       TEXT NOT NULL,
	metadata  TEXT DEFAULT NULL,
        desc_metadata TEXT DEFAULT NULL,
        fromtime TIMESTAMP NOT NULL,
	UNIQUE ( stationid, paramid, level, sensor, fromday, today, hour, qcx, fromtime )
);
