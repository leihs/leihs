CREATE TABLE `topics` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `author_name` varchar(255) default NULL,
  `author_email_address` varchar(255) default NULL,
  `written_on` datetime default NULL,
  `bonus_time` time default NULL,
  `last_read` date default NULL,
  `content` text,
  `approved` tinyint(1) default 1,
  `replies_count` int(11) default 0,
  `parent_id` int(11) default NULL,
  `type` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `developers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) default NULL,
  `salary` int(11) default 70000,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `books` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(100) default NULL,
  `price` int(11) default 70000,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(100) default NULL,
  `last_name` varchar(100) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(100) NOT NULL,
  `lock_version` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `inept_wizards` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `type` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;
