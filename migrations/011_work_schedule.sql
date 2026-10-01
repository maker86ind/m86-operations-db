-- 011: planned work days, where they happen, and weekly repeats.

CREATE TABLE IF NOT EXISTS `work_locations` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_work_location_name` (`name`),
  CONSTRAINT `fk_work_location_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A weekly repeat: every `weekday` (0 = Sunday) from start_date until end_date (NULL = open-ended).
CREATE TABLE IF NOT EXISTS `work_schedule_repeats` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `weekday` tinyint unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location_id` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_wsr_employee_weekday` (`employee_id`,`weekday`,`start_date`),
  CONSTRAINT `fk_wsr_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wsr_location` FOREIGN KEY (`location_id`) REFERENCES `work_locations` (`m86_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One planned day. Overrides a repeat on that date; NULL times = not working that day.
CREATE TABLE IF NOT EXISTS `work_schedule` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `work_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location_id` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_work_schedule_day` (`employee_id`,`work_date`),
  KEY `ix_work_schedule_date` (`work_date`),
  CONSTRAINT `fk_ws_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ws_location` FOREIGN KEY (`location_id`) REFERENCES `work_locations` (`m86_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
