Attribut
Tabelle von Attributen, die beliebigen Entitäten zugewiesen werden können
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
ding_nr - "Nummer, die ein Ding als Attribut Identifikator hat, ordnert ein Ding seinen Attributen zu, RN:1 zu allen anderen"
schluessel - "Schlüssel, Text"
wert - "Wert, Text"

create table attributs (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_on timestamp(14) not null,
	ding_nr int not null,
	schluessel varchar(255),
	wert varchar(255),
	primary key( id )
) engine=MyISAM charset=utf8 comment='Daten einer Person als Nutzer oder Administrator der Ausleihe';
