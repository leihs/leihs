Kaufvorgang
Vorgang, zu dem ein Ding oder eine Dienstleitung von einem Lieferant gekauft wurde (Anschaffung, Reparatur, Versicherung)
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Identifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
art - "Art des K~, Anschaffung, Reparatur, Versicherung, etc."
lieferant - "Firma, die diesen K~ verkauft hat, evtl. Anschrift"
rechnungsnr - "Nr der Rechnung zu diesem K~"
kaufdatum - "Datum, zu dem dieser K~ stattfand"
kaufpreis - "Preis des Gegenstands in Rappen(!)"
abschreibedatum - "Datum, zu dem die Investition dieses K~ abgeschrieben ist"

create table kaufvorgangs (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_on timestamp(14) not null,
	art varchar(255),
	lieferant varchar(255),
	rechnungsnr varchar(100),
	kaufdatum date,
	kaufpreis int,
	abschreibedatum date,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Vorgang, zu dem ein Ding oder eine Dienstleitung von einem Lieferant gekauft wurde (Anschaffung, Reparatur, Versicherung)';
