CREATE TABLE environment (
	environmentid INTEGER NOT NULL,
	alias TEXT NOT NULL,
	name  TEXT NOT NULL,
	description TEXT DEFAULT NULL,
	edited_by    INTEGER NOT NULL,
	edited_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY ( environmentid )
);
