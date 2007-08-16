Schaden
Schaden der bei einer Ausleihe auftritt
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
eintrittsdatum - "Datum, an dem der Schaden eintrat"
ausleihvorgang_id - "Vorgang, bei dem der Schaden auftrat"
gegenstand_id - "Gegenstand, der vom Schaden betroffen ist"
hinweise - "Beschreibung des Schadens"
kaufvorgang_id - "Reparatur des Schadens, R1:1(n?) zu KAUFVORGANGS"
wiederverfuegdatum - "Datum, an dem der Gegenstand (voraussichtlich) wieder verfuegbar ist"

create table schadens (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	updater_id int,
	created_on timestamp(14) not null,
	eintrittsdatum datetime,
	ausleihvorgang_id int,
	gegenstand_id int,
	hinweise text,
	kaufvorgang_id int,
	wiederverfuegdatum datetime,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Schaden der bei einer Ausleihe auftritt';
