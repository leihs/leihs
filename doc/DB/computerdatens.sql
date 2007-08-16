Computerdaten
Zusätzliche Daten für einen Gegenstand der Art Computer
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
gegenstand_id - "Zugeordneter Gegenstand, R1:1 zu GEGENSTANDs"
benutzer_login - "Benutzername an diesem Computer"
ip_adresse - "IP Adresse des Computers"
ip_maske - "IP Maske des Computers"
software - "Textbeschreibung der installierten Softwarepakete"

create table computerdatens (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	updater_id int,
	created_on timestamp(14) not null,
	gegenstand_id int,
	benutzer_login varchar(50),
	ip_adresse varchar(20),
	ip_maske varchar(20),
	software text,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Versicherung für eine Ausleihe';
