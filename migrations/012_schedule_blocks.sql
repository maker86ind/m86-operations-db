-- 012: a planned day can hold several blocks of hours (e.g. 8–12 at one location, 13–17 at another).
-- All rows for an employee and date together make up that day.
ALTER TABLE `work_schedule` ADD KEY `ix_ws_employee_date` (`employee_id`,`work_date`), DROP INDEX `uk_work_schedule_day`;
