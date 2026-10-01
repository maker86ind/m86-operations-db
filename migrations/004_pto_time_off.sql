-- 004: PTO bank (ledger) and time off requests

-- Per-employee accrual override: PTO hours earned per `pto.per_worked_hours` worked.
-- NULL = use the `pto.accrual_hours` setting, 0 = this employee does not accrue.
ALTER TABLE `employees` ADD COLUMN IF NOT EXISTS `pto_accrual_rate` decimal(6,3) DEFAULT NULL AFTER `approver_user_id`;

CREATE TABLE IF NOT EXISTS `time_off_requests` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `kind` enum('pto','unpaid') NOT NULL DEFAULT 'pto',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `hours_per_day` decimal(5,2) NOT NULL,
  `total_hours` decimal(8,2) NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `status` enum('pending','approved','denied','cancelled') NOT NULL DEFAULT 'pending',
  `decided_by` int unsigned DEFAULT NULL,
  `decided_ts` datetime DEFAULT NULL,
  `decision_comment` varchar(500) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_tor_employee_status` (`employee_id`,`status`),
  KEY `ix_tor_dates` (`start_date`,`end_date`),
  CONSTRAINT `fk_tor_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tor_decided_by` FOREIGN KEY (`decided_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One row per requested day (weekends skipped per `pto.skip_weekends`), so a request
-- that spans two pay periods is counted in each.
CREATE TABLE IF NOT EXISTS `time_off_days` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned NOT NULL,
  `employee_id` int unsigned NOT NULL,
  `off_date` date NOT NULL,
  `hours` decimal(5,2) NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_tod_request_date` (`request_id`,`off_date`),
  KEY `ix_tod_employee_date` (`employee_id`,`off_date`),
  CONSTRAINT `fk_tod_request` FOREIGN KEY (`request_id`) REFERENCES `time_off_requests` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tod_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- PTO bank. Balance = SUM(hours). Accruals are one row per employee per pay period
-- (unique key), so re-sending a reopened period recalculates instead of double-counting.
CREATE TABLE IF NOT EXISTS `pto_ledger` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `kind` enum('accrual','usage','reversal','adjustment') NOT NULL,
  `hours` decimal(8,2) NOT NULL,
  `pay_period_id` int unsigned DEFAULT NULL,
  `request_id` int unsigned DEFAULT NULL,
  `basis_hours` decimal(8,2) DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_pto_period_kind` (`employee_id`,`pay_period_id`,`kind`),
  KEY `ix_pto_employee` (`employee_id`,`m86_create_ts`),
  CONSTRAINT `fk_pto_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pto_period` FOREIGN KEY (`pay_period_id`) REFERENCES `pay_periods` (`m86_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pto_request` FOREIGN KEY (`request_id`) REFERENCES `time_off_requests` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
