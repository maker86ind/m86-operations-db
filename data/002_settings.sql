-- Seed: admin-configurable settings with defaults.
-- Idempotent. Re-running refreshes label/help/default/order but NEVER overwrites
-- a value an admin has set (value_json is only written on first insert).

INSERT INTO `settings` (`setting_key`,`setting_group`,`value_json`,`default_json`,`value_type`,`label`,`help_text`,`sort_order`) VALUES
-- Organization
('org.company_name','organization','"Maker86 Industries LLC"','"Maker86 Industries LLC"','string','Company name','Used in email subjects and page titles.',10),
('org.timezone','organization','"America/Chicago"','"America/Chicago"','string','Timezone','IANA timezone for dates, schedules and send times.',20),
('org.country','organization','"US"','"US"','string','Country','Two-letter country code (US, CA, GB...). Its holidays decide payday business days, and it is the default holiday calendar for employees without their own country.',25),
('org.app_url','organization','"https://operations.maker86.com"','"https://operations.maker86.com"','string','App URL','Public URL used in links and OAuth redirects.',30),

-- Payroll schedule
('payroll.period_start_days','payroll_schedule','[8,22]','[8,22]','json','Pay period start days','Days of the month a pay period starts. 8 and 22 = the 8th–21st and the 22nd–7th.',10),
('payroll.paydays','payroll_schedule','[7,21]','[7,21]','json','Paydays','Days of the month payroll is paid. A period is paid on the first payday after it ends.',20),
('payroll.payday_adjust','payroll_schedule','"previous"','"previous"','string','Payday on a weekend or holiday','Holidays come from the company country (Payroll → Holidays).',25),
('payroll.submit_deadline_days','payroll_schedule','2','2','number','Submit deadline (days after period end)','Employees should submit their hours within this many days after the period ends.',30),
('payroll.send_days_before_payday','payroll_schedule','7','7','number','Send email (days before payday)','Target day for the accountant email. Held until every entry is approved.',40),
('payroll.latest_send_days_before_payday','payroll_schedule','5','5','number','Latest send (days before payday)','Used to warn that the email is late.',50),
('payroll.send_time','payroll_schedule','"07:00"','"07:00"','time','Send time','Local time of day the email goes out once due.',60),
('payroll.workweek_start','payroll_schedule','0','0','number','Workweek start day','Used for overtime checks.',70),
('payroll.ot_threshold_hours','payroll_schedule','40','40','number','Overtime threshold (hours per workweek)','Lines over this are annotated for the accountant.',80),
('payroll.ot_annotation','payroll_schedule','true','true','boolean','Annotate overtime in the email','Adds an OT note to an employee line when a workweek exceeds the threshold.',90),

-- Payroll email
('email.from_address','payroll_email','"operations@maker86.com"','"operations@maker86.com"','string','From address','Sender address. Must be allowed by the SMTP account.',10),
('email.from_name','payroll_email','"Maker86 Operations"','"Maker86 Operations"','string','From name','',20),
('email.reply_to','payroll_email','""','""','string','Reply-To','Where accountant replies go. Blank = From address.',30),
('email.to_accountant_role','payroll_email','true','true','boolean','Send to Accountant-role users','Adds every active Accountant user to To.',40),
('email.extra_to','payroll_email','[]','[]','email_list','Extra To recipients','',50),
('email.cc','payroll_email','[]','[]','email_list','CC recipients','',60),
('email.subject_template','payroll_email','"{{payday}} Payroll - {{company}}"','"{{payday}} Payroll - {{company}}"','string','Subject template','Variables: {{payday}} (YYYY/MM/DD), {{payday_us}} (MM/DD/YYYY), {{company}}, {{period_start}}, {{period_end}}.',70),
('email.body_template','payroll_email','"Pay Period: {{period_start}} - {{period_end}}\\n\\n{{lines}}\\n\\n{{signature}}"','"Pay Period: {{period_start}} - {{period_end}}\\n\\n{{lines}}\\n\\n{{signature}}"','text','Body template','Variables: {{payday}} (YYYY/MM/DD), {{payday_us}} (MM/DD/YYYY), {{period_start}}, {{period_end}} (MM/DD/YYYY), {{lines}}, {{signature}}, {{company}}.',80),
('email.line_template','payroll_email','"{{name}} - Hours: {{hours}}, Rate: ${{rate}}"','"{{name}} - Hours: {{hours}}, Rate: ${{rate}}"','string','Employee line template','Variables: {{name}}, {{hours}}, {{rate}}, {{pto}}, {{holiday}}. {{pto}} and {{holiday}} are the PTO and holiday texts below (blank when there are none); a template without them gets them added at the end. Lines are separated by a blank line.',90),
('email.pto_template','payroll_email','", PTO: {{pto_hours}}"','", PTO: {{pto_hours}}"','string','PTO text on employee line','Shown only when the employee took PTO in the period. Variables: {{pto_hours}}.',95),
('email.holiday_template','payroll_email','", Holiday: {{holiday_hours}}"','", Holiday: {{holiday_hours}}"','string','Holiday text on employee line','Shown only when the employee has holiday pay in the period. Variables: {{holiday_hours}}.',96),
('email.signature','payroll_email','"--\\nMaker86 Industries"','"--\\nMaker86 Industries"','text','Signature','',100),

-- SMTP
('smtp.host','smtp','"smtp.resend.com"','"smtp.resend.com"','string','SMTP host','Resend by default (same provider as Stockerly). Any SMTP relay works.',10),
('smtp.port','smtp','465','465','number','SMTP port','465 = implicit TLS, 587 = STARTTLS.',20),
('smtp.user','smtp','"resend"','"resend"','string','SMTP username','"resend" for Resend.',30),
('smtp.password','smtp','""','""','secret','SMTP password / API key','For Resend, paste an API key with sending access. Stored encrypted and never shown again.',40),

-- Auth
('auth.google_domains','auth','["maker86.com"]','["maker86.com"]','json','Google Workspace domains','Accounts from these domains may sign in with Google.',10),
('auth.google_client_id','auth','""','""','string','Google OAuth client ID','From [Google Cloud Console](https://console.cloud.google.com/apis/credentials) > APIs & Services > Credentials. Redirect URI: <App URL>/api/auth/google/callback',12),
('auth.google_client_secret','auth','""','""','secret','Google OAuth client secret','Stored encrypted and never shown again.',14),
('auth.auto_provision','auth','false','false','boolean','Auto-create users on first Google sign-in','Off = an admin must add the user first.',20),
('auth.session_idle_minutes','auth','720','720','number','Session idle timeout (minutes)','',30),
('auth.session_max_days','auth','30','30','number','Session max age (days)','',40),
('auth.invite_expiry_hours','auth','72','72','number','Invite link expiry (hours)','',50),
('auth.max_failed_signins','auth','10','10','number','Failed sign-ins allowed per email','Wrong passwords for one email before password sign-in is blocked for it. Successful sign-ins don''t count.',60),
('auth.max_failed_signins_per_ip','auth','10','10','number','Failed sign-ins allowed per network address','Everyone in the office shares one address. Raise this if people there get blocked.',62),
('auth.failed_signin_window_minutes','auth','15','15','number','Sign-in block length (minutes)','Failures are counted over this window, and a block lasts until it ends.',64),
('auth.max_failed_mfa_codes','auth','10','10','number','Wrong authenticator codes allowed','Wrong codes per person within the same window before code entry is blocked.',66),

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
('pto.skip_holidays','pto','true','true','boolean','Skip holidays in time off requests','Holidays on the employee''s calendar inside a requested range are not counted.',65),
('pto.skip_weekends','pto','true','true','boolean','Skip weekends in time off requests','Saturdays and Sundays inside a requested range are not counted.',60),

-- Holiday pay
('holiday_pay.enabled','holiday_pay','true','true','boolean','Pay holiday hours','Employees get paid hours for each holiday on their calendar, based on how much they usually work.',10),
('holiday_pay.hours_per_credit','holiday_pay','4.5','4.5','number','Average weekly hours','Holiday hours = average weekly hours ÷ the first number × the second, capped below. Example at 4.5 per 1: 30 h a week earns 6.67 h; 40 h a week earns 8.89 h.',20),
('holiday_pay.credit_hours','holiday_pay','1','1','number','Holiday hours earned','Holiday hours earned for each block of average weekly hours.',25),
('holiday_pay.max_hours','holiday_pay','8','8','number','Most holiday hours per holiday','No one gets more than this for a single holiday.',30),
('holiday_pay.lookback_months','holiday_pay','3','3','number','Average over (months)','Weekly average of hours worked over this many months before the holiday. Someone with less history is averaged over the weeks since their first logged day.',40),
('holiday_pay.exempt_salaried','holiday_pay','true','true','boolean','Salaried employees are exempt','On = salaried employees get no holiday hours (their fixed hours already cover the holiday).',50),

-- Test access (super admin issues time-limited links that sign in as a role's test user)
-- Tasks
('tasks.number_prefix','tasks','"T"','"T"','string','Task number prefix','Shown before every task number, e.g. T-42. Letters only, up to 5.',10),
('tasks.max_file_mb','tasks','25','25','number','Largest file (MB)','Biggest file that can be attached to a task, step or comment. At most 150 MB.',20),

('testing.durations_hours','testing','[2,4,8,24,72,168]','[2,4,8,24,72,168]','json','Link durations offered (hours)','Choices when issuing a test link. Each must be between 2 and 168 (7 days).',10),
('testing.default_duration_hours','testing','2','2','number','Default link duration (hours)','Must be one of the durations above.',20),
('testing.max_uses_options','testing','[1,2,3,5,10,25]','[1,2,3,5,10,25]','json','Link use counts offered','How many times one link may be opened (each opening starts a session, e.g. phone and laptop).',30),
('testing.default_max_uses','testing','1','1','number','Default link uses','Must be one of the use counts above.',40),
('testing.redeem_max_failures','testing','20','20','number','Failed link attempts allowed','Per network address. After this many invalid, expired or used-up test links within the block length below, that address can''t open test links until the block length has passed.',50),
('testing.redeem_window_minutes','testing','15','15','number','Test link block length (minutes)','Failed attempts are counted over this window, and a block lasts until it ends.',55),

-- Backups
('schedule.default_start','schedule','"08:00"','"08:00"','time','Usual start time','Filled in when someone adds a work day.',10),
('schedule.default_end','schedule','"17:00"','"17:00"','time','Usual end time','Filled in when someone adds a work day.',20),
('backups.time','backups','"02:00"','"02:00"','time','Nightly backup time','',10),
('backups.retention_days','backups','30','30','number','Backup retention (days)','',20),
('backups.predeploy_keep','backups','20','20','number','Pre-deploy backups to keep','How many pre-deploy database backups to keep. The newest one and any less than 7 days old are always kept.',30),
('uploads.w4_max_mb','uploads','15','15','number','Largest W-4 (MB)','Biggest W-4 photo or PDF an employee or payroll can upload. At most 99 MB.',10),
('uploads.document_max_mb','uploads','25','25','number','Largest pay stub or W-2 PDF (MB)','Biggest pay stub or W-2 PDF payroll can upload at once. At most 99 MB.',20)
ON DUPLICATE KEY UPDATE
  `setting_group` = VALUES(`setting_group`),
  `default_json` = VALUES(`default_json`),
  `value_type` = VALUES(`value_type`),
  `label` = VALUES(`label`),
  `help_text` = VALUES(`help_text`),
  `sort_order` = VALUES(`sort_order`);
