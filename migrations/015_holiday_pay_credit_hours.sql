-- 015: holiday pay is "X average weekly hours per Y holiday hours" (was a fixed Y = 1).
-- Keep Y with each paid holiday so the record shows the rule it was paid under.
ALTER TABLE `holiday_pay` ADD COLUMN IF NOT EXISTS `credit_hours` decimal(6,2) NOT NULL DEFAULT 1.00 AFTER `hours_per_credit`;
