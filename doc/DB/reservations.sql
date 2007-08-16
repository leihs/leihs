Reservation
Eine Reservation eines Benutzers über ein Paket fuer einen definierten Zeitraum
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
person_id - "Reservierende Person, Rn:1 zu PERSONS"
zeitzugriff - "Zugriff auf Paket mit Zeitbereich, Rn:1 zu ZEITZUGRIFFS"
prioritaet - "Prioritaet dieser Reservation"

create table reservations (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	updater_id int,
	created_on timestamp(14) not null,
	person_id int,
	zeitzugriff_id int,
	prioritaet int,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Reservation eines Benutzers über ein Paket fuer einen definierten Zeitraum';
