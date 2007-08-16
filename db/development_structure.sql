CREATE TABLE `attributs` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `ding_nr` int(11) NOT NULL default '0',
  `schluessel` varchar(255) default NULL,
  `wert` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Daten einer Person als Nutzer oder Administrator der Ausleih';

CREATE TABLE `computerdatens` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `benutzer_login` varchar(50) default NULL,
  `ip_adresse` varchar(20) default NULL,
  `ip_maske` varchar(20) default NULL,
  `software` text,
  `gegenstand_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Versicherung für eine Ausleihe';

CREATE TABLE `gegenstands` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2005-04-01 00:00:00',
  `original_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `hersteller` varchar(255) default NULL,
  `modellbezeichnung` varchar(255) default NULL,
  `art` varchar(255) default NULL,
  `seriennr` varchar(255) default NULL,
  `abmessungen` varchar(255) default NULL,
  `kaufvorgang_id` int(11) default NULL,
  `bild_url` varchar(255) default NULL,
  `inventar_abteilung` varchar(10) default NULL,
  `herausgabe_abteilung` varchar(10) default NULL,
  `lagerort` varchar(255) default NULL,
  `letzte_pruefung` date default NULL,
  `paket_id` int(11) default NULL,
  `ausleihbar` int(1) default '0',
  `ausmusterdatum` date default NULL,
  `ausmustergrund` varchar(255) default NULL,
  `attribut_id` int(11) default NULL,
  `kommentar` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Die GegenstÃ¤nde, die inventarisiert sind. Kaufvorgang ist';

CREATE TABLE `geraeteparks` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2005-10-01 10:00:00',
  `name` varchar(50) NOT NULL default '',
  `logo_url` varchar(255) default NULL,
  `ansprechpartner` text,
  `beschreibung` text,
  `oeffentlich` int(1) NOT NULL default '0',
  `vertrag_bezeichnung` varchar(255) default NULL,
  `vertrag_url` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Geraete und Nutzer einzelner Studienbereiche';

CREATE TABLE `geraeteparks_users` (
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL default '2005-10-01 10:00:00',
  `geraetepark_id` int(11) default '0',
  `user_id` int(11) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `kaufvorgangs` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `art` varchar(255) default NULL,
  `lieferant` varchar(255) default NULL,
  `rechnungsnr` varchar(100) default NULL,
  `kaufdatum` date default NULL,
  `kaufpreis` int(11) default NULL,
  `abschreibedatum` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Vorgang, zu dem ein Ding oder eine Dienstleitung von einem L';

CREATE TABLE `pakets` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `name` varchar(255) default NULL,
  `art` varchar(255) default NULL,
  `status` int(11) NOT NULL default '1',
  `hinweise` text,
  `hinweise_ausleih` text,
  `ausleihbefugnis` int(11) NOT NULL default '0',
  `geraetepark_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Zusammenstellung von mehreren GegenstÃ¤nden zu einem ausle';

CREATE TABLE `pakets_reservations` (
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `paket_id` int(11) default '0',
  `reservation_id` int(11) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) NOT NULL default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `status` int(11) default '0',
  `startdatum` datetime default '2005-10-01 10:00:00',
  `enddatum` datetime default '2005-10-01 10:00:00',
  `prioritaet` int(11) default NULL,
  `geraetepark_id` int(11) NOT NULL default '1',
  `user_id` int(11) default NULL,
  `zweck` text,
  `hinweise` text,
  `zubehoer` text,
  `herausgeber_id` int(11) default NULL,
  `rueckgabedatum` datetime default NULL,
  `zuruecknehmer_id` int(11) default NULL,
  `bewertung` int(11) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Reservation eines Benutzers über ein Paket fuer einen defin';

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `lock_version` int(11) NOT NULL default '0',
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updater_id` int(11) default '1',
  `created_at` timestamp NOT NULL default '2004-01-01 10:10:10',
  `login` varchar(80) default NULL,
  `password` varchar(40) default NULL,
  `vorname` varchar(40) default NULL,
  `nachname` varchar(80) default NULL,
  `abteilung` varchar(20) default NULL,
  `ausweis` varchar(40) default NULL,
  `telefon` varchar(20) default NULL,
  `email` varchar(200) default NULL,
  `postadresse` text,
  `benutzerstufe` int(11) NOT NULL default '1',
  `login_als` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

