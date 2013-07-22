CREATE TABLE `access_rights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `suspended_until` date DEFAULT NULL,
  `deleted_at` date DEFAULT NULL,
  `access_level` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `suspended_reason` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_access_rights_on_suspended_until` (`suspended_until`),
  KEY `index_access_rights_on_deleted_at` (`deleted_at`),
  KEY `index_access_rights_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_access_rights_on_role_id` (`role_id`),
  KEY `index_on_user_id_and_inventory_pool_id_and_deleted_at` (`user_id`,`inventory_pool_id`,`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `accessories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accessories_on_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `accessories_inventory_pools` (
  `accessory_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_accessories_inventory_pools` (`accessory_id`,`inventory_pool_id`),
  KEY `index_accessories_inventory_pools_on_inventory_pool_id` (`inventory_pool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `authentication_systems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `class_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `backup_order_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_backup_order_lines_on_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `backup_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `status_const` int(11) DEFAULT '1',
  `purpose` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_backup_orders_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_backup_orders_on_order_id` (`order_id`),
  KEY `index_backup_orders_on_status_const` (`status_const`),
  KEY `index_backup_orders_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `buildings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comment` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `commentable_id` int(11) NOT NULL,
  `commentable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable_id_and_commentable_type` (`commentable_id`,`commentable_type`),
  KEY `index_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contract_lines` (
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
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contract_lines_on_start_date` (`start_date`),
  KEY `index_contract_lines_on_end_date` (`end_date`),
  KEY `index_contract_lines_on_option_id` (`option_id`),
  KEY `fk_contract_lines_contract_id` (`contract_id`),
  KEY `fk_contract_lines_item_id` (`item_id`),
  KEY `fk_contract_lines_model_id` (`model_id`),
  KEY `index_contract_lines_on_returned_date_and_contract_id` (`returned_date`,`contract_id`),
  KEY `index_contract_lines_on_type_and_contract_id` (`type`,`contract_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contracts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `status_const` int(11) DEFAULT '1',
  `purpose` text COLLATE utf8_unicode_ci,
  `note` text COLLATE utf8_unicode_ci,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `handed_over_by_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contracts_on_delta` (`delta`),
  KEY `index_contracts_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_contracts_on_status_const` (`status_const`),
  KEY `index_contracts_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `database_authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_groups_on_delta` (`delta`),
  KEY `index_groups_on_inventory_pool_id` (`inventory_pool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `groups_users` (
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_groups_users_on_user_id_and_group_id` (`user_id`,`group_id`),
  KEY `index_groups_users_on_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `type_const` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `target_id` int(11) NOT NULL,
  `target_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_histories_on_target_type_and_target_id` (`target_type`,`target_id`),
  KEY `index_histories_on_type_const` (`type_const`),
  KEY `index_histories_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_holidays_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_holidays_on_start_date_and_end_date` (`start_date`,`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_on_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
  `delta` tinyint(1) DEFAULT '1',
  `opening_hours` text COLLATE utf8_unicode_ci,
  `address_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_inventory_pools_on_name` (`name`),
  KEY `index_inventory_pools_on_delta` (`delta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `inventory_pools_model_groups` (
  `inventory_pool_id` int(11) DEFAULT NULL,
  `model_group_id` int(11) DEFAULT NULL,
  KEY `index_inventory_pools_model_groups_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_inventory_pools_model_groups_on_model_group_id` (`model_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `serial_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
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
  `needs_permission` tinyint(1) DEFAULT '0',
  `inventory_pool_id` int(11) DEFAULT NULL,
  `is_inventory_relevant` tinyint(1) DEFAULT '0',
  `responsible` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `insurance_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `name` text COLLATE utf8_unicode_ci,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `properties` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_items_on_inventory_code` (`inventory_code`),
  KEY `index_items_on_delta` (`delta`),
  KEY `index_items_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_items_on_retired` (`retired`),
  KEY `index_items_on_is_borrowable` (`is_borrowable`),
  KEY `index_items_on_is_broken` (`is_broken`),
  KEY `index_items_on_is_incomplete` (`is_incomplete`),
  KEY `index_items_on_location_id` (`location_id`),
  KEY `index_items_on_owner_id` (`owner_id`),
  KEY `index_items_on_parent_id_and_retired` (`parent_id`,`retired`),
  KEY `index_items_on_model_id_and_retired_and_inventory_pool_id` (`model_id`,`retired`,`inventory_pool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_name` (`name`),
  KEY `index_languages_on_active_and_default` (`active`,`default`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shelf` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `building_id` int(11) DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_locations_on_delta` (`delta`),
  KEY `index_locations_on_building_id` (`building_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
  KEY `index_on_descendant_id_and_ancestor_id_and_direct` (`descendant_id`,`ancestor_id`,`direct`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `model_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_model_groups_on_delta` (`delta`),
  KEY `index_model_groups_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `model_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_group_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_model_links_on_model_id_and_model_group_id` (`model_id`,`model_group_id`),
  KEY `index_model_links_on_model_group_id_and_model_id` (`model_group_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `models` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `internal_description` text COLLATE utf8_unicode_ci,
  `info_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rental_price` decimal(8,2) DEFAULT NULL,
  `maintenance_period` int(11) DEFAULT '0',
  `is_package` tinyint(1) DEFAULT '0',
  `technical_detail` text COLLATE utf8_unicode_ci,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `hand_over_note` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_models_on_delta` (`delta`),
  KEY `index_models_on_is_package` (`is_package`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `models_compatibles` (
  `model_id` int(11) DEFAULT NULL,
  `compatible_id` int(11) DEFAULT NULL,
  KEY `index_models_compatibles_on_compatible_id` (`compatible_id`),
  KEY `index_models_compatibles_on_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `numerators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `inventory_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_options_on_delta` (`delta`),
  KEY `index_options_on_inventory_pool_id` (`inventory_pool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `order_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_order_lines_on_start_date` (`start_date`),
  KEY `index_order_lines_on_end_date` (`end_date`),
  KEY `index_order_lines_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_order_lines_on_model_id` (`model_id`),
  KEY `index_order_lines_on_order_id` (`order_id`),
  KEY `index_order_lines_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `status_const` int(11) DEFAULT '1',
  `purpose` text COLLATE utf8_unicode_ci,
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_orders_on_delta` (`delta`),
  KEY `index_orders_on_inventory_pool_id` (`inventory_pool_id`),
  KEY `index_orders_on_status_const` (`status_const`),
  KEY `index_orders_on_user_id_and_status_const` (`user_id`,`status_const`),
  KEY `index_orders_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `partitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `inventory_pool_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_partitions_on_model_id_and_inventory_pool_id_and_group_id` (`model_id`,`inventory_pool_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_properties_on_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_roles_on_delta` (`delta`),
  KEY `index_roles_on_parent_id` (`parent_id`),
  KEY `index_roles_on_lft` (`lft`),
  KEY `index_roles_on_rgt` (`rgt`),
  KEY `index_roles_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
  `delta` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `settings` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_delta` (`delta`),
  KEY `index_users_on_authentication_system_id` (`authentication_system_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
  PRIMARY KEY (`id`),
  KEY `index_workdays_on_inventory_pool_id` (`inventory_pool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20101213125330');

INSERT INTO schema_migrations (version) VALUES ('20110111175705');

INSERT INTO schema_migrations (version) VALUES ('20110117113700');

INSERT INTO schema_migrations (version) VALUES ('20110119193618');

INSERT INTO schema_migrations (version) VALUES ('20110201160119');

INSERT INTO schema_migrations (version) VALUES ('20110222163245');

INSERT INTO schema_migrations (version) VALUES ('20110318110901');

INSERT INTO schema_migrations (version) VALUES ('20110523133506');

INSERT INTO schema_migrations (version) VALUES ('20110617090905');

INSERT INTO schema_migrations (version) VALUES ('20110704075302');

INSERT INTO schema_migrations (version) VALUES ('20110815110417');

INSERT INTO schema_migrations (version) VALUES ('20110921134810');

INSERT INTO schema_migrations (version) VALUES ('20111118141748');

INSERT INTO schema_migrations (version) VALUES ('20111123154235');

INSERT INTO schema_migrations (version) VALUES ('20120106214650');

INSERT INTO schema_migrations (version) VALUES ('20120424080000');

INSERT INTO schema_migrations (version) VALUES ('20120523134739');

INSERT INTO schema_migrations (version) VALUES ('20120618143839');

INSERT INTO schema_migrations (version) VALUES ('20120619083752');

INSERT INTO schema_migrations (version) VALUES ('20120806140527');

INSERT INTO schema_migrations (version) VALUES ('20120806203246');

INSERT INTO schema_migrations (version) VALUES ('20120807101549');

INSERT INTO schema_migrations (version) VALUES ('20120921102118');

INSERT INTO schema_migrations (version) VALUES ('20121109141157');

INSERT INTO schema_migrations (version) VALUES ('20130111105833');

INSERT INTO schema_migrations (version) VALUES ('20130704160000');