-- 003: customers, buckets, categories, pre-billing, allocations, pay stubs

CREATE TABLE IF NOT EXISTS `customers` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `qbo_customer_id` varchar(40) DEFAULT NULL,
  `billing_cycle_start_day` tinyint unsigned NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_customers_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `customer_users` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_customer_user` (`customer_id`,`user_id`),
  CONSTRAINT `fk_cu_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cu_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `buckets` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int unsigned DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `billable` tinyint(1) NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_buckets_customer` (`customer_id`),
  CONSTRAINT `fk_buckets_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bucket_categories` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `bucket_id` int unsigned NOT NULL,
  `name` varchar(200) NOT NULL,
  `qbo_item_id` varchar(40) DEFAULT NULL,
  `bill_rate` decimal(10,2) DEFAULT NULL,
  `low_threshold_hours` decimal(8,2) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_categories_bucket` (`bucket_id`),
  CONSTRAINT `fk_categories_bucket` FOREIGN KEY (`bucket_id`) REFERENCES `buckets` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bucket_members` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `bucket_id` int unsigned NOT NULL,
  `employee_id` int unsigned NOT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_bucket_member` (`bucket_id`,`employee_id`),
  CONSTRAINT `fk_bm_bucket` FOREIGN KEY (`bucket_id`) REFERENCES `buckets` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bm_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bm_category` FOREIGN KEY (`category_id`) REFERENCES `bucket_categories` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `prebill_entries` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int unsigned NOT NULL,
  `hours` decimal(8,2) NOT NULL,
  `entry_date` date NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_prebill_category` (`category_id`),
  CONSTRAINT `fk_prebill_category` FOREIGN KEY (`category_id`) REFERENCES `bucket_categories` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bucket_allocations` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `work_date` date NOT NULL,
  `bucket_id` int unsigned NOT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `hours` decimal(6,2) NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_allocation` (`employee_id`,`work_date`,`bucket_id`),
  KEY `ix_alloc_bucket` (`bucket_id`,`work_date`),
  CONSTRAINT `fk_alloc_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_alloc_bucket` FOREIGN KEY (`bucket_id`) REFERENCES `buckets` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_alloc_category` FOREIGN KEY (`category_id`) REFERENCES `bucket_categories` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `paystub_uploads` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `pay_period_id` int unsigned DEFAULT NULL,
  `kind` enum('combined','single') NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `stored_path` varchar(500) NOT NULL,
  `page_count` int unsigned NOT NULL DEFAULT 0,
  `status` enum('review','published') NOT NULL DEFAULT 'review',
  `uploaded_by` int unsigned DEFAULT NULL,
  `published_by` int unsigned DEFAULT NULL,
  `published_ts` datetime DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  CONSTRAINT `fk_upload_period` FOREIGN KEY (`pay_period_id`) REFERENCES `pay_periods` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `paystub_pages` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `upload_id` int unsigned NOT NULL,
  `page_number` int unsigned NOT NULL,
  `text_excerpt` varchar(500) DEFAULT NULL,
  `matched_employee_id` int unsigned DEFAULT NULL,
  `assigned_employee_id` int unsigned DEFAULT NULL,
  `skipped` tinyint(1) NOT NULL DEFAULT 0,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_upload_page` (`upload_id`,`page_number`),
  CONSTRAINT `fk_pages_upload` FOREIGN KEY (`upload_id`) REFERENCES `paystub_uploads` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `paystubs` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `upload_id` int unsigned NOT NULL,
  `employee_id` int unsigned NOT NULL,
  `pay_period_id` int unsigned DEFAULT NULL,
  `stored_path` varchar(500) NOT NULL,
  `pages` varchar(100) NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_paystubs_employee` (`employee_id`),
  CONSTRAINT `fk_paystubs_upload` FOREIGN KEY (`upload_id`) REFERENCES `paystub_uploads` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_paystubs_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_paystubs_period` FOREIGN KEY (`pay_period_id`) REFERENCES `pay_periods` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
