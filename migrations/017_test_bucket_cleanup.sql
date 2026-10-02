-- 017: buckets hold real customer work only. Test employees were sometimes added to buckets before test
-- sessions were kept apart; those memberships and any hours they split onto buckets are removed. The app
-- no longer lets a test employee join a bucket, and ignores any such rows.

DELETE a FROM `bucket_allocations` a JOIN `employees` e ON e.`m86_id` = a.`employee_id` WHERE e.`is_test` = 1;
DELETE m FROM `bucket_members` m JOIN `employees` e ON e.`m86_id` = m.`employee_id` WHERE e.`is_test` = 1;
