with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

with my_subprograms; use my_subprograms;

procedure example is

begin

   --============RM============
   -- Creation des taches
   --user_level_scheduler.new_user_level_task (id1, 5, 1, T1'Access);
   --user_level_scheduler.new_user_level_task (id2, 10, 3, T2'Access);
   --user_level_scheduler.new_user_level_task (id3, 30, 8, T3'Access);

   -- ordonnancement selon RM
   --rate_monotonic_schedule (29);
   --abort_tasks;

   --============EDF===========
   -- Creation des taches
   --user_level_scheduler.new_user_level_task (id1, 12, 5, T1'Access);
   --user_level_scheduler.new_user_level_task (id2, 6, 2, T2'Access);
   --user_level_scheduler.new_user_level_task (id3, 24, 5, T3'Access);

   -- ordonnancement selon EDF
   --edf_schedule (23);
   --abort_tasks;

   --============MUF===========
   -- Creation des taches
   user_level_scheduler.new_user_level_task (id1, 6, 2, T1'Access);
   user_level_scheduler.new_user_level_task (id2, 10, 4, T2'Access);
   user_level_scheduler.new_user_level_task (id3, 12, 3, T3'Access);
   user_level_scheduler.new_user_level_task (id4, 15, 4, T4'Access);

   -- Specification des priorités
   user_level_scheduler.set_task_criticality (id1, 1);
   user_level_scheduler.set_task_criticality (id2, 1);
   user_level_scheduler.set_task_criticality (id3, 1);
   user_level_scheduler.set_task_criticality (id4, 0);

   -- ordonnancement selon MUF
   muf_schedule (24);
   abort_tasks;

end example;
