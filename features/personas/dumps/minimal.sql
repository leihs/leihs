set autocommit=0; set unique_checks=0; set foreign_key_checks=0;
-- MySQL dump 10.13  Distrib 5.7.15, for osx10.11 (x86_64)
--
-- Host: localhost    Database: leihs2_test
-- ------------------------------------------------------
-- Server version	5.7.15

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `access_rights`
--

DROP TABLE IF EXISTS `access_rights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_rights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `suspended_until` date DEFAULT NULL,
  `suspended_reason` text COLLATE utf8_unicode_ci,
  `deleted_at` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `role` enum('customer','group_manager','lending_manager','inventory_manager','admin') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_access_rights_on_suspended_until` (`suspended_until`),
  KEY `index_access_rights_on_deleted_at` (`deleted_at`),
  KEY `index_access_rights_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_access_rights_on_role` (`role`),
  KEY `index_on_user_id_and_inventory_pool_id_and_deleted_at` (`user_id`,`inventory_pool_id`,`deleted_at`),
  CONSTRAINT `fk_rails_b36d97eb0c` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_c10a7fd1fd` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_rights`
--

LOCK TABLES `access_rights` WRITE;
/*!40000 ALTER TABLE `access_rights` DISABLE KEYS */;
/*!40000 ALTER TABLE `access_rights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accessories`
--

DROP TABLE IF EXISTS `accessories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accessories_on_model_id` (`model_id`),
  CONSTRAINT `fk_rails_54c6f19548` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accessories`
--

LOCK TABLES `accessories` WRITE;
/*!40000 ALTER TABLE `accessories` DISABLE KEYS */;
/*!40000 ALTER TABLE `accessories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accessories_inventory_pools`
--

DROP TABLE IF EXISTS `accessories_inventory_pools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessories_inventory_pools` (
  `accessory_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_accessories_inventory_pools` (`accessory_id`,`inventory_pool_id`),
  KEY `index_accessories_inventory_pools_on_inventory_pool_id` (`inventory_pool_id`),
  CONSTRAINT `fk_rails_9511c9a747` FOREIGN KEY (`accessory_id`) REFERENCES `accessories` (`id`),
  CONSTRAINT `fk_rails_e9daa88f6c` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accessories_inventory_pools`
--

LOCK TABLES `accessories_inventory_pools` WRITE;
/*!40000 ALTER TABLE `accessories_inventory_pools` DISABLE KEYS */;
/*!40000 ALTER TABLE `accessories_inventory_pools` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_addresses_on_street_and_zip_code_and_city_and_country_code` (`street`,`zip_code`,`city`,`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_model_id` (`model_id`),
  KEY `index_attachments_on_item_id` (`item_id`),
  CONSTRAINT `attachments_item_id_fk` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_f6d36cd48e` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audits`
--

DROP TABLE IF EXISTS `audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditable_id` int(11) DEFAULT NULL,
  `auditable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `associated_id` int(11) DEFAULT NULL,
  `associated_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `audited_changes` text COLLATE utf8_unicode_ci,
  `version` int(11) DEFAULT '0',
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remote_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `request_uuid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `associated_index` (`associated_id`,`associated_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_request_uuid` (`request_uuid`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audits`
--

LOCK TABLES `audits` WRITE;
/*!40000 ALTER TABLE `audits` DISABLE KEYS */;
INSERT INTO `audits` VALUES (1,1,'Setting',NULL,NULL,NULL,NULL,NULL,'create','---\nsmtp_address: smtp.zhdk.ch\nsmtp_port: 25\nsmtp_domain: beta.ausleihe.zhdk.ch\nlocal_currency_string: CHF\ncontract_terms: Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder\n  Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig\n  zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter\n  Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene\n  Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der\n  Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner\n  Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die\n  \'Richtlinie zur Ausleihe von Sachen\' der ZHdK und etwaige abteilungsspezifische\n  Ausleih-Richtlinien.\ncontract_lending_party_string: |-\n  Your\n  Address\n  Here\nemail_signature: Das PZ-leihs Team\ndefault_email: sender@example.com\ndeliver_order_notifications: false\nuser_image_url: http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}\nldap_config: \nlogo_url: \"/assets/image-logo-zhdk.png\"\nmail_delivery_method: test\nsmtp_username: \nsmtp_password: \nsmtp_enable_starttls_auto: false\nsmtp_openssl_verify_mode: none\ntime_zone: Bern\ndisable_manage_section: false\ndisable_manage_section_message: \ndisable_borrow_section: false\ndisable_borrow_section_message: \ntext: \ntimeout_minutes: 30\n',1,NULL,NULL,'4b16dfc2-a6e4-4e2e-a00a-a1071270405e','2016-10-13 12:11:57'),(2,1,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: English (UK)\nlocale_name: en-GB\ndefault: true\nactive: true\n',1,NULL,NULL,'de38a325-be1d-47c4-bd8d-8285eaa1e49f','2016-10-13 12:11:57'),(3,2,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: English (US)\nlocale_name: en-US\ndefault: false\nactive: true\n',1,NULL,NULL,'75e0437f-c85d-4e55-9a98-edc5a6ec34aa','2016-10-13 12:11:57'),(4,3,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Deutsch\nlocale_name: de-CH\ndefault: false\nactive: true\n',1,NULL,NULL,'be56765d-5590-4130-89bb-637dd3f158e2','2016-10-13 12:11:57'),(5,4,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Züritüütsch\nlocale_name: gsw-CH\ndefault: false\nactive: true\n',1,NULL,NULL,'4eaa3a36-2e44-46be-948d-43cc4abac1e1','2016-10-13 12:11:57'),(6,1,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Database Authentication\nclass_name: DatabaseAuthentication\nis_default: true\nis_active: true\n',1,NULL,NULL,'36b4b187-322b-463b-8126-a0734dd9ac1d','2016-10-13 12:11:57'),(7,2,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: LDAP Authentication\nclass_name: LdapAuthentication\nis_default: false\nis_active: false\n',1,NULL,NULL,'48dcf306-0fc9-4e9e-96c0-00ee147bb1ca','2016-10-13 12:11:57'),(8,3,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: ZHDK Authentication\nclass_name: Zhdk\nis_default: false\nis_active: false\n',1,NULL,NULL,'79ac7e99-2c7c-4fad-a12e-8f867195fc63','2016-10-13 12:11:57'),(9,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Inventory Code\n  attribute: inventory_code\n  required: true\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  group: \n  forPackage: true\nactive: true\nposition: 1\n',1,NULL,NULL,'752058ea-8c97-496b-b9a6-68fc2d2365d7','2016-10-13 12:11:57'),(10,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Model\n  attribute:\n  - model\n  - id\n  value_label:\n  - model\n  - product\n  value_label_ext:\n  - model\n  - version\n  form_name: model_id\n  required: true\n  type: autocomplete-search\n  target_type: item\n  search_path: models\n  search_attr: search_term\n  value_attr: id\n  display_attr: product\n  display_attr_ext: version\n  group: \nactive: true\nposition: 2\n',2,NULL,NULL,'9b7c4943-683f-4034-a95b-24c05ba25845','2016-10-13 12:11:57'),(11,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Software\n  attribute:\n  - model\n  - id\n  value_label:\n  - model\n  - product\n  value_label_ext:\n  - model\n  - version\n  form_name: model_id\n  required: true\n  type: autocomplete-search\n  target_type: license\n  search_path: software\n  search_attr: search_term\n  value_attr: id\n  display_attr: product\n  display_attr_ext: version\n  group: \nactive: true\nposition: 3\n',3,NULL,NULL,'0b14852d-bfdf-40a1-b368-241e056638bf','2016-10-13 12:11:57'),(12,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Serial Number\n  attribute: serial_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  group: General Information\nactive: true\nposition: 4\n',4,NULL,NULL,'e64e8c28-6b40-4ba6-99fc-5c6b21dae294','2016-10-13 12:11:57'),(13,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: MAC-Address\n  attribute:\n  - properties\n  - mac_address\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: General Information\nactive: true\nposition: 5\n',5,NULL,NULL,'28c8430c-6713-4fc6-ae21-dfe9cb1854a4','2016-10-13 12:11:57'),(14,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: IMEI-Number\n  attribute:\n  - properties\n  - imei_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: General Information\nactive: true\nposition: 6\n',6,NULL,NULL,'59c1b470-2a0b-4f03-8989-ca78f19cb396','2016-10-13 12:11:57'),(15,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Name\n  attribute: name\n  type: text\n  target_type: item\n  group: General Information\n  forPackage: true\nactive: true\nposition: 7\n',7,NULL,NULL,'ff1406d7-0a60-402c-bd11-c15dfa9a1fd6','2016-10-13 12:11:57'),(16,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Note\n  attribute: note\n  type: textarea\n  group: General Information\n  forPackage: true\nactive: true\nposition: 8\n',8,NULL,NULL,'42daa178-1ecd-48a2-af3c-8fee96dff1fe','2016-10-13 12:11:57'),(17,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Retirement\n  attribute: retired\n  type: select\n  permissions:\n    role: lending_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: false\n  - label: \'Yes\'\n    value: true\n  default: false\n  group: Status\nactive: true\nposition: 9\n',9,NULL,NULL,'91054161-515a-44fc-8d9f-348a104bd663','2016-10-13 12:11:57'),(18,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Reason for Retirement\n  attribute: retired_reason\n  type: textarea\n  required: true\n  permissions:\n    role: lending_manager\n    owner: true\n  visibility_dependency_field_id: retired\n  visibility_dependency_value: \'true\'\n  group: Status\nactive: true\nposition: 10\n',10,NULL,NULL,'c9850510-e0dc-4526-97ba-81cee5825552','2016-10-13 12:11:57'),(19,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Working order\n  attribute: is_broken\n  type: radio\n  target_type: item\n  values:\n  - label: OK\n    value: false\n  - label: Broken\n    value: true\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: 11\n',11,NULL,NULL,'8300d34d-5104-4143-9ab2-8ada90ca3e16','2016-10-13 12:11:57'),(20,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Completeness\n  attribute: is_incomplete\n  type: radio\n  target_type: item\n  values:\n  - label: OK\n    value: false\n  - label: Incomplete\n    value: true\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: 12\n',12,NULL,NULL,'58acece2-681d-4cd8-97e6-c324e59be666','2016-10-13 12:11:57'),(21,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Borrowable\n  attribute: is_borrowable\n  type: radio\n  values:\n  - label: OK\n    value: true\n  - label: Unborrowable\n    value: false\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: 13\n',13,NULL,NULL,'580de15c-6251-4854-b512-b275c0d38a39','2016-10-13 12:11:57'),(22,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Status note\n  attribute: status_note\n  type: textarea\n  target_type: item\n  group: Status\n  forPackage: true\nactive: true\nposition: 14\n',14,NULL,NULL,'acacbcc9-5df8-4698-bab0-6e4770df0de9','2016-10-13 12:11:57'),(23,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Building\n  attribute:\n  - location\n  - building_id\n  type: autocomplete\n  target_type: item\n  values: all_buildings\n  group: Location\n  forPackage: true\nactive: true\nposition: 15\n',15,NULL,NULL,'9e02e3f6-ea1e-4aa4-a11a-6433be5a0374','2016-10-13 12:11:58'),(24,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Room\n  attribute:\n  - location\n  - room\n  type: text\n  target_type: item\n  group: Location\n  forPackage: true\nactive: true\nposition: 16\n',16,NULL,NULL,'45c4c2cd-4f00-473d-b753-5cab7410458f','2016-10-13 12:11:58'),(25,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Shelf\n  attribute:\n  - location\n  - shelf\n  type: text\n  target_type: item\n  group: Location\n  forPackage: true\nactive: true\nposition: 17\n',17,NULL,NULL,'acabfcba-8016-46bd-9e94-5650528677b8','2016-10-13 12:11:58'),(26,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Relevant for inventory\n  attribute: is_inventory_relevant\n  type: select\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: false\n  - label: \'Yes\'\n    value: true\n  default: true\n  group: Inventory\n  forPackage: true\nactive: true\nposition: 18\n',18,NULL,NULL,'c41e4ead-df42-41e6-8043-63cad6400d56','2016-10-13 12:11:58'),(27,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Owner\n  attribute:\n  - owner\n  - id\n  type: autocomplete\n  permissions:\n    role: inventory_manager\n    owner: true\n  values: all_inventory_pools\n  group: Inventory\nactive: true\nposition: 19\n',19,NULL,NULL,'0a6c41c8-358a-413b-81fc-3f6e8d30f0d6','2016-10-13 12:11:58'),(28,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Last Checked\n  attribute: last_check\n  permissions:\n    role: lending_manager\n    owner: true\n  default: today\n  type: date\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: 20\n',20,NULL,NULL,'d0a76e96-5955-4404-896d-569d472ae6cb','2016-10-13 12:11:58'),(29,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Responsible department\n  attribute:\n  - inventory_pool\n  - id\n  type: autocomplete\n  values: all_inventory_pools\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Inventory\n  forPackage: true\nactive: true\nposition: 21\n',21,NULL,NULL,'d082bf7b-ab6f-437c-a18d-e17bf074ef79','2016-10-13 12:11:58'),(30,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Responsible person\n  attribute: responsible\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: 22\n',22,NULL,NULL,'4b317a36-5751-4814-b09b-7bea401b3517','2016-10-13 12:11:58'),(31,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: User/Typical usage\n  attribute: user_name\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: 23\n',23,NULL,NULL,'ecab701e-65a5-4673-8fd9-36a767752191','2016-10-13 12:11:58'),(32,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Reference\n  attribute:\n  - properties\n  - reference\n  permissions:\n    role: inventory_manager\n    owner: true\n  required: true\n  values:\n  - label: Running Account\n    value: invoice\n  - label: Investment\n    value: investment\n  default: invoice\n  type: radio\n  group: Invoice Information\nactive: true\nposition: 24\n',24,NULL,NULL,'2468031a-33e4-4781-aa8f-763a0fb0505f','2016-10-13 12:11:58'),(33,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Project Number\n  attribute:\n  - properties\n  - project_number\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  required: true\n  visibility_dependency_field_id: properties_reference\n  visibility_dependency_value: investment\n  group: Invoice Information\nactive: true\nposition: 25\n',25,NULL,NULL,'17fdc071-253e-45bf-97fa-46a829191336','2016-10-13 12:11:58'),(34,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Invoice Number\n  attribute: invoice_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: 26\n',26,NULL,NULL,'ffdc92e4-2f3a-47c7-b949-40fa6913423c','2016-10-13 12:11:58'),(35,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Invoice Date\n  attribute: invoice_date\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  group: Invoice Information\nactive: true\nposition: 27\n',27,NULL,NULL,'24067af5-3488-47b4-a7d2-9cf4bd7a26c1','2016-10-13 12:11:58'),(36,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Initial Price\n  attribute: price\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  currency: true\n  group: Invoice Information\n  forPackage: true\nactive: true\nposition: 28\n',28,NULL,NULL,'82ac71c1-1095-4238-8a92-691a277a3304','2016-10-13 12:11:58'),(37,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Supplier\n  attribute:\n  - supplier\n  - id\n  type: autocomplete\n  extensible: true\n  extended_key:\n  - supplier\n  - name\n  permissions:\n    role: lending_manager\n    owner: true\n  values: all_suppliers\n  group: Invoice Information\nactive: true\nposition: 29\n',29,NULL,NULL,'04a6e190-f260-44d8-b30b-8f67f93e6613','2016-10-13 12:11:58'),(38,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Warranty expiration\n  attribute:\n  - properties\n  - warranty_expiration\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: 30\n',30,NULL,NULL,'5e5abf81-0046-4cc2-94e2-f50e76f3fdee','2016-10-13 12:11:58'),(39,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Contract expiration\n  attribute:\n  - properties\n  - contract_expiration\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: 31\n',31,NULL,NULL,'e8f0a3b9-0c35-4eec-92e1-925e1f94b483','2016-10-13 12:11:58'),(40,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Activation Type\n  attribute:\n  - properties\n  - activation_type\n  type: select\n  target_type: license\n  values:\n  - label: None\n    value: none\n  - label: Dongle\n    value: dongle\n  - label: Serial Number\n    value: serial_number\n  - label: License Server\n    value: license_server\n  - label: Challenge Response/System ID\n    value: challenge_response\n  default: none\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: 32\n',32,NULL,NULL,'5a51c81e-10b0-4325-9a99-a121844908a8','2016-10-13 12:11:58'),(41,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Dongle ID\n  attribute:\n  - properties\n  - dongle_id\n  type: text\n  target_type: license\n  required: true\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_activation_type\n  visibility_dependency_value: dongle\n  group: General Information\nactive: true\nposition: 33\n',33,NULL,NULL,'1d3a62f3-654b-4794-9807-d10948025c07','2016-10-13 12:11:58'),(42,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: License Type\n  attribute:\n  - properties\n  - license_type\n  type: select\n  target_type: license\n  values:\n  - label: Free\n    value: free\n  - label: Single Workplace\n    value: single_workplace\n  - label: Multiple Workplace\n    value: multiple_workplace\n  - label: Site License\n    value: site_license\n  - label: Concurrent\n    value: concurrent\n  default: free\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: 34\n',34,NULL,NULL,'3dff2d0e-4a88-4f2f-b373-10945e01af96','2016-10-13 12:11:58'),(43,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Total quantity\n  attribute:\n  - properties\n  - total_quantity\n  type: text\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_license_type\n  visibility_dependency_value:\n  - multiple_workplace\n  - site_license\n  - concurrent\n  group: General Information\nactive: true\nposition: 35\n',35,NULL,NULL,'d1d7f22e-9e20-4988-a8a2-240fdad8e26f','2016-10-13 12:11:58'),(44,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Quantity allocations\n  attribute:\n  - properties\n  - quantity_allocations\n  type: composite\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_total_quantity\n  data_dependency_field_id: properties_total_quantity\n  group: General Information\nactive: true\nposition: 36\n',36,NULL,NULL,'b743efbb-c1e5-4701-8012-7cfaeb2cc256','2016-10-13 12:11:58'),(45,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Operating System\n  attribute:\n  - properties\n  - operating_system\n  type: checkbox\n  target_type: license\n  values:\n  - label: Windows\n    value: windows\n  - label: Mac OS X\n    value: mac_os_x\n  - label: Linux\n    value: linux\n  - label: iOS\n    value: ios\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: 37\n',37,NULL,NULL,'794ba087-d5c8-418a-b98c-ef7ecf7c79f3','2016-10-13 12:11:58'),(46,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Installation\n  attribute:\n  - properties\n  - installation\n  type: checkbox\n  target_type: license\n  values:\n  - label: Citrix\n    value: citrix\n  - label: Local\n    value: local\n  - label: Web\n    value: web\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: 38\n',38,NULL,NULL,'519ab038-0057-4485-9886-c2142624d6b4','2016-10-13 12:11:58'),(47,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: License expiration\n  attribute:\n  - properties\n  - license_expiration\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: date\n  target_type: license\n  group: General Information\nactive: true\nposition: 39\n',39,NULL,NULL,'e61c5f1e-13da-4ff9-a51d-abc25544b147','2016-10-13 12:11:58'),(48,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Maintenance contract\n  attribute:\n  - properties\n  - maintenance_contract\n  type: select\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: \'false\'\n  - label: \'Yes\'\n    value: \'true\'\n  default: \'false\'\n  group: Maintenance\nactive: true\nposition: 40\n',40,NULL,NULL,'dab87404-078c-4880-8ed4-fc17c17057af','2016-10-13 12:11:58'),(49,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Maintenance expiration\n  attribute:\n  - properties\n  - maintenance_expiration\n  type: date\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_contract\n  visibility_dependency_value: \'true\'\n  group: Maintenance\nactive: true\nposition: 41\n',41,NULL,NULL,'ebcfe1b1-9e26-45d9-af87-4598ede47528','2016-10-13 12:11:58'),(50,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Currency\n  attribute:\n  - properties\n  - maintenance_currency\n  type: select\n  values: all_currencies\n  default: CHF\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_expiration\n  group: Maintenance\nactive: true\nposition: 42\n',42,NULL,NULL,'62107157-a726-4cbf-9f34-b5b6144c5502','2016-10-13 12:11:58'),(51,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Price\n  attribute:\n  - properties\n  - maintenance_price\n  type: text\n  currency: true\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_currency\n  group: Maintenance\nactive: true\nposition: 43\n',43,NULL,NULL,'49c3501c-af5c-423c-802b-9c42c2935e24','2016-10-13 12:11:58'),(52,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Procured by\n  attribute:\n  - properties\n  - procured_by\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  target_type: license\n  group: Invoice Information\nactive: true\nposition: 44\n',44,NULL,NULL,'8f8bc27e-cbc1-4fae-adb3-b9b4f59aff69','2016-10-13 12:11:58'),(53,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Attachments\n  attribute: attachments\n  type: attachment\n  group: General Information\n  permissions:\n    role: inventory_manager\n    owner: true\nactive: true\nposition: 45\n',45,NULL,NULL,'1a8c41f1-9b84-4dee-94fd-9516090c0cb2','2016-10-13 12:11:58'),(54,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Umzug\n  attribute:\n  - properties\n  - umzug\n  type: select\n  target_type: item\n  values:\n  - label: zügeln\n    value: zügeln\n  - label: sofort entsorgen\n    value: sofort entsorgen\n  - label: bei Umzug entsorgen\n    value: bei Umzug entsorgen\n  - label: bei Umzug verkaufen\n    value: bei Umzug verkaufen\n  default: zügeln\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Umzug\nactive: true\nposition: 46\n',46,NULL,NULL,'cc770c9f-03dc-4aad-ab6c-0966fdd114da','2016-10-13 12:11:58'),(55,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Zielraum\n  attribute:\n  - properties\n  - zielraum\n  type: text\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Umzug\nactive: true\nposition: 47\n',47,NULL,NULL,'29e3f202-6805-47d5-bf30-d97ff3bbc4fb','2016-10-13 12:11:58'),(56,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftsdatum\n  attribute:\n  - properties\n  - ankunftsdatum\n  type: date\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: 48\n',48,NULL,NULL,'5e9f2eb0-9941-4faa-a4b9-911bea266605','2016-10-13 12:11:58'),(57,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftszustand\n  attribute:\n  - properties\n  - ankunftszustand\n  type: select\n  target_type: item\n  values:\n  - label: intakt\n    value: intakt\n  - label: transportschaden\n    value: transportschaden\n  default: intakt\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: 49\n',49,NULL,NULL,'2216e91e-f1e4-4669-8ab7-bd524967e055','2016-10-13 12:11:58'),(58,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftsnotiz\n  attribute:\n  - properties\n  - ankunftsnotiz\n  type: textarea\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: 50\n',50,NULL,NULL,'d0679c3b-4710-4533-aa7c-87af504bf944','2016-10-13 12:11:58'),(59,0,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Beschaffungsgruppe\n  attribute:\n  - properties\n  - anschaffungskategorie\n  value_label:\n  - properties\n  - anschaffungskategorie\n  required: true\n  type: select\n  target_type: item\n  values:\n  - label: \'\'\n    value: \n  - label: Werkstatt-Technik\n    value: Werkstatt-Technik\n  - label: Produktionstechnik\n    value: Produktionstechnik\n  - label: AV-Technik\n    value: AV-Technik\n  - label: Musikinstrumente\n    value: Musikinstrumente\n  - label: Facility Management\n    value: Facility Management\n  - label: IC-Technik/Software\n    value: IC-Technik/Software\n  - label: Durch Kunde beschafft\n    value: Durch Kunde beschafft\n  default: \n  visibility_dependency_field_id: is_inventory_relevant\n  visibility_dependency_value: \'true\'\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Inventory\nactive: true\nposition: 51\n',51,NULL,NULL,'0e5dfda9-609e-4f15-be47-aa58e1c5be0c','2016-10-13 12:11:58');
/*!40000 ALTER TABLE `audits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authentication_systems`
--

DROP TABLE IF EXISTS `authentication_systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authentication_systems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `class_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authentication_systems`
--

LOCK TABLES `authentication_systems` WRITE;
/*!40000 ALTER TABLE `authentication_systems` DISABLE KEYS */;
INSERT INTO `authentication_systems` VALUES (1,'Database Authentication','DatabaseAuthentication',1,1),(2,'LDAP Authentication','LdapAuthentication',0,0),(3,'ZHDK Authentication','Zhdk',0,0);
/*!40000 ALTER TABLE `authentication_systems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buildings`
--

DROP TABLE IF EXISTS `buildings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `buildings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buildings`
--

LOCK TABLES `buildings` WRITE;
/*!40000 ALTER TABLE `buildings` DISABLE KEYS */;
/*!40000 ALTER TABLE `buildings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contracts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `database_authentications`
--

DROP TABLE IF EXISTS `database_authentications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `database_authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_85650bffa9` (`user_id`),
  CONSTRAINT `fk_rails_85650bffa9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `database_authentications`
--

LOCK TABLES `database_authentications` WRITE;
/*!40000 ALTER TABLE `database_authentications` DISABLE KEYS */;
/*!40000 ALTER TABLE `database_authentications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delegations_users`
--

DROP TABLE IF EXISTS `delegations_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delegations_users` (
  `delegation_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_delegations_users_on_user_id_and_delegation_id` (`user_id`,`delegation_id`),
  KEY `index_delegations_users_on_delegation_id` (`delegation_id`),
  CONSTRAINT `fk_rails_b5f7f9c898` FOREIGN KEY (`delegation_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_df1fb72b34` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delegations_users`
--

LOCK TABLES `delegations_users` WRITE;
/*!40000 ALTER TABLE `delegations_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `delegations_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fields`
--

DROP TABLE IF EXISTS `fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fields` (
  `id` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `active` tinyint(1) DEFAULT '1',
  `position` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fields_on_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fields`
--

LOCK TABLES `fields` WRITE;
/*!40000 ALTER TABLE `fields` DISABLE KEYS */;
INSERT INTO `fields` VALUES ('attachments','{\"label\":\"Attachments\",\"attribute\":\"attachments\",\"type\":\"attachment\",\"group\":\"General Information\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true}}',1,45),('inventory_code','{\"label\":\"Inventory Code\",\"attribute\":\"inventory_code\",\"required\":true,\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"group\":null,\"forPackage\":true}',1,1),('inventory_pool_id','{\"label\":\"Responsible department\",\"attribute\":[\"inventory_pool\",\"id\"],\"type\":\"autocomplete\",\"values\":\"all_inventory_pools\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Inventory\",\"forPackage\":true}',1,21),('invoice_date','{\"label\":\"Invoice Date\",\"attribute\":\"invoice_date\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"group\":\"Invoice Information\"}',1,27),('invoice_number','{\"label\":\"Invoice Number\",\"attribute\":\"invoice_number\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,26),('is_borrowable','{\"label\":\"Borrowable\",\"attribute\":\"is_borrowable\",\"type\":\"radio\",\"values\":[{\"label\":\"OK\",\"value\":true},{\"label\":\"Unborrowable\",\"value\":false}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,13),('is_broken','{\"label\":\"Working order\",\"attribute\":\"is_broken\",\"type\":\"radio\",\"target_type\":\"item\",\"values\":[{\"label\":\"OK\",\"value\":false},{\"label\":\"Broken\",\"value\":true}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,11),('is_incomplete','{\"label\":\"Completeness\",\"attribute\":\"is_incomplete\",\"type\":\"radio\",\"target_type\":\"item\",\"values\":[{\"label\":\"OK\",\"value\":false},{\"label\":\"Incomplete\",\"value\":true}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,12),('is_inventory_relevant','{\"label\":\"Relevant for inventory\",\"attribute\":\"is_inventory_relevant\",\"type\":\"select\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":false},{\"label\":\"Yes\",\"value\":true}],\"default\":true,\"group\":\"Inventory\",\"forPackage\":true}',1,18),('last_check','{\"label\":\"Last Checked\",\"attribute\":\"last_check\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"default\":\"today\",\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,20),('location_building_id','{\"label\":\"Building\",\"attribute\":[\"location\",\"building_id\"],\"type\":\"autocomplete\",\"target_type\":\"item\",\"values\":\"all_buildings\",\"group\":\"Location\",\"forPackage\":true}',1,15),('location_room','{\"label\":\"Room\",\"attribute\":[\"location\",\"room\"],\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Location\",\"forPackage\":true}',1,16),('location_shelf','{\"label\":\"Shelf\",\"attribute\":[\"location\",\"shelf\"],\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Location\",\"forPackage\":true}',1,17),('model_id','{\"label\":\"Model\",\"attribute\":[\"model\",\"id\"],\"value_label\":[\"model\",\"product\"],\"value_label_ext\":[\"model\",\"version\"],\"form_name\":\"model_id\",\"required\":true,\"type\":\"autocomplete-search\",\"target_type\":\"item\",\"search_path\":\"models\",\"search_attr\":\"search_term\",\"value_attr\":\"id\",\"display_attr\":\"product\",\"display_attr_ext\":\"version\",\"group\":null}',1,2),('name','{\"label\":\"Name\",\"attribute\":\"name\",\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\",\"forPackage\":true}',1,7),('note','{\"label\":\"Note\",\"attribute\":\"note\",\"type\":\"textarea\",\"group\":\"General Information\",\"forPackage\":true}',1,8),('owner_id','{\"label\":\"Owner\",\"attribute\":[\"owner\",\"id\"],\"type\":\"autocomplete\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":\"all_inventory_pools\",\"group\":\"Inventory\"}',1,19),('price','{\"label\":\"Initial Price\",\"attribute\":\"price\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"currency\":true,\"group\":\"Invoice Information\",\"forPackage\":true}',1,28),('properties_activation_type','{\"label\":\"Activation Type\",\"attribute\":[\"properties\",\"activation_type\"],\"type\":\"select\",\"target_type\":\"license\",\"values\":[{\"label\":\"None\",\"value\":\"none\"},{\"label\":\"Dongle\",\"value\":\"dongle\"},{\"label\":\"Serial Number\",\"value\":\"serial_number\"},{\"label\":\"License Server\",\"value\":\"license_server\"},{\"label\":\"Challenge Response/System ID\",\"value\":\"challenge_response\"}],\"default\":\"none\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,32),('properties_ankunftsdatum','{\"label\":\"Ankunftsdatum\",\"attribute\":[\"properties\",\"ankunftsdatum\"],\"type\":\"date\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,48),('properties_ankunftsnotiz','{\"label\":\"Ankunftsnotiz\",\"attribute\":[\"properties\",\"ankunftsnotiz\"],\"type\":\"textarea\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,50),('properties_ankunftszustand','{\"label\":\"Ankunftszustand\",\"attribute\":[\"properties\",\"ankunftszustand\"],\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"intakt\",\"value\":\"intakt\"},{\"label\":\"transportschaden\",\"value\":\"transportschaden\"}],\"default\":\"intakt\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,49),('properties_anschaffungskategorie','{\"label\":\"Beschaffungsgruppe\",\"attribute\":[\"properties\",\"anschaffungskategorie\"],\"value_label\":[\"properties\",\"anschaffungskategorie\"],\"required\":true,\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"\",\"value\":null},{\"label\":\"Werkstatt-Technik\",\"value\":\"Werkstatt-Technik\"},{\"label\":\"Produktionstechnik\",\"value\":\"Produktionstechnik\"},{\"label\":\"AV-Technik\",\"value\":\"AV-Technik\"},{\"label\":\"Musikinstrumente\",\"value\":\"Musikinstrumente\"},{\"label\":\"Facility Management\",\"value\":\"Facility Management\"},{\"label\":\"IC-Technik/Software\",\"value\":\"IC-Technik/Software\"},{\"label\":\"Durch Kunde beschafft\",\"value\":\"Durch Kunde beschafft\"}],\"default\":null,\"visibility_dependency_field_id\":\"is_inventory_relevant\",\"visibility_dependency_value\":\"true\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Inventory\"}',1,51),('properties_contract_expiration','{\"label\":\"Contract expiration\",\"attribute\":[\"properties\",\"contract_expiration\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,31),('properties_dongle_id','{\"label\":\"Dongle ID\",\"attribute\":[\"properties\",\"dongle_id\"],\"type\":\"text\",\"target_type\":\"license\",\"required\":true,\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_activation_type\",\"visibility_dependency_value\":\"dongle\",\"group\":\"General Information\"}',1,33),('properties_imei_number','{\"label\":\"IMEI-Number\",\"attribute\":[\"properties\",\"imei_number\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\"}',1,6),('properties_installation','{\"label\":\"Installation\",\"attribute\":[\"properties\",\"installation\"],\"type\":\"checkbox\",\"target_type\":\"license\",\"values\":[{\"label\":\"Citrix\",\"value\":\"citrix\"},{\"label\":\"Local\",\"value\":\"local\"},{\"label\":\"Web\",\"value\":\"web\"}],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,38),('properties_license_expiration','{\"label\":\"License expiration\",\"attribute\":[\"properties\",\"license_expiration\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"license\",\"group\":\"General Information\"}',1,39),('properties_license_type','{\"label\":\"License Type\",\"attribute\":[\"properties\",\"license_type\"],\"type\":\"select\",\"target_type\":\"license\",\"values\":[{\"label\":\"Free\",\"value\":\"free\"},{\"label\":\"Single Workplace\",\"value\":\"single_workplace\"},{\"label\":\"Multiple Workplace\",\"value\":\"multiple_workplace\"},{\"label\":\"Site License\",\"value\":\"site_license\"},{\"label\":\"Concurrent\",\"value\":\"concurrent\"}],\"default\":\"free\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,34),('properties_mac_address','{\"label\":\"MAC-Address\",\"attribute\":[\"properties\",\"mac_address\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\"}',1,5),('properties_maintenance_contract','{\"label\":\"Maintenance contract\",\"attribute\":[\"properties\",\"maintenance_contract\"],\"type\":\"select\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":\"false\"},{\"label\":\"Yes\",\"value\":\"true\"}],\"default\":\"false\",\"group\":\"Maintenance\"}',1,40),('properties_maintenance_currency','{\"label\":\"Currency\",\"attribute\":[\"properties\",\"maintenance_currency\"],\"type\":\"select\",\"values\":\"all_currencies\",\"default\":\"CHF\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_expiration\",\"group\":\"Maintenance\"}',1,42),('properties_maintenance_expiration','{\"label\":\"Maintenance expiration\",\"attribute\":[\"properties\",\"maintenance_expiration\"],\"type\":\"date\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_contract\",\"visibility_dependency_value\":\"true\",\"group\":\"Maintenance\"}',1,41),('properties_maintenance_price','{\"label\":\"Price\",\"attribute\":[\"properties\",\"maintenance_price\"],\"type\":\"text\",\"currency\":true,\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_currency\",\"group\":\"Maintenance\"}',1,43),('properties_operating_system','{\"label\":\"Operating System\",\"attribute\":[\"properties\",\"operating_system\"],\"type\":\"checkbox\",\"target_type\":\"license\",\"values\":[{\"label\":\"Windows\",\"value\":\"windows\"},{\"label\":\"Mac OS X\",\"value\":\"mac_os_x\"},{\"label\":\"Linux\",\"value\":\"linux\"},{\"label\":\"iOS\",\"value\":\"ios\"}],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,37),('properties_procured_by','{\"label\":\"Procured by\",\"attribute\":[\"properties\",\"procured_by\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"license\",\"group\":\"Invoice Information\"}',1,44),('properties_project_number','{\"label\":\"Project Number\",\"attribute\":[\"properties\",\"project_number\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"required\":true,\"visibility_dependency_field_id\":\"properties_reference\",\"visibility_dependency_value\":\"investment\",\"group\":\"Invoice Information\"}',1,25),('properties_quantity_allocations','{\"label\":\"Quantity allocations\",\"attribute\":[\"properties\",\"quantity_allocations\"],\"type\":\"composite\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_total_quantity\",\"data_dependency_field_id\":\"properties_total_quantity\",\"group\":\"General Information\"}',1,36),('properties_reference','{\"label\":\"Reference\",\"attribute\":[\"properties\",\"reference\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"required\":true,\"values\":[{\"label\":\"Running Account\",\"value\":\"invoice\"},{\"label\":\"Investment\",\"value\":\"investment\"}],\"default\":\"invoice\",\"type\":\"radio\",\"group\":\"Invoice Information\"}',1,24),('properties_total_quantity','{\"label\":\"Total quantity\",\"attribute\":[\"properties\",\"total_quantity\"],\"type\":\"text\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_license_type\",\"visibility_dependency_value\":[\"multiple_workplace\",\"site_license\",\"concurrent\"],\"group\":\"General Information\"}',1,35),('properties_umzug','{\"label\":\"Umzug\",\"attribute\":[\"properties\",\"umzug\"],\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"zügeln\",\"value\":\"zügeln\"},{\"label\":\"sofort entsorgen\",\"value\":\"sofort entsorgen\"},{\"label\":\"bei Umzug entsorgen\",\"value\":\"bei Umzug entsorgen\"},{\"label\":\"bei Umzug verkaufen\",\"value\":\"bei Umzug verkaufen\"}],\"default\":\"zügeln\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Umzug\"}',1,46),('properties_warranty_expiration','{\"label\":\"Warranty expiration\",\"attribute\":[\"properties\",\"warranty_expiration\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,30),('properties_zielraum','{\"label\":\"Zielraum\",\"attribute\":[\"properties\",\"zielraum\"],\"type\":\"text\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Umzug\"}',1,47),('responsible','{\"label\":\"Responsible person\",\"attribute\":\"responsible\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,22),('retired','{\"label\":\"Retirement\",\"attribute\":\"retired\",\"type\":\"select\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":false},{\"label\":\"Yes\",\"value\":true}],\"default\":false,\"group\":\"Status\"}',1,9),('retired_reason','{\"label\":\"Reason for Retirement\",\"attribute\":\"retired_reason\",\"type\":\"textarea\",\"required\":true,\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"retired\",\"visibility_dependency_value\":\"true\",\"group\":\"Status\"}',1,10),('serial_number','{\"label\":\"Serial Number\",\"attribute\":\"serial_number\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"group\":\"General Information\"}',1,4),('software_model_id','{\"label\":\"Software\",\"attribute\":[\"model\",\"id\"],\"value_label\":[\"model\",\"product\"],\"value_label_ext\":[\"model\",\"version\"],\"form_name\":\"model_id\",\"required\":true,\"type\":\"autocomplete-search\",\"target_type\":\"license\",\"search_path\":\"software\",\"search_attr\":\"search_term\",\"value_attr\":\"id\",\"display_attr\":\"product\",\"display_attr_ext\":\"version\",\"group\":null}',1,3),('status_note','{\"label\":\"Status note\",\"attribute\":\"status_note\",\"type\":\"textarea\",\"target_type\":\"item\",\"group\":\"Status\",\"forPackage\":true}',1,14),('supplier_id','{\"label\":\"Supplier\",\"attribute\":[\"supplier\",\"id\"],\"type\":\"autocomplete\",\"extensible\":true,\"extended_key\":[\"supplier\",\"name\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"values\":\"all_suppliers\",\"group\":\"Invoice Information\"}',1,29),('user_name','{\"label\":\"User/Typical usage\",\"attribute\":\"user_name\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,23);
/*!40000 ALTER TABLE `fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `inventory_pool_id` int(11) NOT NULL,
  `is_verification_required` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_groups_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_groups_on_is_verification_required` (`is_verification_required`),
  CONSTRAINT `fk_rails_45f96f9df2` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups_users`
--

DROP TABLE IF EXISTS `groups_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups_users` (
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_groups_users_on_user_id_and_group_id` (`user_id`,`group_id`),
  KEY `index_groups_users_on_group_id` (`group_id`),
  CONSTRAINT `fk_rails_4e63edbd27` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `fk_rails_8546c71994` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups_users`
--

LOCK TABLES `groups_users` WRITE;
/*!40000 ALTER TABLE `groups_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hidden_fields`
--

DROP TABLE IF EXISTS `hidden_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hidden_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hidden_fields`
--

LOCK TABLES `hidden_fields` WRITE;
/*!40000 ALTER TABLE `hidden_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `hidden_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `holidays`
--

DROP TABLE IF EXISTS `holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_holidays_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_holidays_on_start_date_and_end_date` (`start_date`,`end_date`),
  CONSTRAINT `fk_rails_c189a29194` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holidays`
--

LOCK TABLES `holidays` WRITE;
/*!40000 ALTER TABLE `holidays` DISABLE KEYS */;
/*!40000 ALTER TABLE `holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_on_target_id_and_target_type` (`target_id`,`target_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_pools`
--

DROP TABLE IF EXISTS `inventory_pools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_pools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `contact_details` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contract_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contract_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_contract_note` text COLLATE utf8_unicode_ci,
  `shortname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `color` text COLLATE utf8_unicode_ci,
  `print_contracts` tinyint(1) DEFAULT '1',
  `opening_hours` text COLLATE utf8_unicode_ci,
  `address_id` int(11) DEFAULT NULL,
  `automatic_suspension` tinyint(1) NOT NULL DEFAULT '0',
  `automatic_suspension_reason` text COLLATE utf8_unicode_ci,
  `automatic_access` tinyint(1) DEFAULT NULL,
  `required_purpose` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_inventory_pools_on_name` (`name`),
  KEY `fk_rails_6a55965722` (`address_id`),
  CONSTRAINT `fk_rails_6a55965722` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_pools`
--

LOCK TABLES `inventory_pools` WRITE;
/*!40000 ALTER TABLE `inventory_pools` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_pools` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_pools_model_groups`
--

DROP TABLE IF EXISTS `inventory_pools_model_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_pools_model_groups` (
  `inventory_pool_id` int(11) DEFAULT NULL,
  `model_group_id` int(11) DEFAULT NULL,
  KEY `index_inventory_pools_model_groups_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_inventory_pools_model_groups_on_model_group_id` (`model_group_id`),
  CONSTRAINT `fk_rails_6a7781d99f` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `fk_rails_cb04742a0b` FOREIGN KEY (`model_group_id`) REFERENCES `model_groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_pools_model_groups`
--

LOCK TABLES `inventory_pools_model_groups` WRITE;
/*!40000 ALTER TABLE `inventory_pools_model_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_pools_model_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `serial_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `model_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `owner_id` int(11) NOT NULL,
  `inventory_pool_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `invoice_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `last_check` date DEFAULT NULL,
  `retired` date DEFAULT NULL,
  `retired_reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `is_broken` tinyint(1) DEFAULT '0',
  `is_incomplete` tinyint(1) DEFAULT '0',
  `is_borrowable` tinyint(1) DEFAULT '0',
  `status_note` text COLLATE utf8_unicode_ci,
  `needs_permission` tinyint(1) DEFAULT '0',
  `is_inventory_relevant` tinyint(1) DEFAULT '0',
  `responsible` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `insurance_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `name` text COLLATE utf8_unicode_ci,
  `user_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `properties` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_items_on_inventory_code` (`inventory_code`),
  KEY `index_items_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_items_on_retired` (`retired`),
  KEY `index_items_on_is_borrowable` (`is_borrowable`),
  KEY `index_items_on_is_broken` (`is_broken`),
  KEY `index_items_on_is_incomplete` (`is_incomplete`),
  KEY `index_items_on_location_id` (`location_id`),
  KEY `index_items_on_owner_id` (`owner_id`),
  KEY `index_items_on_parent_id_and_retired` (`parent_id`,`retired`),
  KEY `index_items_on_model_id_and_retired_and_inventory_pool_id` (`model_id`,`retired`,`inventory_pool_id`),
  KEY `fk_rails_538506beaf` (`supplier_id`),
  CONSTRAINT `fk_rails_042cf7b23c` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `fk_rails_0ed18b3bf9` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `fk_rails_538506beaf` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `fk_rails_8757b4d49c` FOREIGN KEY (`owner_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `fk_rails_e8ed83a2e6` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_rails_ed5bf219ac` FOREIGN KEY (`parent_id`) REFERENCES `items` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_name` (`name`),
  KEY `index_languages_on_active_and_default` (`active`,`default`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'English (UK)','en-GB',1,1),(2,'English (US)','en-US',0,1),(3,'Deutsch','de-CH',0,1),(4,'Züritüütsch','gsw-CH',0,1);
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shelf` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `building_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_building_id` (`building_id`),
  CONSTRAINT `fk_rails_b81dc66f92` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_templates`
--

DROP TABLE IF EXISTS `mail_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `format` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_templates`
--

LOCK TABLES `mail_templates` WRITE;
/*!40000 ALTER TABLE `mail_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_group_links`
--

DROP TABLE IF EXISTS `model_group_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `model_group_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ancestor_id` int(11) DEFAULT NULL,
  `descendant_id` int(11) DEFAULT NULL,
  `direct` tinyint(1) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_model_group_links_on_ancestor_id` (`ancestor_id`),
  KEY `index_model_group_links_on_direct` (`direct`),
  KEY `index_on_descendant_id_and_ancestor_id_and_direct` (`descendant_id`,`ancestor_id`,`direct`),
  CONSTRAINT `fk_rails_1e0f0d42e8` FOREIGN KEY (`ancestor_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_c32706c682` FOREIGN KEY (`descendant_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_group_links`
--

LOCK TABLES `model_group_links` WRITE;
/*!40000 ALTER TABLE `model_group_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_group_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_groups`
--

DROP TABLE IF EXISTS `model_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `model_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_model_groups_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_groups`
--

LOCK TABLES `model_groups` WRITE;
/*!40000 ALTER TABLE `model_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_links`
--

DROP TABLE IF EXISTS `model_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `model_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_group_id` int(11) NOT NULL,
  `model_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_model_links_on_model_id_and_model_group_id` (`model_id`,`model_group_id`),
  KEY `index_model_links_on_model_group_id_and_model_id` (`model_group_id`,`model_id`),
  CONSTRAINT `fk_rails_11add1a9a3` FOREIGN KEY (`model_group_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_9b7295b085` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_links`
--

LOCK TABLES `model_links` WRITE;
/*!40000 ALTER TABLE `model_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `models`
--

DROP TABLE IF EXISTS `models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `models` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Model',
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `internal_description` text COLLATE utf8_unicode_ci,
  `info_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rental_price` decimal(8,2) DEFAULT NULL,
  `maintenance_period` int(11) DEFAULT '0',
  `is_package` tinyint(1) DEFAULT '0',
  `technical_detail` text COLLATE utf8_unicode_ci,
  `hand_over_note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_models_on_type` (`type`),
  KEY `index_models_on_is_package` (`is_package`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `models`
--

LOCK TABLES `models` WRITE;
/*!40000 ALTER TABLE `models` DISABLE KEYS */;
/*!40000 ALTER TABLE `models` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `models_compatibles`
--

DROP TABLE IF EXISTS `models_compatibles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `models_compatibles` (
  `model_id` int(11) DEFAULT NULL,
  `compatible_id` int(11) DEFAULT NULL,
  KEY `index_models_compatibles_on_compatible_id` (`compatible_id`),
  KEY `index_models_compatibles_on_model_id` (`model_id`),
  CONSTRAINT `fk_rails_5c311e46b1` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `fk_rails_e63411efbd` FOREIGN KEY (`compatible_id`) REFERENCES `models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `models_compatibles`
--

LOCK TABLES `models_compatibles` WRITE;
/*!40000 ALTER TABLE `models_compatibles` DISABLE KEYS */;
/*!40000 ALTER TABLE `models_compatibles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_user_id` (`user_id`),
  KEY `index_notifications_on_created_at_and_user_id` (`created_at`,`user_id`),
  CONSTRAINT `fk_rails_b080fb4855` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numerators`
--

DROP TABLE IF EXISTS `numerators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `numerators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `numerators`
--

LOCK TABLES `numerators` WRITE;
/*!40000 ALTER TABLE `numerators` DISABLE KEYS */;
/*!40000 ALTER TABLE `numerators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `options`
--

DROP TABLE IF EXISTS `options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) NOT NULL,
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_options_on_inventory_pool_id` (`inventory_pool_id`),
  CONSTRAINT `fk_rails_fd8397be78` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `options`
--

LOCK TABLES `options` WRITE;
/*!40000 ALTER TABLE `options` DISABLE KEYS */;
/*!40000 ALTER TABLE `options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partitions`
--

DROP TABLE IF EXISTS `partitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) NOT NULL,
  `inventory_pool_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_partitions_on_model_id_and_inventory_pool_id_and_group_id` (`model_id`,`inventory_pool_id`,`group_id`),
  KEY `fk_rails_44495fc6cf` (`group_id`),
  KEY `fk_rails_b10a540212` (`inventory_pool_id`),
  CONSTRAINT `fk_rails_44495fc6cf` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `fk_rails_69c88ff594` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_b10a540212` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partitions`
--

LOCK TABLES `partitions` WRITE;
/*!40000 ALTER TABLE `partitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `partitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_accesses`
--

DROP TABLE IF EXISTS `procurement_accesses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_accesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_accesses_on_is_admin` (`is_admin`),
  KEY `fk_rails_8c572e2cea` (`user_id`),
  KEY `fk_rails_c116e35025` (`organization_id`),
  CONSTRAINT `fk_rails_8c572e2cea` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c116e35025` FOREIGN KEY (`organization_id`) REFERENCES `procurement_organizations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_accesses`
--

LOCK TABLES `procurement_accesses` WRITE;
/*!40000 ALTER TABLE `procurement_accesses` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_accesses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_attachments`
--

DROP TABLE IF EXISTS `procurement_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) DEFAULT NULL,
  `file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_file_size` int(11) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_396a61ca60` (`request_id`),
  CONSTRAINT `fk_rails_396a61ca60` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_attachments`
--

LOCK TABLES `procurement_attachments` WRITE;
/*!40000 ALTER TABLE `procurement_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_budget_limits`
--

DROP TABLE IF EXISTS `procurement_budget_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_budget_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_period_id` int(11) NOT NULL,
  `main_category_id` int(11) NOT NULL,
  `amount_cents` int(11) NOT NULL DEFAULT '0',
  `amount_currency` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'CHF',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_on_budget_period_id_and_category_id` (`budget_period_id`,`main_category_id`),
  KEY `fk_rails_1c5f9021ad` (`main_category_id`),
  CONSTRAINT `fk_rails_1c5f9021ad` FOREIGN KEY (`main_category_id`) REFERENCES `procurement_main_categories` (`id`),
  CONSTRAINT `fk_rails_beb637d785` FOREIGN KEY (`budget_period_id`) REFERENCES `procurement_budget_periods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_budget_limits`
--

LOCK TABLES `procurement_budget_limits` WRITE;
/*!40000 ALTER TABLE `procurement_budget_limits` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_budget_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_budget_periods`
--

DROP TABLE IF EXISTS `procurement_budget_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_budget_periods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `inspection_start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_budget_periods_on_end_date` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_budget_periods`
--

LOCK TABLES `procurement_budget_periods` WRITE;
/*!40000 ALTER TABLE `procurement_budget_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_budget_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_categories`
--

DROP TABLE IF EXISTS `procurement_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `main_category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_procurement_categories_on_name` (`name`),
  KEY `index_procurement_categories_on_main_category_id` (`main_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_categories`
--

LOCK TABLES `procurement_categories` WRITE;
/*!40000 ALTER TABLE `procurement_categories` DISABLE KEYS */;
INSERT INTO `procurement_categories` VALUES (1,'Existing requests',1);
/*!40000 ALTER TABLE `procurement_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_category_inspectors`
--

DROP TABLE IF EXISTS `procurement_category_inspectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_category_inspectors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_procurement_category_inspectors_on_user_id_and_category_id` (`user_id`,`category_id`),
  KEY `fk_rails_ed1149b98d` (`category_id`),
  CONSTRAINT `fk_rails_ed1149b98d` FOREIGN KEY (`category_id`) REFERENCES `procurement_categories` (`id`),
  CONSTRAINT `fk_rails_f80c94fb1e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_category_inspectors`
--

LOCK TABLES `procurement_category_inspectors` WRITE;
/*!40000 ALTER TABLE `procurement_category_inspectors` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_category_inspectors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_main_categories`
--

DROP TABLE IF EXISTS `procurement_main_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_main_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_procurement_main_categories_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_main_categories`
--

LOCK TABLES `procurement_main_categories` WRITE;
/*!40000 ALTER TABLE `procurement_main_categories` DISABLE KEYS */;
INSERT INTO `procurement_main_categories` VALUES (1,'Old Groups',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `procurement_main_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_organizations`
--

DROP TABLE IF EXISTS `procurement_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shortname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_0731e8b712` (`parent_id`),
  CONSTRAINT `fk_rails_0731e8b712` FOREIGN KEY (`parent_id`) REFERENCES `procurement_organizations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_organizations`
--

LOCK TABLES `procurement_organizations` WRITE;
/*!40000 ALTER TABLE `procurement_organizations` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_requests`
--

DROP TABLE IF EXISTS `procurement_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_period_id` int(11) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `article_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `article_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `requested_quantity` int(11) NOT NULL,
  `approved_quantity` int(11) DEFAULT NULL,
  `order_quantity` int(11) DEFAULT NULL,
  `price_cents` int(11) NOT NULL DEFAULT '0',
  `price_currency` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'CHF',
  `priority` enum('normal','high') COLLATE utf8_unicode_ci DEFAULT 'normal',
  `replacement` tinyint(1) DEFAULT '1',
  `supplier_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiver` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `motivation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `inspection_comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_f365098d3c` (`user_id`),
  KEY `fk_rails_214a7de1ff` (`model_id`),
  KEY `fk_rails_51707743b7` (`supplier_id`),
  KEY `fk_rails_8244a2f05f` (`location_id`),
  KEY `fk_rails_b6213e1ee9` (`budget_period_id`),
  KEY `fk_rails_4c51bafad3` (`organization_id`),
  KEY `fk_rails_bf7bec026c` (`template_id`),
  KEY `fk_rails_b740f37e3d` (`category_id`),
  CONSTRAINT `fk_rails_214a7de1ff` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `fk_rails_4c51bafad3` FOREIGN KEY (`organization_id`) REFERENCES `procurement_organizations` (`id`),
  CONSTRAINT `fk_rails_51707743b7` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `fk_rails_8244a2f05f` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_rails_b6213e1ee9` FOREIGN KEY (`budget_period_id`) REFERENCES `procurement_budget_periods` (`id`),
  CONSTRAINT `fk_rails_b740f37e3d` FOREIGN KEY (`category_id`) REFERENCES `procurement_categories` (`id`),
  CONSTRAINT `fk_rails_bf7bec026c` FOREIGN KEY (`template_id`) REFERENCES `procurement_templates` (`id`),
  CONSTRAINT `fk_rails_f365098d3c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_requests`
--

LOCK TABLES `procurement_requests` WRITE;
/*!40000 ALTER TABLE `procurement_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_settings`
--

DROP TABLE IF EXISTS `procurement_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_procurement_settings_on_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_settings`
--

LOCK TABLES `procurement_settings` WRITE;
/*!40000 ALTER TABLE `procurement_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurement_templates`
--

DROP TABLE IF EXISTS `procurement_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `article_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `article_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price_cents` int(11) NOT NULL DEFAULT '0',
  `price_currency` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'CHF',
  `supplier_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_e6aab61827` (`model_id`),
  KEY `fk_rails_46cc05bf71` (`supplier_id`),
  KEY `fk_rails_fe27b0b24a` (`category_id`),
  CONSTRAINT `fk_rails_46cc05bf71` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `fk_rails_e6aab61827` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `fk_rails_fe27b0b24a` FOREIGN KEY (`category_id`) REFERENCES `procurement_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurement_templates`
--

LOCK TABLES `procurement_templates` WRITE;
/*!40000 ALTER TABLE `procurement_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `procurement_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_properties_on_model_id` (`model_id`),
  CONSTRAINT `fk_rails_a52b96ad3d` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `properties`
--

LOCK TABLES `properties` WRITE;
/*!40000 ALTER TABLE `properties` DISABLE KEYS */;
/*!40000 ALTER TABLE `properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purposes`
--

DROP TABLE IF EXISTS `purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purposes`
--

LOCK TABLES `purposes` WRITE;
/*!40000 ALTER TABLE `purposes` DISABLE KEYS */;
/*!40000 ALTER TABLE `purposes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contract_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `delegated_user_id` int(11) DEFAULT NULL,
  `handed_over_by_user_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'ItemLine',
  `item_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `returned_date` date DEFAULT NULL,
  `option_id` int(11) DEFAULT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `returned_to_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status` enum('unsubmitted','submitted','rejected','approved','signed','closed') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reservations_on_start_date` (`start_date`),
  KEY `index_reservations_on_end_date` (`end_date`),
  KEY `index_reservations_on_option_id` (`option_id`),
  KEY `index_reservations_on_contract_id` (`contract_id`),
  KEY `index_reservations_on_item_id` (`item_id`),
  KEY `index_reservations_on_model_id` (`model_id`),
  KEY `index_reservations_on_returned_date_and_contract_id` (`returned_date`,`contract_id`),
  KEY `index_reservations_on_type_and_contract_id` (`type`,`contract_id`),
  KEY `index_reservations_on_status` (`status`),
  KEY `fk_rails_151794e412` (`inventory_pool_id`),
  KEY `fk_rails_48a92fce51` (`user_id`),
  KEY `fk_rails_6f10314351` (`delegated_user_id`),
  KEY `fk_rails_3cc4562273` (`handed_over_by_user_id`),
  KEY `fk_rails_1391c89ed4` (`purpose_id`),
  KEY `fk_rails_5cc2043d96` (`returned_to_user_id`),
  CONSTRAINT `fk_rails_1391c89ed4` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`),
  CONSTRAINT `fk_rails_151794e412` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `fk_rails_3cc4562273` FOREIGN KEY (`handed_over_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_48a92fce51` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_4d0c0195f0` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `fk_rails_5cc2043d96` FOREIGN KEY (`returned_to_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_6f10314351` FOREIGN KEY (`delegated_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_8dc1da71d1` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_943a884838` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `fk_rails_a863d81c8a` FOREIGN KEY (`option_id`) REFERENCES `options` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20151002000000'),('20151013060621'),('20160414090545'),('20160418075339'),('20160506120000'),('20160527094851'),('20161005103353');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `smtp_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smtp_port` int(11) DEFAULT NULL,
  `smtp_domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `local_currency_string` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `contract_terms` text COLLATE utf8_unicode_ci,
  `contract_lending_party_string` text COLLATE utf8_unicode_ci,
  `email_signature` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `default_email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `deliver_order_notifications` tinyint(1) DEFAULT NULL,
  `user_image_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ldap_config` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mail_delivery_method` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smtp_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smtp_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smtp_enable_starttls_auto` tinyint(1) NOT NULL DEFAULT '0',
  `smtp_openssl_verify_mode` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'none',
  `time_zone` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Bern',
  `disable_manage_section` tinyint(1) NOT NULL DEFAULT '0',
  `disable_manage_section_message` text COLLATE utf8_unicode_ci,
  `disable_borrow_section` tinyint(1) NOT NULL DEFAULT '0',
  `disable_borrow_section_message` text COLLATE utf8_unicode_ci,
  `text` text COLLATE utf8_unicode_ci,
  `timeout_minutes` int(11) NOT NULL DEFAULT '30',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'smtp.zhdk.ch',25,'beta.ausleihe.zhdk.ch','CHF','Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die \'Richtlinie zur Ausleihe von Sachen\' der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien.','Your\nAddress\nHere','Das PZ-leihs Team','sender@example.com',0,'http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}',NULL,'/assets/image-logo-zhdk.png','test',NULL,NULL,0,'none','Bern',0,NULL,0,NULL,NULL,30);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_suppliers_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `firstname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authentication_system_id` int(11) DEFAULT '1',
  `unique_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `badge_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `extended_info` text COLLATE utf8_unicode_ci,
  `settings` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delegator_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_authentication_system_id` (`authentication_system_id`),
  KEY `fk_rails_45f4f12508` (`language_id`),
  KEY `fk_rails_cc67a09e58` (`delegator_user_id`),
  CONSTRAINT `fk_rails_330f34f125` FOREIGN KEY (`authentication_system_id`) REFERENCES `authentication_systems` (`id`),
  CONSTRAINT `fk_rails_45f4f12508` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`),
  CONSTRAINT `fk_rails_cc67a09e58` FOREIGN KEY (`delegator_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workdays`
--

DROP TABLE IF EXISTS `workdays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workdays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `monday` tinyint(1) DEFAULT '1',
  `tuesday` tinyint(1) DEFAULT '1',
  `wednesday` tinyint(1) DEFAULT '1',
  `thursday` tinyint(1) DEFAULT '1',
  `friday` tinyint(1) DEFAULT '1',
  `saturday` tinyint(1) DEFAULT '0',
  `sunday` tinyint(1) DEFAULT '0',
  `reservation_advance_days` int(11) DEFAULT '0',
  `max_visits` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_workdays_on_inventory_pool_id` (`inventory_pool_id`),
  CONSTRAINT `fk_rails_a18bc267df` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workdays`
--

LOCK TABLES `workdays` WRITE;
/*!40000 ALTER TABLE `workdays` DISABLE KEYS */;
/*!40000 ALTER TABLE `workdays` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-10-13 14:11:59
commit; set unique_checks=1; set foreign_key_checks=1;
