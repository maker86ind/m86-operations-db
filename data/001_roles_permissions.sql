-- Seed: roles, permissions and default role -> permission sets.
-- Idempotent. Re-running refreshes names/descriptions and ADDS missing grants;
-- it never removes grants an admin added in the UI.

INSERT INTO `permissions` (`perm_key`, `description`) VALUES
  ('settings.manage',   'Edit system settings'),
  ('security.manage',   'Edit MFA policy and security settings'),
  ('users.manage',      'Create, disable and assign roles to users; send invites'),
  ('roles.manage',      'Create and edit roles and their permissions'),
  ('impersonate',       'Act as another user (audited)'),
  ('audit.view',        'View the audit log'),
  ('employees.manage',  'Create and edit employees'),
  ('wages.view',        'View employee wages'),
  ('wages.manage',      'Edit employee wages'),
  ('time.own',          'Enter and submit own hours'),
  ('time.view_all',     'View all employees hours'),
  ('time.approve',      'Approve or return submitted periods'),
  ('time.edit_any',     'Edit any employee hours'),
  ('periods.manage',    'Reopen and manage pay periods'),
  ('payroll.view',      'View payroll summaries and sent emails'),
  ('payroll.send',      'Send correction or test payroll emails'),
  ('buckets.manage',    'Manage customers, buckets, categories and pre-billing'),
  ('buckets.view_all',  'View all buckets and balances'),
  ('buckets.view_own_customer', 'View buckets of linked customers (client portal)'),
  ('paystubs.upload',   'Upload and publish pay stubs'),
  ('paystubs.view_all', 'View all pay stubs'),
  ('paystubs.view_own', 'View own pay stubs'),
  ('pto.manage',        'Adjust PTO balances and per-employee accrual rates'),
  ('testing.manage',    'Issue and revoke test-user access links (one test user per role)'),
  ('taxdocs.view_own',  'Upload own W-4 and view own tax forms'),
  ('taxdocs.view_all',  'View all employees W-4s and W-2s'),
  ('taxdocs.upload',    'Upload and publish W-2s'),
  ('schedule.own',      'Enter own planned work days'),
  ('calendar.view',     'See the company calendar (who is working or off)'),
  ('locations.manage',  'Add, rename and archive work locations'),
  ('tasks.use',         'See, create and work on tasks'),
  ('tasks.manage_all',  'Edit and delete anyone''s tasks and comments'),
  ('tasks.categories',  'Manage task categories')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `roles` (`role_key`, `name`, `description`, `is_system`) VALUES
  ('super_admin', 'Super Admin', 'Everything, including security settings and act-as-user', 1),
  ('admin',       'Admin',       'Runs payroll, buckets, employees and users', 1),
  ('approver',    'Approver / Manager', 'Approves submitted hours', 1),
  ('accountant',  'Accountant',  'Read-only payroll, wages and pay stubs; uploads pay stubs', 1),
  ('employee',    'Employee',    'Enters own hours and views own pay stubs', 1),
  ('client',      'Client',      'Read-only view of their own buckets', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `description` = VALUES(`description`), `is_system` = 1;

-- super_admin: every permission
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r CROSS JOIN permissions p WHERE r.role_key = 'super_admin';

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r JOIN permissions p ON p.perm_key IN (
  'settings.manage','users.manage','audit.view','employees.manage','wages.view','wages.manage',
  'time.own','time.view_all','time.approve','time.edit_any','periods.manage','payroll.view','payroll.send',
  'buckets.manage','buckets.view_all','paystubs.upload','paystubs.view_all','paystubs.view_own','pto.manage',
  'taxdocs.view_own','taxdocs.view_all','taxdocs.upload','schedule.own','calendar.view','locations.manage',
  'tasks.use','tasks.manage_all','tasks.categories')
WHERE r.role_key = 'admin';

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r JOIN permissions p ON p.perm_key IN (
  'time.own','time.view_all','time.approve','time.edit_any','buckets.view_all','paystubs.view_own','taxdocs.view_own',
  'schedule.own','calendar.view','locations.manage','tasks.use')
WHERE r.role_key = 'approver';

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r JOIN permissions p ON p.perm_key IN (
  'wages.view','time.view_all','payroll.view','paystubs.upload','paystubs.view_all','taxdocs.view_all','taxdocs.upload','calendar.view',
  'tasks.use')
WHERE r.role_key = 'accountant';

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r JOIN permissions p ON p.perm_key IN (
  'time.own','paystubs.view_own','taxdocs.view_own','schedule.own','calendar.view','tasks.use')
WHERE r.role_key = 'employee';

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.m86_id, p.m86_id FROM roles r JOIN permissions p ON p.perm_key IN (
  'buckets.view_own_customer')
WHERE r.role_key = 'client';
