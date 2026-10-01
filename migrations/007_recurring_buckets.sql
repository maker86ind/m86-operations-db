-- Recurring buckets: a category can add a fixed number of hours every billing cycle
-- (on the customer's billing_cycle_start_day). The hours land as ordinary prebill entries,
-- so balances work exactly as before; cycle_date makes each cycle's entry unique.
ALTER TABLE `bucket_categories` ADD COLUMN IF NOT EXISTS `recurring_hours` decimal(8,2) DEFAULT NULL AFTER `low_threshold_hours`;
ALTER TABLE `prebill_entries` ADD COLUMN IF NOT EXISTS `cycle_date` date DEFAULT NULL AFTER `entry_date`;
ALTER TABLE `prebill_entries` ADD UNIQUE KEY IF NOT EXISTS `uk_prebill_cycle` (`category_id`, `cycle_date`);
