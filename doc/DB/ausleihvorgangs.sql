Ausleihvorgang
Konkrete Ausleihe eines reservierten Pakets mit Kaution

id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
attributenr - "Nummer zur Verbindung in die AttributeTabelle"
person_id - "Ausleiher, Rn:1 zu PERSONS"
zeitzugriff_id -"Zugriff auf Paket mit Zeitbereich, Rn:1 zu ZEITZUGRIFFS"
einsatzort - "Ort der Einsatzes des ausgeliehenen Pakets"
vertrag_ablage - "Ort der Ablage des Vertragspapiers"
versicherung_id - "Versicherung fuer die Ausleihe, R1:1 zu VERSICHERUNGS"
kaution - "Betrag, der als Kaution erhoben wurde"
kautionskasse - "Kasse, in der die Kaution ruht"
rueckgabe - "Datum, an dem das Paket zurück gegeben wurde"
( schaden_id - "Schäden bei dieser Ausleihe, R1:n zu SCHADENS" )
bewertung - "Bewertung des Ausleihevorgangs"

create table ausleihvorgangs (
	id int auto_increment,
	lock_version int default 0,
	updated_at timestamp(14) not null default CURRENT_TIMESTAMP,
	updater_id int,
	created_at timestamp(14) not null,
	attibutenr int,
	person_id int,
	zeitzugriff_id int,
	einsatzort varchar(255),
	vertrag_ablage varchar(255),
	versicherung_id int,
	kaution int,
	kautionskasse varchar(255),
	rueckgabe datetime,
	schaden_id int,
	bewertung text,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Konkrete Ausleihe eines reservierten Pakets mit Kaution';
