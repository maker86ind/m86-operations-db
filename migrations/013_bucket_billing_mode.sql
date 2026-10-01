-- 013: how a bucket is billed, and which month a billing covers.
-- ahead = hours are billed first and reported hours count down (a retainer).
-- after = reported hours pile up as unbilled until they are billed, usually monthly.
ALTER TABLE `buckets` ADD COLUMN IF NOT EXISTS `billing_mode` enum('ahead','after') NOT NULL DEFAULT 'ahead' AFTER `billable`;
ALTER TABLE `prebill_entries` ADD COLUMN IF NOT EXISTS `period_start` date DEFAULT NULL AFTER `entry_date`;
ALTER TABLE `prebill_entries` ADD COLUMN IF NOT EXISTS `period_end` date DEFAULT NULL AFTER `period_start`;
