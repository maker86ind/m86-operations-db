-- 006: one test user per role, and super-admin-issued time-limited access grants for them

ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `is_test` tinyint(1) NOT NULL DEFAULT 0 AFTER `is_break_glass`;
ALTER TABLE `employees` ADD COLUMN IF NOT EXISTS `is_test` tinyint(1) NOT NULL DEFAULT 0 AFTER `active`;

-- Only the sha256 of a grant token is stored; `token_prefix` is for display.
CREATE TABLE IF NOT EXISTS `test_grants` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `token_hash` char(64) NOT NULL,
  `token_prefix` varchar(16) NOT NULL,
  `role_key` varchar(50) NOT NULL,
  `test_user_id` int unsigned NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `hours` smallint unsigned NOT NULL,
  `max_uses` smallint unsigned NOT NULL,
  `use_count` smallint unsigned NOT NULL DEFAULT 0,
  `expires_ts` datetime NOT NULL,
  `issued_by` int unsigned DEFAULT NULL,
  `last_used_ts` datetime DEFAULT NULL,
  `last_used_ip` varchar(64) DEFAULT NULL,
  `revoked_ts` datetime DEFAULT NULL,
  `revoked_by` int unsigned DEFAULT NULL,
  `revoke_reason` varchar(255) DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_test_grant_token` (`token_hash`),
  KEY `ix_test_grant_expires` (`expires_ts`),
  CONSTRAINT `fk_test_grant_user` FOREIGN KEY (`test_user_id`) REFERENCES `users` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_test_grant_issuer` FOREIGN KEY (`issued_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_test_grant_revoker` FOREIGN KEY (`revoked_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A session opened with a grant ends when the grant is revoked (sessions are deleted by grant).
ALTER TABLE `sessions` ADD COLUMN IF NOT EXISTS `test_grant_id` int unsigned DEFAULT NULL AFTER `acting_as_user_id`;
ALTER TABLE `sessions` ADD KEY IF NOT EXISTS `ix_sessions_test_grant` (`test_grant_id`);
