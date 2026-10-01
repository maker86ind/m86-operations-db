-- 016: tasks. Numbered tasks (the number is the id) with priority, several assignees, steps,
-- one level of subtasks, a category, tags, files and threaded comments.
-- checklists / checklist_id arrive with recurring checklists (0.8.3); the columns are here so
-- comments and generated tasks need no later change to these tables.

CREATE TABLE IF NOT EXISTS `task_categories` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `colour` varchar(20) NOT NULL DEFAULT 'slate',
  `position` int NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_task_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tasks` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `parent_task_id` int unsigned DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `notes_md` text DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `priority` enum('urgent','high','normal','low') NOT NULL DEFAULT 'normal',
  `private` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('open','done') NOT NULL DEFAULT 'open',
  `done_by` int unsigned DEFAULT NULL,
  `done_ts` datetime DEFAULT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `checklist_id` int unsigned DEFAULT NULL,
  `occurrence_date` date DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `is_test` tinyint(1) NOT NULL DEFAULT 0,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_tasks_parent` (`parent_task_id`),
  KEY `ix_tasks_status_due` (`is_test`, `status`, `due_date`),
  UNIQUE KEY `uk_tasks_occurrence` (`checklist_id`, `occurrence_date`),
  CONSTRAINT `fk_task_parent` FOREIGN KEY (`parent_task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_task_category` FOREIGN KEY (`category_id`) REFERENCES `task_categories` (`m86_id`),
  CONSTRAINT `fk_task_done_by` FOREIGN KEY (`done_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_task_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `task_assignees` (
  `task_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`, `user_id`),
  KEY `ix_task_assignee_user` (`user_id`),
  CONSTRAINT `fk_ta_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ta_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `task_steps` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int unsigned NOT NULL,
  `position` int NOT NULL DEFAULT 0,
  `text` varchar(500) NOT NULL,
  `done` tinyint(1) NOT NULL DEFAULT 0,
  `done_by` int unsigned DEFAULT NULL,
  `done_ts` datetime DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_task_steps_task` (`task_id`, `position`),
  CONSTRAINT `fk_step_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_step_done_by` FOREIGN KEY (`done_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tags` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  UNIQUE KEY `uk_tag_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `task_tags` (
  `task_id` int unsigned NOT NULL,
  `tag_id` int unsigned NOT NULL,
  PRIMARY KEY (`task_id`, `tag_id`),
  KEY `ix_task_tags_tag` (`tag_id`),
  CONSTRAINT `fk_tt_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`m86_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A comment belongs to a task (or, from 0.8.3, a checklist). parent_id = the top-level comment of its
-- thread (one level); reply_to_id = the exact comment answered, shown as a quote.
CREATE TABLE IF NOT EXISTS `task_comments` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int unsigned DEFAULT NULL,
  `checklist_id` int unsigned DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `reply_to_id` int unsigned DEFAULT NULL,
  `author_user_id` int unsigned DEFAULT NULL,
  `body_md` text NOT NULL,
  `edited_ts` datetime DEFAULT NULL,
  `deleted_ts` datetime DEFAULT NULL,
  `is_test` tinyint(1) NOT NULL DEFAULT 0,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `m86_update_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_comment_task` (`task_id`, `m86_id`),
  KEY `ix_comment_checklist` (`checklist_id`, `m86_id`),
  CONSTRAINT `fk_comment_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `task_comments` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_reply_to` FOREIGN KEY (`reply_to_id`) REFERENCES `task_comments` (`m86_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_comment_author` FOREIGN KEY (`author_user_id`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A file on a task, on one of its steps, or on one of its comments.
CREATE TABLE IF NOT EXISTS `task_files` (
  `m86_id` int unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int unsigned NOT NULL,
  `step_id` int unsigned DEFAULT NULL,
  `comment_id` int unsigned DEFAULT NULL,
  `original_filename` varchar(255) NOT NULL,
  `content_type` varchar(100) NOT NULL,
  `size_bytes` int unsigned NOT NULL,
  `stored_path` varchar(500) NOT NULL,
  `uploaded_by` int unsigned DEFAULT NULL,
  `m86_create_ts` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`m86_id`),
  KEY `ix_task_files_task` (`task_id`),
  CONSTRAINT `fk_tf_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tf_step` FOREIGN KEY (`step_id`) REFERENCES `task_steps` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tf_comment` FOREIGN KEY (`comment_id`) REFERENCES `task_comments` (`m86_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tf_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`m86_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
