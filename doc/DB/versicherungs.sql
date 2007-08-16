Versicherung
Versicherung für eine Ausleihe
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
ausleihvorgang_id -"Ausleihe, zu der diese Versicherung gilt"
kaufvorgang_id - "Kauf dieser Versicherung"
policenr - "Nr der Versicherungspolice"

create table versicherungs (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	updater_id int,
	created_on timestamp(14) not null,
	ausleihvorgang_id int not null,
	kaufvorgang_id int not null,
	policenr varchar(255),
	primary key( id )
) engine=MyISAM charset=utf8 comment='Versicherung für eine Ausleihe';
