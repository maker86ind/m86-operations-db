-- 014: holiday pay. Hours = min(cap, average weekly hours over the lookback / hours per credit)
-- (settings group holiday_pay). A row is written when the payroll email for the period is sent,
-- so later edits to older hours or settings never change what was already paid.
CREATE TABLE IF NOT EXISTS `holiday_pay` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `holiday_date` date NOT NULL,
  `holiday_name` varchar(150) NOT NULL,
  `pay_period_id` int unsigned NOT NULL,
  `hours` decimal(6,2) NOT NULL,
  `avg_weekly_hours` decimal(7,2) NOT NULL,
  `weeks` decimal(6,2) NOT NULL,
  `hours_per_credit` decimal(6,2) NOT NULL,
  `max_hours` decimal(6,2) NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_holiday_pay` (`employee_id`,`holiday_date`),
  KEY `ix_holiday_pay_period` (`pay_period_id`),
  CONSTRAINT `fk_hp_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hp_period` FOREIGN KEY (`pay_period_id`) REFERENCES `pay_periods` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
