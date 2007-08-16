Paket
Zusammenstellung von mehreren Gegenständen zu einem ausleihbaren Paket
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
name - "Name des P~"
kategorie - "Kategorie des P~, Geräteart"
hinweise - "Hinweise zu diesem P~"
( gegenstand_id - "Gegenstände, die dieses Paket enthält, Rn:n zu GEGENSTANDs")
ausleihbefugnis - "Befugnis, die ein Ausleiher haben muss, um leihen zu können"

create table pakets (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_on timestamp(14) not null,
	name varchar(255),
	kategorie varchar(255),
	hinweise text,
	ausleihbefugnis int not null default 0,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Zusammenstellung von mehreren Gegenständen zu einem ausleihbaren Paket';

--------------------------------------------------------
Paket - Zeitzugriff
Relation n:n zwischen PAKETs und ZEITZUGRIFFs
create table pakets_zeitzugriffs (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_on timestamp(14) not null,
	paket_id int not null,
	zeitzugriff_id int not null,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Daten einer Person als Nutzer oder Administrator der Ausleihe';
