Person
Daten einer Person als Nutzer oder Administrator der Ausleihe
id - "ID und PK dieser Tabelle, benoetigt fuer eindeutige Indentifikation"
lock_version - "optimistic locking, verwaltet von RoR"
updated_on - "Datum letzte Aenderung, verwaltet von RoR"
person_id - "letzter Aenderer, R1:1 zu PERSONS"
created_on - "Datum Erstellung, verwaltet von RoR"
name - "Familienname"
vorname - "Vorname"
user_id - "login Daten, R1:1 zu USERS"
kuerzel - "Buchstabenkürzel als Kurzzeichen"
email - "Emailadresse (gleichzeitig Loginname?)"
abteilung - "Bezeichnung der Abteilung, in der die P~ ist"
funktion - "Funktion der P~ (Student, Dozent, Mitarbeiter)"
adresse - "Adresse (komplett)"
telefon - "Telefon"
ausweisnr - "Ausweisnummer von Studenten- oder Identitätskarte"
ausleihbefugnis - "Befugnis, bestimmte Pakete auszuleihen"

create table persons (
	id int auto_increment,
	lock_version int default 0,
	updated_on timestamp(14) not null default CURRENT_TIMESTAMP,
	person_id int,
	created_on timestamp(14) not null,
	name varchar(100),
	vorname varchar(100),
	user_id int(11),
	kuerzel varchar(10),
	email varchar(255),
	abteilung varchar(255),
	funktion varchar(255),
	adresse varchar(255),
	telefon varchar(50),
	ausweisnr varchar(255),
	ausleihbefugnis int,
	primary key( id )
) engine=MyISAM charset=utf8 comment='Daten einer Person als Nutzer oder Administrator der Ausleihe';
