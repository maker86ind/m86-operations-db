-- 009: tax forms. Employees upload their W-4; accountants upload W-2s through the same
-- upload -> review -> publish flow as pay stubs (doc_type + tax_year on the upload).
ALTER TABLE `paystub_uploads` ADD COLUMN IF NOT EXISTS `doc_type` enum('paystub','w2') NOT NULL DEFAULT 'paystub' AFTER `m86_id`;
ALTER TABLE `paystub_uploads` ADD COLUMN IF NOT EXISTS `tax_year` smallint unsigned DEFAULT NULL AFTER `pay_period_id`;

CREATE TABLE IF NOT EXISTS `tax_documents` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `form` enum('w2','w4') NOT NULL,
  `tax_year` smallint unsigned DEFAULT NULL,
  `upload_id` int unsigned DEFAULT NULL,
  `pages` varchar(200) DEFAULT NULL,
  `original_filename` varchar(255) DEFAULT NULL,
  `content_type` varchar(50) NOT NULL DEFAULT 'application/pdf',
  `stored_path` varchar(500) NOT NULL,
  `uploaded_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_taxdoc_employee_form` (`employee_id`, `form`, `tax_year`),
  CONSTRAINT `fk_taxdoc_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
