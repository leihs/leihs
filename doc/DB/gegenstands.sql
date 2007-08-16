Gegenstand
Ein Gegenstand im Inventar, der separat besteht und evtl. im Paket ausgeliehen werden kann
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_at - "Datum letzte Aenderung, verwaltet von RoR"
updater_id - "letzter Aenderer, R1:1 zu PERSONS"
created_at - "Datum Erstellung, verwaltet von RoR"
name - "Name des G~"
hersteller - "Hersteller des G~"
modellbezeichnung - "Modellbezeichnung des G~"
art - "Art oder Metabeschreibung des G~"
seriennr - "Seriennummer des G~"
abmessungen - "Höhe, Breite, Tiefe des Gegenstands als Text"
kaufvorgang_id - "Anschaffung des G~"
bild_url - "URL zu einem Bild des G~"
inventar_abteilung - "Abteilung, die den G~ inventarisiert hat"
lagerort - "Ort, an dem der G~ gelagert ist, wenn er nicht ausgeliehen wurde"
letzte_pruefung - "Datum, zu dem der G~ zum letzten Mal überprüft wurde"
paket_id - "Paket, dem der G~ zugeordnet ist, Rn:1 zu PAKETs"
ausleihbar - "0, wenn nicht ausleihbar, 1 wenn ausleihbar"
ausmusterdatum - "Datum, an dem der G~ ausgemustert wurde (wird)"
ausmustergrund - "freies feld"
attribut_id - "Zuordnung zu den Attributen (-> ding_nr)"
original_id - "Falls von itHelp synchronisiert, die dortige ID"
kommentar - "Freitextfeld fuer Kommentar"

create table gegenstands (
	id int auto_increment,
	lock_version int default 0,
	updated_at timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_at timestamp(14) not null,
	name varchar(255),
	hersteller varchar(255),
	modellbezeichnung varchar(255),
	art varchar(255),
	seriennr varchar(255),
	abmessungen varchar(255),
	kaufvorgang_id int,
	bild_url varchar(255),
	inventar_abteilung varchar(10),
	lagerort varchar(255),
	letzte_pruefung date,
	paket_id int,
	ausleihbar int,
	ausmusterdatum date,
	ausmustergrund varchar(255),
	attribut_id int,
	original_id int,
	kommentar text,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Die Gegenstaende, die inventarisiert sind. Kaufvorgang ist Anschaffung';
