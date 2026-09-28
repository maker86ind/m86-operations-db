-- 005: holiday calendars by country, and each employee's country

CREATE TABLE IF NOT EXISTS `holidays` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `country` char(2) NOT NULL,
  `holiday_date` date NOT NULL,
  `name` varchar(150) NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_holiday_country_date` (`country`,`holiday_date`),
  KEY `ix_holiday_date` (`holiday_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee's holiday calendar. NULL = the `org.country` setting.
ALTER TABLE `employees` ADD COLUMN IF NOT EXISTS `country` char(2) DEFAULT NULL AFTER `pto_accrual_rate`;
