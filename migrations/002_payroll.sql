-- 002: employees, wages, pay periods, daily hours, submissions, payroll emails

CREATE TABLE IF NOT EXISTS `employees` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `display_name` varchar(150) NOT NULL,
  `name_aliases` varchar(500) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `exempt_ot` tinyint(1) NOT NULL DEFAULT 0,
  `approver_user_id` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_employees_user` (`user_id`),
  CONSTRAINT `fk_employees_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_employees_approver` FOREIGN KEY (`approver_user_id`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `employee_wages` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `pay_type` enum('hourly','salaried') NOT NULL DEFAULT 'hourly',
  `rate` decimal(10,2) NOT NULL,
  `hours_per_period` decimal(8,2) DEFAULT NULL,
  `effective_date` date NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_wage_effective` (`employee_id`,`effective_date`),
  CONSTRAINT `fk_wages_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pay_periods` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `pay_date` date NOT NULL,
  `status` enum('open','closed','ready','sent','locked') NOT NULL DEFAULT 'open',
  `email_sent_ts` datetime DEFAULT NULL,
  `reopened_ts` datetime DEFAULT NULL,
  `reopen_reason` varchar(500) DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_pay_periods_start` (`start_date`),
  KEY `ix_pay_periods_end` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `day_entries` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `work_date` date NOT NULL,
  `hours` decimal(6,2) NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_day_entry` (`employee_id`,`work_date`),
  CONSTRAINT `fk_day_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `period_submissions` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `pay_period_id` int unsigned NOT NULL,
  `status` enum('draft','submitted','approved','returned') NOT NULL DEFAULT 'draft',
  `salaried_hours_override` decimal(8,2) DEFAULT NULL,
  `submitted_ts` datetime DEFAULT NULL,
  `approved_by` int unsigned DEFAULT NULL,
  `approved_ts` datetime DEFAULT NULL,
  `return_comment` varchar(1000) DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_submission` (`employee_id`,`pay_period_id`),
  CONSTRAINT `fk_sub_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sub_period` FOREIGN KEY (`pay_period_id`) REFERENCES `pay_periods` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payroll_emails` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `pay_period_id` int unsigned DEFAULT NULL,
  `kind` enum('auto','correction','test') NOT NULL DEFAULT 'auto',
  `from_addr` varchar(255) NOT NULL,
  `to_list` text NOT NULL,
  `cc_list` text DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `status` enum('sent','failed') NOT NULL,
  `message_id` varchar(255) DEFAULT NULL,
  `error` text DEFAULT NULL,
  `sent_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_payroll_emails_period` (`pay_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
