-- 008: holidays that repeat every year, calculated for any year instead of entered yearly.
--   fixed    month/day, e.g. Dec 25; `observed` moves Sat -> Fri and Sun -> Mon
--   weekday  nth (1-5, or -1 = last) weekday (0 = Sun .. 6 = Sat) of a month, e.g. 4th Thu of Nov
--   easter   days from Western Easter Sunday, e.g. -2 = Good Friday
CREATE TABLE IF NOT EXISTS `holiday_rules` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `country` char(2) NOT NULL,
  `name` varchar(150) NOT NULL,
  `kind` enum('fixed','weekday','easter') NOT NULL,
  `month` tinyint unsigned DEFAULT NULL,
  `day` tinyint unsigned DEFAULT NULL,
  `weekday` tinyint unsigned DEFAULT NULL,
  `nth` tinyint DEFAULT NULL,
  `offset_days` smallint DEFAULT NULL,
  `observed` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_holiday_rule_country_name` (`country`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
