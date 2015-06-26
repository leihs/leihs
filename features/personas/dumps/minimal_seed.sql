-- MySQL dump 10.13  Distrib 5.1.48, for apple-darwin10.3.0 (i386)
--
-- Host: localhost    Database: leihs2_test
-- ------------------------------------------------------
-- Server version	5.1.48

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
  `user_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `suspended_until` date DEFAULT NULL,
  `suspended_reason` text COLLATE utf8_unicode_ci,
  `deleted_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `role` enum('customer','group_manager','lending_manager','inventory_manager','admin') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_access_rights_on_suspended_until` (`suspended_until`),
  KEY `index_access_rights_on_deleted_at` (`deleted_at`),
  KEY `index_access_rights_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_access_rights_on_role` (`role`),
  KEY `index_on_user_id_and_inventory_pool_id_and_deleted_at` (`user_id`,`inventory_pool_id`,`deleted_at`),
  CONSTRAINT `access_rights_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `access_rights_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE
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
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accessories_on_model_id` (`model_id`),
  CONSTRAINT `accessories_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
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
  CONSTRAINT `accessories_inventory_pools_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `accessories_inventory_pools_accessory_id_fk` FOREIGN KEY (`accessory_id`) REFERENCES `accessories` (`id`)
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
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_model_id` (`model_id`),
  CONSTRAINT `attachments_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
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
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audits`
--

LOCK TABLES `audits` WRITE;
/*!40000 ALTER TABLE `audits` DISABLE KEYS */;
INSERT INTO `audits` VALUES (1,1,'Setting',NULL,NULL,NULL,NULL,NULL,'create','---\nsmtp_address: smtp.zhdk.ch\nsmtp_port: 25\nsmtp_domain: beta.ausleihe.zhdk.ch\nlocal_currency_string: CHF\ncontract_terms: Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder\n  Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig\n  zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter\n  Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene\n  Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der\n  Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner\n  Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die\n  \'Richtlinie zur Ausleihe von Sachen\' der ZHdK und etwaige abteilungsspezifische\n  Ausleih-Richtlinien.\ncontract_lending_party_string: |-\n  Your\n  Address\n  Here\nemail_signature: Das PZ-leihs Team\ndefault_email: sender@example.com\ndeliver_order_notifications: false\nuser_image_url: http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}\nldap_config: \nlogo_url: \"/assets/image-logo-zhdk.png\"\nmail_delivery_method: test\nsmtp_username: \nsmtp_password: \nsmtp_enable_starttls_auto: false\nsmtp_openssl_verify_mode: none\ntime_zone: Bern\ndisable_manage_section: false\ndisable_manage_section_message: \ndisable_borrow_section: false\ndisable_borrow_section_message: \ntext: \n',1,NULL,NULL,'cd4d0b89-8e72-4685-8745-89fef7798506','2015-06-22 12:54:59'),(2,1,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: English (UK)\nlocale_name: en-GB\ndefault: true\nactive: true\n',1,NULL,NULL,'d2bc8b11-b7f8-4584-946b-5c9db1f7aa91','2015-06-22 12:54:59'),(3,2,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: English (US)\nlocale_name: en-US\ndefault: false\nactive: true\n',1,NULL,NULL,'1a805878-32d4-4d0f-9a8b-c57b26f025e5','2015-06-22 12:54:59'),(4,3,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Deutsch\nlocale_name: de-CH\ndefault: false\nactive: true\n',1,NULL,NULL,'e3395a77-20fe-4b68-b9ed-f4fecdf9bac3','2015-06-22 12:54:59'),(5,4,'Language',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Züritüütsch\nlocale_name: gsw-CH\ndefault: false\nactive: true\n',1,NULL,NULL,'77648557-865b-4466-9ffd-8a9e14ded950','2015-06-22 12:54:59'),(6,1,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: Database Authentication\nclass_name: DatabaseAuthentication\nis_default: true\nis_active: true\n',1,NULL,NULL,'2f27f811-1b20-49bc-ac35-4cc6d7d9dceb','2015-06-22 12:54:59'),(7,2,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: LDAP Authentication\nclass_name: LdapAuthentication\nis_default: false\nis_active: false\n',1,NULL,NULL,'a8b31514-bdaf-460a-95f3-50b2d30b6831','2015-06-22 12:54:59'),(8,3,'AuthenticationSystem',NULL,NULL,NULL,NULL,NULL,'create','---\nname: ZHDK Authentication\nclass_name: Zhdk\nis_default: false\nis_active: false\n',1,NULL,NULL,'200a64b8-416e-48fb-b3e4-134ed83a5ac0','2015-06-22 12:54:59'),(9,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Inventory Code\n  attribute: inventory_code\n  required: true\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  group: \nactive: true\nposition: \n',1,NULL,NULL,'d4f80766-b31c-482a-a5dd-b9fc6d7b7dc0','2015-06-22 12:54:59'),(10,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 1\n',2,NULL,NULL,'60bab60a-ee2a-4954-bcdd-f16679ed438e','2015-06-22 12:54:59'),(11,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Model\n  attribute:\n  - model\n  - id\n  value_label:\n  - model\n  - product\n  value_label_ext:\n  - model\n  - version\n  form_name: model_id\n  required: true\n  type: autocomplete-search\n  target_type: item\n  search_path: models\n  search_attr: search_term\n  value_attr: id\n  display_attr: product\n  display_attr_ext: version\n  group: \nactive: true\nposition: \n',3,NULL,NULL,'a447becb-4780-4f4d-a068-3302fcac94b7','2015-06-22 12:54:59'),(12,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 2\n',4,NULL,NULL,'04727c5c-6ddb-42d9-9efd-fa759b092e97','2015-06-22 12:54:59'),(13,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Software\n  attribute:\n  - model\n  - id\n  value_label:\n  - model\n  - product\n  value_label_ext:\n  - model\n  - version\n  form_name: model_id\n  required: true\n  type: autocomplete-search\n  target_type: license\n  search_path: software\n  search_attr: search_term\n  value_attr: id\n  display_attr: product\n  display_attr_ext: version\n  group: \nactive: true\nposition: \n',5,NULL,NULL,'c8bf8f63-6eb5-49fa-9e97-dcf8a72cb30a','2015-06-22 12:54:59'),(14,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 3\n',6,NULL,NULL,'4cfbfa28-931f-425b-8e71-64321588f3b3','2015-06-22 12:54:59'),(15,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Serial Number\n  attribute: serial_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  group: General Information\nactive: true\nposition: \n',7,NULL,NULL,'10004e60-15d9-4eeb-be25-99b0d2e7866a','2015-06-22 12:54:59'),(16,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 4\n',8,NULL,NULL,'d18589f0-7df0-48ac-be87-6650dd68152a','2015-06-22 12:54:59'),(17,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: MAC-Address\n  attribute:\n  - properties\n  - mac_address\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: General Information\nactive: true\nposition: \n',9,NULL,NULL,'6abf5703-e9fb-4c2a-88ef-3884b8b2f7b0','2015-06-22 12:54:59'),(18,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 5\n',10,NULL,NULL,'69ca704c-be74-4bc5-a46d-369ddd0b6f71','2015-06-22 12:54:59'),(19,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: IMEI-Number\n  attribute:\n  - properties\n  - imei_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: General Information\nactive: true\nposition: \n',11,NULL,NULL,'45cc1786-3473-499d-8e34-6005ba873065','2015-06-22 12:54:59'),(20,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 6\n',12,NULL,NULL,'e877983b-d892-4641-ab51-cbe619e97a2c','2015-06-22 12:54:59'),(21,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Name\n  attribute: name\n  type: text\n  target_type: item\n  group: General Information\n  forPackage: true\nactive: true\nposition: \n',13,NULL,NULL,'bc1c2b3c-fc73-4252-8189-7f0e9c536a8c','2015-06-22 12:54:59'),(22,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 7\n',14,NULL,NULL,'61fb9301-3bbf-4d0b-a4a1-e32f19e2e669','2015-06-22 12:54:59'),(23,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Note\n  attribute: note\n  type: textarea\n  group: General Information\n  forPackage: true\nactive: true\nposition: \n',15,NULL,NULL,'80774726-c341-46a8-bf2d-d30c75974e59','2015-06-22 12:54:59'),(24,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 8\n',16,NULL,NULL,'92285be3-451f-442e-9e92-3931cb2d37e5','2015-06-22 12:54:59'),(25,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Retirement\n  attribute: retired\n  type: select\n  permissions:\n    role: lending_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: false\n  - label: \'Yes\'\n    value: true\n  default: false\n  group: Status\nactive: true\nposition: \n',17,NULL,NULL,'373500ff-39c9-4bcd-a69a-06245772a0b6','2015-06-22 12:54:59'),(26,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 9\n',18,NULL,NULL,'bac052c9-dc30-4604-83ba-d765684ae47f','2015-06-22 12:54:59'),(27,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Reason for Retirement\n  attribute: retired_reason\n  type: textarea\n  required: true\n  permissions:\n    role: lending_manager\n    owner: true\n  visibility_dependency_field_id: retired\n  visibility_dependency_value: \'true\'\n  group: Status\nactive: true\nposition: \n',19,NULL,NULL,'9614b35b-b09c-4303-a28c-ca1647992ca9','2015-06-22 12:54:59'),(28,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 10\n',20,NULL,NULL,'3beaf657-7515-4fff-ae42-e137ff6f7874','2015-06-22 12:54:59'),(29,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Working order\n  attribute: is_broken\n  type: radio\n  target_type: item\n  values:\n  - label: OK\n    value: false\n  - label: Broken\n    value: true\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: \n',21,NULL,NULL,'2eb5b97a-b1d6-4ccd-a5a4-30970a09c3bd','2015-06-22 12:54:59'),(30,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 11\n',22,NULL,NULL,'394ee3ff-51cb-48bc-af71-bbb348ca0230','2015-06-22 12:54:59'),(31,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Completeness\n  attribute: is_incomplete\n  type: radio\n  target_type: item\n  values:\n  - label: OK\n    value: false\n  - label: Incomplete\n    value: true\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: \n',23,NULL,NULL,'adc0fc81-7fc0-47f2-9b45-3a371ce33e38','2015-06-22 12:54:59'),(32,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 12\n',24,NULL,NULL,'04e0fc14-33d5-4e55-a7db-c3ddec9eee74','2015-06-22 12:54:59'),(33,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Borrowable\n  attribute: is_borrowable\n  type: radio\n  values:\n  - label: OK\n    value: true\n  - label: Unborrowable\n    value: false\n  default: false\n  group: Status\n  forPackage: true\nactive: true\nposition: \n',25,NULL,NULL,'d5fbdd4b-99fa-495c-b730-3fbd6b66b2e4','2015-06-22 12:54:59'),(34,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 13\n',26,NULL,NULL,'f0659c1a-1be6-43ff-a356-a81255444585','2015-06-22 12:54:59'),(35,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Status note\n  attribute: status_note\n  type: textarea\n  target_type: item\n  group: Status\n  forPackage: true\nactive: true\nposition: \n',27,NULL,NULL,'a8733817-5786-4eaa-a2b3-c5abcc7d91e7','2015-06-22 12:54:59'),(36,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 14\n',28,NULL,NULL,'043b04da-2618-4b00-af2d-8b6d57b457d1','2015-06-22 12:54:59'),(37,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Building\n  attribute:\n  - location\n  - building_id\n  type: autocomplete\n  target_type: item\n  values: all_buildings\n  group: Location\n  forPackage: true\nactive: true\nposition: \n',29,NULL,NULL,'608ee628-e3bb-4567-852d-b205125575cd','2015-06-22 12:54:59'),(38,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 15\n',30,NULL,NULL,'cf21eb81-7ea2-4166-a8b4-276198497707','2015-06-22 12:54:59'),(39,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Room\n  attribute:\n  - location\n  - room\n  type: text\n  target_type: item\n  group: Location\n  forPackage: true\nactive: true\nposition: \n',31,NULL,NULL,'4023a6b4-fc52-4c4a-9634-c0e5f4bcc525','2015-06-22 12:54:59'),(40,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 16\n',32,NULL,NULL,'545fa484-13bc-42d1-91e8-792375b22c70','2015-06-22 12:54:59'),(41,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Shelf\n  attribute:\n  - location\n  - shelf\n  type: text\n  target_type: item\n  group: Location\n  forPackage: true\nactive: true\nposition: \n',33,NULL,NULL,'ac1a320f-56ea-4815-b198-bf1b98e7fd94','2015-06-22 12:54:59'),(42,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 17\n',34,NULL,NULL,'474b2798-0dd9-4ebc-a52c-431a75bfd2cf','2015-06-22 12:54:59'),(43,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Relevant for inventory\n  attribute: is_inventory_relevant\n  type: select\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: false\n  - label: \'Yes\'\n    value: true\n  default: true\n  group: Inventory\n  forPackage: true\nactive: true\nposition: \n',35,NULL,NULL,'29749387-1fd5-441c-8156-d9a31b535e94','2015-06-22 12:54:59'),(44,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 18\n',36,NULL,NULL,'44638bbb-6290-4161-a269-96d1c5f49cec','2015-06-22 12:54:59'),(45,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Owner\n  attribute:\n  - owner\n  - id\n  type: autocomplete\n  permissions:\n    role: inventory_manager\n    owner: true\n  values: all_inventory_pools\n  group: Inventory\nactive: true\nposition: \n',37,NULL,NULL,'7070eb28-e393-4f4a-b4fc-277973f7641b','2015-06-22 12:54:59'),(46,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 19\n',38,NULL,NULL,'d6f52570-7d72-4bb4-b52b-c2f4615b7afb','2015-06-22 12:54:59'),(47,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Last Checked\n  attribute: last_check\n  permissions:\n    role: lending_manager\n    owner: true\n  default: today\n  type: date\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: \n',39,NULL,NULL,'9d6ec541-ee1f-4935-8e95-4e4ef4164423','2015-06-22 12:54:59'),(48,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 20\n',40,NULL,NULL,'4c415cb9-fd14-4fdd-a44b-0b266fc3ba42','2015-06-22 12:54:59'),(49,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Responsible department\n  attribute:\n  - inventory_pool\n  - id\n  type: autocomplete\n  values: all_inventory_pools\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Inventory\n  forPackage: true\nactive: true\nposition: \n',41,NULL,NULL,'f871e548-b6e5-492e-a061-6ef17e79df8a','2015-06-22 12:54:59'),(50,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 21\n',42,NULL,NULL,'b037c5e0-4c7e-44b8-b6c2-7cde4cdf7d07','2015-06-22 12:54:59'),(51,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Responsible person\n  attribute: responsible\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: \n',43,NULL,NULL,'19ba580b-6f3c-424d-8575-99ff0731f8ea','2015-06-22 12:54:59'),(52,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 22\n',44,NULL,NULL,'f92793d8-1697-446d-a441-0599a65b5374','2015-06-22 12:54:59'),(53,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: User/Typical usage\n  attribute: user_name\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Inventory\n  forPackage: true\nactive: true\nposition: \n',45,NULL,NULL,'23cade09-660f-4d08-9c78-164f9c637272','2015-06-22 12:54:59'),(54,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 23\n',46,NULL,NULL,'8ec04b42-665f-4791-a003-c9495457dd20','2015-06-22 12:54:59'),(55,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Reference\n  attribute:\n  - properties\n  - reference\n  permissions:\n    role: inventory_manager\n    owner: true\n  required: true\n  values:\n  - label: Running Account\n    value: invoice\n  - label: Investment\n    value: investment\n  default: invoice\n  type: radio\n  group: Invoice Information\nactive: true\nposition: \n',47,NULL,NULL,'6df8a7de-dd02-4691-8ef1-78e3cd58db79','2015-06-22 12:54:59'),(56,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 24\n',48,NULL,NULL,'373fb974-f204-4007-bdc8-b631fc6ae456','2015-06-22 12:54:59'),(57,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Project Number\n  attribute:\n  - properties\n  - project_number\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  required: true\n  visibility_dependency_field_id: properties_reference\n  visibility_dependency_value: investment\n  group: Invoice Information\nactive: true\nposition: \n',49,NULL,NULL,'3bb2a22a-dac9-4193-97eb-d0d677c87b2e','2015-06-22 12:54:59'),(58,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 25\n',50,NULL,NULL,'6b2a5fe3-2411-4b2a-a924-04cc20b82a50','2015-06-22 12:54:59'),(59,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Invoice Number\n  attribute: invoice_number\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: \n',51,NULL,NULL,'1aa28c13-fefa-4aef-bd0f-0b80f23e07a0','2015-06-22 12:54:59'),(60,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 26\n',52,NULL,NULL,'291beb7c-f62c-4327-936a-2f6597d9a899','2015-06-22 12:54:59'),(61,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Invoice Date\n  attribute: invoice_date\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  group: Invoice Information\nactive: true\nposition: \n',53,NULL,NULL,'bd2cb526-5214-4ef8-98c4-7b5bf58d923c','2015-06-22 12:54:59'),(62,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 27\n',54,NULL,NULL,'9d35226e-45a4-4219-84c0-60acdd2cb692','2015-06-22 12:54:59'),(63,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Initial Price\n  attribute: price\n  permissions:\n    role: lending_manager\n    owner: true\n  type: text\n  currency: true\n  group: Invoice Information\n  forPackage: true\nactive: true\nposition: \n',55,NULL,NULL,'31ca69b4-6d23-4f8a-9810-1ef07b7d10e1','2015-06-22 12:54:59'),(64,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 28\n',56,NULL,NULL,'ba0ce21d-125a-4512-a3a0-37d206581371','2015-06-22 12:54:59'),(65,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Supplier\n  attribute:\n  - supplier\n  - id\n  type: autocomplete\n  extensible: true\n  extended_key:\n  - supplier\n  - name\n  permissions:\n    role: lending_manager\n    owner: true\n  values: all_suppliers\n  group: Invoice Information\nactive: true\nposition: \n',57,NULL,NULL,'69d7ce43-06dc-4868-a5d4-59c84d8cb5ae','2015-06-22 12:54:59'),(66,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 29\n',58,NULL,NULL,'530066ee-a033-4bdf-8ee9-9a1ebf1b54e6','2015-06-22 12:54:59'),(67,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Warranty expiration\n  attribute:\n  - properties\n  - warranty_expiration\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: \n',59,NULL,NULL,'c0d4ea5d-40ac-42e2-9f23-dcb470eb5349','2015-06-22 12:54:59'),(68,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 30\n',60,NULL,NULL,'03d730d4-7877-47fd-9f4b-8fcb730cb5d1','2015-06-22 12:54:59'),(69,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Contract expiration\n  attribute:\n  - properties\n  - contract_expiration\n  permissions:\n    role: lending_manager\n    owner: true\n  type: date\n  target_type: item\n  group: Invoice Information\nactive: true\nposition: \n',61,NULL,NULL,'fa831404-6149-4821-a32f-f5aea2dff9ba','2015-06-22 12:54:59'),(70,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 31\n',62,NULL,NULL,'43ff664d-214f-46cb-a1bc-e853a85edc86','2015-06-22 12:54:59'),(71,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Umzug\n  attribute:\n  - properties\n  - umzug\n  type: select\n  target_type: item\n  values:\n  - label: zügeln\n    value: zügeln\n  - label: sofort entsorgen\n    value: sofort entsorgen\n  - label: bei Umzug entsorgen\n    value: bei Umzug entsorgen\n  - label: bei Umzug verkaufen\n    value: bei Umzug verkaufen\n  default: zügeln\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Umzug\nactive: true\nposition: \n',63,NULL,NULL,'d5398980-a230-47e0-aa1c-b21947909e59','2015-06-22 12:54:59'),(72,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 32\n',64,NULL,NULL,'99f67494-9303-4dda-918c-305f7c051ea6','2015-06-22 12:54:59'),(73,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Zielraum\n  attribute:\n  - properties\n  - zielraum\n  type: text\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Umzug\nactive: true\nposition: \n',65,NULL,NULL,'369bda56-a1f1-45f3-87b5-548cac82a3f4','2015-06-22 12:54:59'),(74,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 33\n',66,NULL,NULL,'681229ce-0c4a-4c83-ada7-aef7f5450395','2015-06-22 12:54:59'),(75,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftsdatum\n  attribute:\n  - properties\n  - ankunftsdatum\n  type: date\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: \n',67,NULL,NULL,'6804eb75-601f-4618-acfe-c3e992ef8eda','2015-06-22 12:54:59'),(76,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 34\n',68,NULL,NULL,'99918663-6df2-4cdc-a2a1-00f6acd46e54','2015-06-22 12:54:59'),(77,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftszustand\n  attribute:\n  - properties\n  - ankunftszustand\n  type: select\n  target_type: item\n  values:\n  - label: intakt\n    value: intakt\n  - label: transportschaden\n    value: transportschaden\n  default: intakt\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: \n',69,NULL,NULL,'08aa4660-41d2-42bf-b41b-2ffa79ae6a81','2015-06-22 12:54:59'),(78,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 35\n',70,NULL,NULL,'b712c15a-ff30-4e39-b572-119b544fb272','2015-06-22 12:54:59'),(79,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Ankunftsnotiz\n  attribute:\n  - properties\n  - ankunftsnotiz\n  type: textarea\n  target_type: item\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Toni Ankunftskontrolle\nactive: true\nposition: \n',71,NULL,NULL,'71db3d82-f0ab-4326-9b17-48da6cb6442f','2015-06-22 12:54:59'),(80,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 36\n',72,NULL,NULL,'84bf76d9-38ac-41a0-bb09-664c6366b85a','2015-06-22 12:54:59'),(81,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Anschaffungskategorie\n  attribute:\n  - properties\n  - anschaffungskategorie\n  value_label:\n  - properties\n  - anschaffungskategorie\n  required: true\n  type: select\n  target_type: item\n  values:\n  - label: \'\'\n    value: \n  - label: Werkstatt-Technik\n    value: Werkstatt-Technik\n  - label: Produktionstechnik\n    value: Produktionstechnik\n  - label: AV-Technik\n    value: AV-Technik\n  - label: Musikinstrumente\n    value: Musikinstrumente\n  - label: Facility Management\n    value: Facility Management\n  - label: IC-Technik/Software\n    value: IC-Technik/Software\n  default: \n  visibility_dependency_field_id: is_inventory_relevant\n  visibility_dependency_value: \'true\'\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: Inventory\nactive: true\nposition: \n',73,NULL,NULL,'9edaffda-561f-46ed-9fd4-e446b5b7eaa2','2015-06-22 12:54:59'),(82,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 37\n',74,NULL,NULL,'bc2ed8e5-c3ba-44ee-9b43-30f01152d1b1','2015-06-22 12:54:59'),(83,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Activation Type\n  attribute:\n  - properties\n  - activation_type\n  type: select\n  target_type: license\n  values:\n  - label: None\n    value: none\n  - label: Dongle\n    value: dongle\n  - label: Serial Number\n    value: serial_number\n  - label: License Server\n    value: license_server\n  - label: Challenge Response/System ID\n    value: challenge_response\n  default: none\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: \n',75,NULL,NULL,'22678ad3-90d5-4c67-8cb9-8d088ee51ea4','2015-06-22 12:54:59'),(84,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 38\n',76,NULL,NULL,'e062e653-223e-4227-bb81-3615d72714e1','2015-06-22 12:54:59'),(85,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Dongle ID\n  attribute:\n  - properties\n  - dongle_id\n  type: text\n  target_type: license\n  required: true\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_activation_type\n  visibility_dependency_value: dongle\n  group: General Information\nactive: true\nposition: \n',77,NULL,NULL,'5142acc0-0351-4f8f-bf35-d5f37abbd924','2015-06-22 12:54:59'),(86,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 39\n',78,NULL,NULL,'b7bfad08-3ffa-4ae5-9c4b-abf95878945b','2015-06-22 12:54:59'),(87,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: License Type\n  attribute:\n  - properties\n  - license_type\n  type: select\n  target_type: license\n  values:\n  - label: Free\n    value: free\n  - label: Single Workplace\n    value: single_workplace\n  - label: Multiple Workplace\n    value: multiple_workplace\n  - label: Site License\n    value: site_license\n  - label: Concurrent\n    value: concurrent\n  default: free\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: \n',79,NULL,NULL,'7e970370-d5d1-4ca2-84f1-c24bc816dae9','2015-06-22 12:54:59'),(88,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 40\n',80,NULL,NULL,'085432e9-0c11-4691-806e-aa7a8943a505','2015-06-22 12:54:59'),(89,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Total quantity\n  attribute:\n  - properties\n  - total_quantity\n  type: text\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_license_type\n  visibility_dependency_value:\n  - multiple_workplace\n  - site_license\n  - concurrent\n  group: General Information\nactive: true\nposition: \n',81,NULL,NULL,'c805e04f-2ff3-48e9-ac37-30bcedc69676','2015-06-22 12:54:59'),(90,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 41\n',82,NULL,NULL,'b9817615-36d6-4ea3-b6d9-da38d1c6b57c','2015-06-22 12:54:59'),(91,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Quantity allocations\n  attribute:\n  - properties\n  - quantity_allocations\n  type: composite\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_total_quantity\n  data_dependency_field_id: properties_total_quantity\n  group: General Information\nactive: true\nposition: \n',83,NULL,NULL,'fa53d28e-1945-4592-8046-178bfc8ba031','2015-06-22 12:54:59'),(92,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 42\n',84,NULL,NULL,'99af9d31-67f7-444e-8853-42113bacd750','2015-06-22 12:54:59'),(93,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Operating System\n  attribute:\n  - properties\n  - operating_system\n  type: checkbox\n  target_type: license\n  values:\n  - label: Windows\n    value: windows\n  - label: Mac OS X\n    value: mac_os_x\n  - label: Linux\n    value: linux\n  - label: iOS\n    value: ios\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: \n',85,NULL,NULL,'98eb1d14-86b9-47bc-9c79-b7779e519a4f','2015-06-22 12:54:59'),(94,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 43\n',86,NULL,NULL,'2fa458b8-358b-4397-bf34-1d57e1c197a8','2015-06-22 12:54:59'),(95,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Installation\n  attribute:\n  - properties\n  - installation\n  type: checkbox\n  target_type: license\n  values:\n  - label: Citrix\n    value: citrix\n  - label: Local\n    value: local\n  - label: Web\n    value: web\n  permissions:\n    role: inventory_manager\n    owner: true\n  group: General Information\nactive: true\nposition: \n',87,NULL,NULL,'0c39fd02-6d83-4895-8bcb-d89647e2546a','2015-06-22 12:54:59'),(96,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 44\n',88,NULL,NULL,'a72572fc-6407-4ee5-b769-c43a7216452b','2015-06-22 12:54:59'),(97,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: License expiration\n  attribute:\n  - properties\n  - license_expiration\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: date\n  target_type: license\n  group: General Information\nactive: true\nposition: \n',89,NULL,NULL,'79ca5404-ec0d-4efa-b5f9-4c435bf5cfc3','2015-06-22 12:54:59'),(98,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 45\n',90,NULL,NULL,'35a77385-a856-40a1-9071-4fb0aa482669','2015-06-22 12:54:59'),(99,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Maintenance contract\n  attribute:\n  - properties\n  - maintenance_contract\n  type: select\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  values:\n  - label: \'No\'\n    value: \'false\'\n  - label: \'Yes\'\n    value: \'true\'\n  default: \'false\'\n  group: Maintenance\nactive: true\nposition: \n',91,NULL,NULL,'2dc510f7-b5dc-4d2b-8260-17cbdb41d83e','2015-06-22 12:54:59'),(100,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 46\n',92,NULL,NULL,'64d27e87-f8c3-4a53-98e7-606946a9177b','2015-06-22 12:54:59'),(101,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Maintenance expiration\n  attribute:\n  - properties\n  - maintenance_expiration\n  type: date\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_contract\n  visibility_dependency_value: \'true\'\n  group: Maintenance\nactive: true\nposition: \n',93,NULL,NULL,'ac29f799-b733-41d6-905b-3c87592c008d','2015-06-22 12:54:59'),(102,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 47\n',94,NULL,NULL,'126b8d22-ba10-40b4-963e-2a4b5f480881','2015-06-22 12:54:59'),(103,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Currency\n  attribute:\n  - properties\n  - maintenance_currency\n  type: select\n  values: all_currencies\n  default: CHF\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_expiration\n  group: Maintenance\nactive: true\nposition: \n',95,NULL,NULL,'875e888b-e3df-4f77-9438-87456d8a35dd','2015-06-22 12:54:59'),(104,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 48\n',96,NULL,NULL,'98ec7205-2296-49fd-84c7-7192f58c80d7','2015-06-22 12:54:59'),(105,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Price\n  attribute:\n  - properties\n  - maintenance_price\n  type: text\n  currency: true\n  target_type: license\n  permissions:\n    role: inventory_manager\n    owner: true\n  visibility_dependency_field_id: properties_maintenance_currency\n  group: Maintenance\nactive: true\nposition: \n',97,NULL,NULL,'c41e8463-ac32-4c79-9362-c527c87383e7','2015-06-22 12:54:59'),(106,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 49\n',98,NULL,NULL,'98dc2d55-7089-48f7-be47-973e2417c092','2015-06-22 12:54:59'),(107,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'create','---\ndata:\n  label: Procured by\n  attribute:\n  - properties\n  - procured_by\n  permissions:\n    role: inventory_manager\n    owner: true\n  type: text\n  target_type: license\n  group: Invoice Information\nactive: true\nposition: \n',99,NULL,NULL,'88761b54-6679-4771-a2d2-af840e2a9a06','2015-06-22 12:54:59'),(108,NULL,'Field',NULL,NULL,NULL,NULL,NULL,'update','---\nposition:\n- \n- 50\n',100,NULL,NULL,'67faa473-606f-4bdf-998e-0ed8558ffcf5','2015-06-22 12:54:59');
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
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
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
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `database_authentications_user_id_fk` (`user_id`),
  CONSTRAINT `database_authentications_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
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
  CONSTRAINT `delegations_users_delegation_id_fk` FOREIGN KEY (`delegation_id`) REFERENCES `users` (`id`),
  CONSTRAINT `delegations_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
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
  `id` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
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
INSERT INTO `fields` VALUES ('inventory_code','{\"label\":\"Inventory Code\",\"attribute\":\"inventory_code\",\"required\":true,\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"group\":null}',1,1),('inventory_pool_id','{\"label\":\"Responsible department\",\"attribute\":[\"inventory_pool\",\"id\"],\"type\":\"autocomplete\",\"values\":\"all_inventory_pools\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Inventory\",\"forPackage\":true}',1,21),('invoice_date','{\"label\":\"Invoice Date\",\"attribute\":\"invoice_date\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"group\":\"Invoice Information\"}',1,27),('invoice_number','{\"label\":\"Invoice Number\",\"attribute\":\"invoice_number\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,26),('is_borrowable','{\"label\":\"Borrowable\",\"attribute\":\"is_borrowable\",\"type\":\"radio\",\"values\":[{\"label\":\"OK\",\"value\":true},{\"label\":\"Unborrowable\",\"value\":false}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,13),('is_broken','{\"label\":\"Working order\",\"attribute\":\"is_broken\",\"type\":\"radio\",\"target_type\":\"item\",\"values\":[{\"label\":\"OK\",\"value\":false},{\"label\":\"Broken\",\"value\":true}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,11),('is_incomplete','{\"label\":\"Completeness\",\"attribute\":\"is_incomplete\",\"type\":\"radio\",\"target_type\":\"item\",\"values\":[{\"label\":\"OK\",\"value\":false},{\"label\":\"Incomplete\",\"value\":true}],\"default\":false,\"group\":\"Status\",\"forPackage\":true}',1,12),('is_inventory_relevant','{\"label\":\"Relevant for inventory\",\"attribute\":\"is_inventory_relevant\",\"type\":\"select\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":false},{\"label\":\"Yes\",\"value\":true}],\"default\":true,\"group\":\"Inventory\",\"forPackage\":true}',1,18),('last_check','{\"label\":\"Last Checked\",\"attribute\":\"last_check\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"default\":\"today\",\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,20),('location_building_id','{\"label\":\"Building\",\"attribute\":[\"location\",\"building_id\"],\"type\":\"autocomplete\",\"target_type\":\"item\",\"values\":\"all_buildings\",\"group\":\"Location\",\"forPackage\":true}',1,15),('location_room','{\"label\":\"Room\",\"attribute\":[\"location\",\"room\"],\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Location\",\"forPackage\":true}',1,16),('location_shelf','{\"label\":\"Shelf\",\"attribute\":[\"location\",\"shelf\"],\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Location\",\"forPackage\":true}',1,17),('model_id','{\"label\":\"Model\",\"attribute\":[\"model\",\"id\"],\"value_label\":[\"model\",\"product\"],\"value_label_ext\":[\"model\",\"version\"],\"form_name\":\"model_id\",\"required\":true,\"type\":\"autocomplete-search\",\"target_type\":\"item\",\"search_path\":\"models\",\"search_attr\":\"search_term\",\"value_attr\":\"id\",\"display_attr\":\"product\",\"display_attr_ext\":\"version\",\"group\":null}',1,2),('name','{\"label\":\"Name\",\"attribute\":\"name\",\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\",\"forPackage\":true}',1,7),('note','{\"label\":\"Note\",\"attribute\":\"note\",\"type\":\"textarea\",\"group\":\"General Information\",\"forPackage\":true}',1,8),('owner_id','{\"label\":\"Owner\",\"attribute\":[\"owner\",\"id\"],\"type\":\"autocomplete\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":\"all_inventory_pools\",\"group\":\"Inventory\"}',1,19),('price','{\"label\":\"Initial Price\",\"attribute\":\"price\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"currency\":true,\"group\":\"Invoice Information\",\"forPackage\":true}',1,28),('properties_activation_type','{\"label\":\"Activation Type\",\"attribute\":[\"properties\",\"activation_type\"],\"type\":\"select\",\"target_type\":\"license\",\"values\":[{\"label\":\"None\",\"value\":\"none\"},{\"label\":\"Dongle\",\"value\":\"dongle\"},{\"label\":\"Serial Number\",\"value\":\"serial_number\"},{\"label\":\"License Server\",\"value\":\"license_server\"},{\"label\":\"Challenge Response/System ID\",\"value\":\"challenge_response\"}],\"default\":\"none\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,38),('properties_ankunftsdatum','{\"label\":\"Ankunftsdatum\",\"attribute\":[\"properties\",\"ankunftsdatum\"],\"type\":\"date\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,34),('properties_ankunftsnotiz','{\"label\":\"Ankunftsnotiz\",\"attribute\":[\"properties\",\"ankunftsnotiz\"],\"type\":\"textarea\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,36),('properties_ankunftszustand','{\"label\":\"Ankunftszustand\",\"attribute\":[\"properties\",\"ankunftszustand\"],\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"intakt\",\"value\":\"intakt\"},{\"label\":\"transportschaden\",\"value\":\"transportschaden\"}],\"default\":\"intakt\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Toni Ankunftskontrolle\"}',1,35),('properties_anschaffungskategorie','{\"label\":\"Anschaffungskategorie\",\"attribute\":[\"properties\",\"anschaffungskategorie\"],\"value_label\":[\"properties\",\"anschaffungskategorie\"],\"required\":true,\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"\",\"value\":null},{\"label\":\"Werkstatt-Technik\",\"value\":\"Werkstatt-Technik\"},{\"label\":\"Produktionstechnik\",\"value\":\"Produktionstechnik\"},{\"label\":\"AV-Technik\",\"value\":\"AV-Technik\"},{\"label\":\"Musikinstrumente\",\"value\":\"Musikinstrumente\"},{\"label\":\"Facility Management\",\"value\":\"Facility Management\"},{\"label\":\"IC-Technik/Software\",\"value\":\"IC-Technik/Software\"}],\"default\":null,\"visibility_dependency_field_id\":\"is_inventory_relevant\",\"visibility_dependency_value\":\"true\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Inventory\"}',1,37),('properties_contract_expiration','{\"label\":\"Contract expiration\",\"attribute\":[\"properties\",\"contract_expiration\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,31),('properties_dongle_id','{\"label\":\"Dongle ID\",\"attribute\":[\"properties\",\"dongle_id\"],\"type\":\"text\",\"target_type\":\"license\",\"required\":true,\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_activation_type\",\"visibility_dependency_value\":\"dongle\",\"group\":\"General Information\"}',1,39),('properties_imei_number','{\"label\":\"IMEI-Number\",\"attribute\":[\"properties\",\"imei_number\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\"}',1,6),('properties_installation','{\"label\":\"Installation\",\"attribute\":[\"properties\",\"installation\"],\"type\":\"checkbox\",\"target_type\":\"license\",\"values\":[{\"label\":\"Citrix\",\"value\":\"citrix\"},{\"label\":\"Local\",\"value\":\"local\"},{\"label\":\"Web\",\"value\":\"web\"}],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,44),('properties_license_expiration','{\"label\":\"License expiration\",\"attribute\":[\"properties\",\"license_expiration\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"license\",\"group\":\"General Information\"}',1,45),('properties_license_type','{\"label\":\"License Type\",\"attribute\":[\"properties\",\"license_type\"],\"type\":\"select\",\"target_type\":\"license\",\"values\":[{\"label\":\"Free\",\"value\":\"free\"},{\"label\":\"Single Workplace\",\"value\":\"single_workplace\"},{\"label\":\"Multiple Workplace\",\"value\":\"multiple_workplace\"},{\"label\":\"Site License\",\"value\":\"site_license\"},{\"label\":\"Concurrent\",\"value\":\"concurrent\"}],\"default\":\"free\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,40),('properties_mac_address','{\"label\":\"MAC-Address\",\"attribute\":[\"properties\",\"mac_address\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"General Information\"}',1,5),('properties_maintenance_contract','{\"label\":\"Maintenance contract\",\"attribute\":[\"properties\",\"maintenance_contract\"],\"type\":\"select\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":\"false\"},{\"label\":\"Yes\",\"value\":\"true\"}],\"default\":\"false\",\"group\":\"Maintenance\"}',1,46),('properties_maintenance_currency','{\"label\":\"Currency\",\"attribute\":[\"properties\",\"maintenance_currency\"],\"type\":\"select\",\"values\":\"all_currencies\",\"default\":\"CHF\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_expiration\",\"group\":\"Maintenance\"}',1,48),('properties_maintenance_expiration','{\"label\":\"Maintenance expiration\",\"attribute\":[\"properties\",\"maintenance_expiration\"],\"type\":\"date\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_contract\",\"visibility_dependency_value\":\"true\",\"group\":\"Maintenance\"}',1,47),('properties_maintenance_price','{\"label\":\"Price\",\"attribute\":[\"properties\",\"maintenance_price\"],\"type\":\"text\",\"currency\":true,\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_maintenance_currency\",\"group\":\"Maintenance\"}',1,49),('properties_operating_system','{\"label\":\"Operating System\",\"attribute\":[\"properties\",\"operating_system\"],\"type\":\"checkbox\",\"target_type\":\"license\",\"values\":[{\"label\":\"Windows\",\"value\":\"windows\"},{\"label\":\"Mac OS X\",\"value\":\"mac_os_x\"},{\"label\":\"Linux\",\"value\":\"linux\"},{\"label\":\"iOS\",\"value\":\"ios\"}],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"General Information\"}',1,43),('properties_procured_by','{\"label\":\"Procured by\",\"attribute\":[\"properties\",\"procured_by\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"license\",\"group\":\"Invoice Information\"}',1,50),('properties_project_number','{\"label\":\"Project Number\",\"attribute\":[\"properties\",\"project_number\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"required\":true,\"visibility_dependency_field_id\":\"properties_reference\",\"visibility_dependency_value\":\"investment\",\"group\":\"Invoice Information\"}',1,25),('properties_quantity_allocations','{\"label\":\"Quantity allocations\",\"attribute\":[\"properties\",\"quantity_allocations\"],\"type\":\"composite\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_total_quantity\",\"data_dependency_field_id\":\"properties_total_quantity\",\"group\":\"General Information\"}',1,42),('properties_reference','{\"label\":\"Reference\",\"attribute\":[\"properties\",\"reference\"],\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"required\":true,\"values\":[{\"label\":\"Running Account\",\"value\":\"invoice\"},{\"label\":\"Investment\",\"value\":\"investment\"}],\"default\":\"invoice\",\"type\":\"radio\",\"group\":\"Invoice Information\"}',1,24),('properties_total_quantity','{\"label\":\"Total quantity\",\"attribute\":[\"properties\",\"total_quantity\"],\"type\":\"text\",\"target_type\":\"license\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"properties_license_type\",\"visibility_dependency_value\":[\"multiple_workplace\",\"site_license\",\"concurrent\"],\"group\":\"General Information\"}',1,41),('properties_umzug','{\"label\":\"Umzug\",\"attribute\":[\"properties\",\"umzug\"],\"type\":\"select\",\"target_type\":\"item\",\"values\":[{\"label\":\"zügeln\",\"value\":\"zügeln\"},{\"label\":\"sofort entsorgen\",\"value\":\"sofort entsorgen\"},{\"label\":\"bei Umzug entsorgen\",\"value\":\"bei Umzug entsorgen\"},{\"label\":\"bei Umzug verkaufen\",\"value\":\"bei Umzug verkaufen\"}],\"default\":\"zügeln\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Umzug\"}',1,32),('properties_warranty_expiration','{\"label\":\"Warranty expiration\",\"attribute\":[\"properties\",\"warranty_expiration\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"date\",\"target_type\":\"item\",\"group\":\"Invoice Information\"}',1,30),('properties_zielraum','{\"label\":\"Zielraum\",\"attribute\":[\"properties\",\"zielraum\"],\"type\":\"text\",\"target_type\":\"item\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"group\":\"Umzug\"}',1,33),('responsible','{\"label\":\"Responsible person\",\"attribute\":\"responsible\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,22),('retired','{\"label\":\"Retirement\",\"attribute\":\"retired\",\"type\":\"select\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"values\":[{\"label\":\"No\",\"value\":false},{\"label\":\"Yes\",\"value\":true}],\"default\":false,\"group\":\"Status\"}',1,9),('retired_reason','{\"label\":\"Reason for Retirement\",\"attribute\":\"retired_reason\",\"type\":\"textarea\",\"required\":true,\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"visibility_dependency_field_id\":\"retired\",\"visibility_dependency_value\":\"true\",\"group\":\"Status\"}',1,10),('serial_number','{\"label\":\"Serial Number\",\"attribute\":\"serial_number\",\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"type\":\"text\",\"group\":\"General Information\"}',1,4),('software_model_id','{\"label\":\"Software\",\"attribute\":[\"model\",\"id\"],\"value_label\":[\"model\",\"product\"],\"value_label_ext\":[\"model\",\"version\"],\"form_name\":\"model_id\",\"required\":true,\"type\":\"autocomplete-search\",\"target_type\":\"license\",\"search_path\":\"software\",\"search_attr\":\"search_term\",\"value_attr\":\"id\",\"display_attr\":\"product\",\"display_attr_ext\":\"version\",\"group\":null}',1,3),('status_note','{\"label\":\"Status note\",\"attribute\":\"status_note\",\"type\":\"textarea\",\"target_type\":\"item\",\"group\":\"Status\",\"forPackage\":true}',1,14),('supplier_id','{\"label\":\"Supplier\",\"attribute\":[\"supplier\",\"id\"],\"type\":\"autocomplete\",\"extensible\":true,\"extended_key\":[\"supplier\",\"name\"],\"permissions\":{\"role\":\"lending_manager\",\"owner\":true},\"values\":\"all_suppliers\",\"group\":\"Invoice Information\"}',1,29),('user_name','{\"label\":\"User/Typical usage\",\"attribute\":\"user_name\",\"permissions\":{\"role\":\"inventory_manager\",\"owner\":true},\"type\":\"text\",\"target_type\":\"item\",\"group\":\"Inventory\",\"forPackage\":true}',1,23);
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
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `is_verification_required` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_groups_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_groups_on_is_verification_required` (`is_verification_required`),
  CONSTRAINT `groups_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
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
  CONSTRAINT `groups_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `groups_users_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
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
  CONSTRAINT `holidays_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE
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
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `contact_details` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contract_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contract_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_contract_note` text COLLATE utf8_unicode_ci,
  `shortname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `color` text COLLATE utf8_unicode_ci,
  `print_contracts` tinyint(1) DEFAULT '1',
  `opening_hours` text COLLATE utf8_unicode_ci,
  `address_id` int(11) DEFAULT NULL,
  `automatic_suspension` tinyint(1) NOT NULL DEFAULT '0',
  `automatic_suspension_reason` text COLLATE utf8_unicode_ci,
  `automatic_access` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_inventory_pools_on_name` (`name`),
  KEY `inventory_pools_address_id_fk` (`address_id`),
  CONSTRAINT `inventory_pools_address_id_fk` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
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
  CONSTRAINT `inventory_pools_model_groups_model_group_id_fk` FOREIGN KEY (`model_group_id`) REFERENCES `model_groups` (`id`),
  CONSTRAINT `inventory_pools_model_groups_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
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
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `serial_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
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
  KEY `items_supplier_id_fk` (`supplier_id`),
  CONSTRAINT `items_supplier_id_fk` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `items_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `items_location_id_fk` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `items_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `items_owner_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `items_parent_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `items` (`id`) ON DELETE SET NULL
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
  CONSTRAINT `locations_building_id_fk` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`)
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
  CONSTRAINT `model_group_links_descendant_id_fk` FOREIGN KEY (`descendant_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `model_group_links_ancestor_id_fk` FOREIGN KEY (`ancestor_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE
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
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
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
  `model_group_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_model_links_on_model_id_and_model_group_id` (`model_id`,`model_group_id`),
  KEY `index_model_links_on_model_group_id_and_model_id` (`model_group_id`,`model_id`),
  CONSTRAINT `model_links_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `model_links_model_group_id_fk` FOREIGN KEY (`model_group_id`) REFERENCES `model_groups` (`id`) ON DELETE CASCADE
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
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
  CONSTRAINT `models_compatibles_compatible_id_fk` FOREIGN KEY (`compatible_id`) REFERENCES `models` (`id`),
  CONSTRAINT `models_compatibles_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`)
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
  CONSTRAINT `notifications_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
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
  `inventory_pool_id` int(11) DEFAULT NULL,
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_options_on_inventory_pool_id` (`inventory_pool_id`),
  CONSTRAINT `options_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
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
  `model_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_partitions_on_model_id_and_inventory_pool_id_and_group_id` (`model_id`,`inventory_pool_id`,`group_id`),
  KEY `partitions_group_id_fk` (`group_id`),
  KEY `partitions_inventory_pool_id_fk` (`inventory_pool_id`),
  CONSTRAINT `partitions_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `partitions_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `partitions_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`)
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
-- Temporary table structure for view `partitions_with_generals`
--

DROP TABLE IF EXISTS `partitions_with_generals`;
/*!50001 DROP VIEW IF EXISTS `partitions_with_generals`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `partitions_with_generals` (
  `model_id` int(11),
  `inventory_pool_id` int(11),
  `group_id` int(11),
  `quantity` decimal(33,0)
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_properties_on_model_id` (`model_id`),
  CONSTRAINT `properties_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `delegated_user_id` int(11) DEFAULT NULL,
  `handed_over_by_user_id` int(11) DEFAULT NULL,
  `status` enum('unsubmitted','submitted','rejected','approved','signed','closed') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contract_lines_on_start_date` (`start_date`),
  KEY `index_contract_lines_on_end_date` (`end_date`),
  KEY `index_contract_lines_on_option_id` (`option_id`),
  KEY `index_contract_lines_on_contract_id` (`contract_id`),
  KEY `index_contract_lines_on_item_id` (`item_id`),
  KEY `index_contract_lines_on_model_id` (`model_id`),
  KEY `index_contract_lines_on_returned_date_and_contract_id` (`returned_date`,`contract_id`),
  KEY `index_contract_lines_on_type_and_contract_id` (`type`,`contract_id`),
  KEY `contract_lines_purpose_id_fk` (`purpose_id`),
  KEY `contract_lines_returned_to_user_id_fk` (`returned_to_user_id`),
  KEY `index_reservations_on_status` (`status`),
  KEY `reservations_inventory_pool_id_fk` (`inventory_pool_id`),
  KEY `reservations_user_id_fk` (`user_id`),
  KEY `reservations_delegated_user_id_fk` (`delegated_user_id`),
  KEY `reservations_handed_over_by_user_id_fk` (`handed_over_by_user_id`),
  CONSTRAINT `reservations_handed_over_by_user_id_fk` FOREIGN KEY (`handed_over_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `contract_lines_contract_id_fk` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `contract_lines_item_id_fk` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `contract_lines_model_id_fk` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `contract_lines_option_id_fk` FOREIGN KEY (`option_id`) REFERENCES `options` (`id`),
  CONSTRAINT `contract_lines_purpose_id_fk` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`),
  CONSTRAINT `contract_lines_returned_to_user_id_fk` FOREIGN KEY (`returned_to_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reservations_delegated_user_id_fk` FOREIGN KEY (`delegated_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reservations_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`),
  CONSTRAINT `reservations_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
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
INSERT INTO `schema_migrations` VALUES ('20140410180000'),('20140903105715'),('20150129121330'),('20150427062734'),('20150428160035'),('20150507143147'),('20150527084404'),('20150616123337');
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
  `local_currency_string` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contract_terms` text COLLATE utf8_unicode_ci,
  `contract_lending_party_string` text COLLATE utf8_unicode_ci,
  `email_signature` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'smtp.zhdk.ch',25,'beta.ausleihe.zhdk.ch','CHF','Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die \'Richtlinie zur Ausleihe von Sachen\' der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien.','Your\nAddress\nHere','Das PZ-leihs Team','sender@example.com',0,'http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}',NULL,'/assets/image-logo-zhdk.png','test',NULL,NULL,0,'none','Bern',0,NULL,0,NULL,NULL);
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
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
  `firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `delegator_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_authentication_system_id` (`authentication_system_id`),
  KEY `users_language_id_fk` (`language_id`),
  KEY `users_delegator_user_id_fk` (`delegator_user_id`),
  CONSTRAINT `users_delegator_user_id_fk` FOREIGN KEY (`delegator_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `users_authentication_system_id_fk` FOREIGN KEY (`authentication_system_id`) REFERENCES `authentication_systems` (`id`),
  CONSTRAINT `users_language_id_fk` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
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
-- Temporary table structure for view `visits`
--

DROP TABLE IF EXISTS `visits`;
/*!50001 DROP VIEW IF EXISTS `visits`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `visits` (
  `id` varchar(148),
  `inventory_pool_id` int(11),
  `user_id` int(11),
  `status` enum('unsubmitted','submitted','rejected','approved','signed','closed'),
  `date` date,
  `quantity` decimal(32,0)
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

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
  CONSTRAINT `workdays_inventory_pool_id_fk` FOREIGN KEY (`inventory_pool_id`) REFERENCES `inventory_pools` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workdays`
--

LOCK TABLES `workdays` WRITE;
/*!40000 ALTER TABLE `workdays` DISABLE KEYS */;
/*!40000 ALTER TABLE `workdays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `partitions_with_generals`
--

/*!50001 DROP TABLE IF EXISTS `partitions_with_generals`*/;
/*!50001 DROP VIEW IF EXISTS `partitions_with_generals`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `partitions_with_generals` AS select `partitions`.`model_id` AS `model_id`,`partitions`.`inventory_pool_id` AS `inventory_pool_id`,`partitions`.`group_id` AS `group_id`,`partitions`.`quantity` AS `quantity` from `partitions` union select `i`.`model_id` AS `model_id`,`i`.`inventory_pool_id` AS `inventory_pool_id`,NULL AS `group_id`,(count(`i`.`id`) - ifnull((select sum(`p`.`quantity`) from `partitions` `p` where ((`p`.`model_id` = `i`.`model_id`) and (`p`.`inventory_pool_id` = `i`.`inventory_pool_id`)) group by `p`.`inventory_pool_id`,`p`.`model_id`),0)) AS `quantity` from `items` `i` where (isnull(`i`.`retired`) and (`i`.`is_borrowable` = 1) and isnull(`i`.`parent_id`)) group by `i`.`inventory_pool_id`,`i`.`model_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `visits`
--

/*!50001 DROP TABLE IF EXISTS `visits`*/;
/*!50001 DROP VIEW IF EXISTS `visits`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `visits` AS select hex(concat_ws('_',if((`reservations`.`status` = 'signed'),`reservations`.`end_date`,`reservations`.`start_date`),`reservations`.`inventory_pool_id`,`reservations`.`user_id`,`reservations`.`status`)) AS `id`,`reservations`.`inventory_pool_id` AS `inventory_pool_id`,`reservations`.`user_id` AS `user_id`,`reservations`.`status` AS `status`,if((`reservations`.`status` = 'signed'),`reservations`.`end_date`,`reservations`.`start_date`) AS `date`,sum(`reservations`.`quantity`) AS `quantity` from `reservations` where (`reservations`.`status` in ('submitted','approved','signed')) group by `reservations`.`user_id`,`reservations`.`status`,if((`reservations`.`status` = 'signed'),`reservations`.`end_date`,`reservations`.`start_date`),`reservations`.`inventory_pool_id` order by if((`reservations`.`status` = 'signed'),`reservations`.`end_date`,`reservations`.`start_date`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-22 14:55:00
