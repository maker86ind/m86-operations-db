-- 010: credentials (Resend API key, Google OAuth client secret) are entered in Settings.
-- A 'secret' setting holds an AES-256-GCM blob; the API never returns it.
ALTER TABLE `settings` MODIFY `value_type` enum('string','number','boolean','json','email_list','time','text','secret') NOT NULL DEFAULT 'string';
