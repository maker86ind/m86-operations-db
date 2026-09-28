-- Seed: admin-configurable settings with defaults.
-- Idempotent. Re-running refreshes label/help/default/order but NEVER overwrites
-- a value an admin has set (value_json is only written on first insert).

INSERT INTO `settings` (`setting_key`,`setting_group`,`value_json`,`default_json`,`value_type`,`label`,`help_text`,`sort_order`) VALUES
-- Organization
('org.company_name','organization','"Maker86 Industries LLC"','"Maker86 Industries LLC"','string','Company name','Used in email subjects and page titles.',10),
('org.timezone','organization','"America/Chicago"','"America/Chicago"','string','Timezone','IANA timezone for dates, schedules and send times.',20),
('org.app_url','organization','"https://operations.maker86.com"','"https://operations.maker86.com"','string','App URL','Public URL used in links and OAuth redirects.',30),

-- Payroll schedule
('payroll.period_start_days','payroll_schedule','[8,22]','[8,22]','json','Pay period start days','Days of the month a pay period starts. [8,22] = 8th-21st and 22nd-7th.',10),
('payroll.paydays','payroll_schedule','[7,21]','[7,21]','json','Paydays','Days of the month payroll is paid. A period is paid on the first payday after it ends.',20),
('payroll.submit_deadline_days','payroll_schedule','2','2','number','Submit deadline (days after period end)','Employees should submit their hours within this many days after the period ends.',30),
('payroll.send_days_before_payday','payroll_schedule','7','7','number','Send email (days before payday)','Target day for the accountant email. Held until every entry is approved.',40),
('payroll.latest_send_days_before_payday','payroll_schedule','5','5','number','Latest send (days before payday)','Used to warn that the email is late.',50),
('payroll.send_time','payroll_schedule','"07:00"','"07:00"','time','Send time','Local time of day the email goes out once due.',60),
('payroll.workweek_start','payroll_schedule','0','0','number','Workweek start day','0 = Sunday ... 6 = Saturday. Used for overtime checks.',70),
('payroll.ot_threshold_hours','payroll_schedule','40','40','number','Overtime threshold (hours per workweek)','Lines over this are annotated for the accountant.',80),
('payroll.ot_annotation','payroll_schedule','true','true','boolean','Annotate overtime in the email','Adds an OT note to an employee line when a workweek exceeds the threshold.',90),

-- Payroll email
('email.from_address','payroll_email','"operations@maker86.com"','"operations@maker86.com"','string','From address','Sender address. Must be allowed by the SMTP account.',10),
('email.from_name','payroll_email','"Maker86 Operations"','"Maker86 Operations"','string','From name','',20),
('email.reply_to','payroll_email','""','""','string','Reply-To','Where accountant replies go. Blank = From address.',30),
('email.to_accountant_role','payroll_email','true','true','boolean','Send to Accountant-role users','Adds every active Accountant user to To.',40),
('email.extra_to','payroll_email','[]','[]','email_list','Extra To recipients','',50),
('email.cc','payroll_email','[]','[]','email_list','CC recipients','',60),
('email.subject_template','payroll_email','"{{payday}} Payroll - {{company}}"','"{{payday}} Payroll - {{company}}"','string','Subject template','Variables: {{payday}} (YYYY/MM/DD), {{company}}, {{period_start}}, {{period_end}}.',70),
('email.body_template','payroll_email','"Pay Period: {{period_start}} - {{period_end}}\\n\\n{{lines}}\\n\\n{{signature}}"','"Pay Period: {{period_start}} - {{period_end}}\\n\\n{{lines}}\\n\\n{{signature}}"','text','Body template','Variables: {{period_start}}, {{period_end}} (MM/DD/YYYY), {{lines}}, {{signature}}, {{company}}.',80),
('email.line_template','payroll_email','"{{name}} - Hours: {{hours}}, Rate: ${{rate}}"','"{{name}} - Hours: {{hours}}, Rate: ${{rate}}"','string','Employee line template','Variables: {{name}}, {{hours}}, {{rate}}, {{pto}}. {{pto}} is the PTO text below (blank when no PTO); if the template has no {{pto}} it is added at the end. Lines are separated by a blank line.',90),
('email.pto_template','payroll_email','", PTO: {{pto_hours}}"','", PTO: {{pto_hours}}"','string','PTO text on employee line','Shown only when the employee took PTO in the period. Variables: {{pto_hours}}.',95),
('email.signature','payroll_email','"--\\nMaker86 Industries"','"--\\nMaker86 Industries"','text','Signature','',100),

-- SMTP (password comes from the SMTP_PASSWORD environment variable)
('smtp.host','smtp','"smtp.gmail.com"','"smtp.gmail.com"','string','SMTP host','',10),
('smtp.port','smtp','465','465','number','SMTP port','465 = implicit TLS, 587 = STARTTLS.',20),
('smtp.user','smtp','""','""','string','SMTP username','Password is set in the server environment (SMTP_PASSWORD), never here.',30),

-- Auth
('auth.google_domains','auth','["maker86.com"]','["maker86.com"]','json','Google Workspace domains','Accounts from these domains may sign in with Google.',10),
('auth.auto_provision','auth','false','false','boolean','Auto-create users on first Google sign-in','Off = an admin must add the user first.',20),
('auth.session_idle_minutes','auth','720','720','number','Session idle timeout (minutes)','',30),
('auth.session_max_days','auth','30','30','number','Session max age (days)','',40),
('auth.invite_expiry_hours','auth','72','72','number','Invite link expiry (hours)','',50),

-- MFA
('mfa.required_roles','mfa','["super_admin","admin","accountant","approver"]','["super_admin","admin","accountant","approver"]','json','Roles that must use MFA','Users holding any of these roles must enrol MFA.',10),
('mfa.remember_days','mfa','30','30','number','Remember device (days)','0 = ask every login. Super Admins are always asked.',20),

-- Buckets
('buckets.default_low_threshold_hours','buckets','10','10','number','Default low-balance threshold (hours)','Categories without their own threshold use this.',10),
('buckets.client_sees_resources','buckets','true','true','boolean','Clients see per-person hours','Show resource names and hours in the client view.',20),

-- PTO / time off
('pto.accrual_hours','pto','1','1','number','PTO earned (hours)','PTO hours earned for every block of hours worked below. Proportional: half the hours earns half. Employees can have their own rate.',10),
('pto.per_worked_hours','pto','40','40','number','Per hours worked','Hours worked that earn the PTO above. Accrual posts when the period payroll email is sent.',20),
('pto.max_balance_hours','pto','0','0','number','Maximum PTO balance (hours)','Accrual stops at this balance. 0 = no cap.',30),
('pto.allow_negative','pto','false','false','boolean','Allow negative PTO balance','Off = a PTO request cannot be approved for more hours than the employee has.',40),
('pto.max_negative_hours','pto','40','40','number','Maximum negative PTO balance (hours)','Only used when a negative balance is allowed: the balance may not go below minus this many hours. 0 = no limit.',45),
('pto.default_day_hours','pto','8','8','number','Default hours per day off','Pre-filled on time off requests.',50),
('pto.skip_weekends','pto','true','true','boolean','Skip weekends in time off requests','Saturdays and Sundays inside a requested range are not counted.',60),

-- Backups
('backups.time','backups','"02:00"','"02:00"','time','Nightly backup time','',10),
('backups.retention_days','backups','30','30','number','Backup retention (days)','',20)
ON DUPLICATE KEY UPDATE
  `setting_group` = VALUES(`setting_group`),
  `default_json` = VALUES(`default_json`),
  `value_type` = VALUES(`value_type`),
  `label` = VALUES(`label`),
  `help_text` = VALUES(`help_text`),
  `sort_order` = VALUES(`sort_order`);
