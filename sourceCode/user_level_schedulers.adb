with Text_IO; use Text_IO;

package body user_level_schedulers is

   -- Rate monotonic scheduling
   --
   procedure rate_monotonic_schedule (duration_in_time_unit : Integer) is
      a_tcb           : tcb;
      no_ready_task   : Boolean;
      elected_task    : tcb;
      smallest_period : Integer;
   begin

      -- Loop on tcbs, and select tasks which are ready
      -- and which have smallest periods
      --
      loop

        -- Find the next task to run
        --
         no_ready_task   := True;
         smallest_period := Integer'Last;
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_ready) then
               no_ready_task := False;
               if a_tcb.period < smallest_period then
                  smallest_period := a_tcb.period;
                  elected_task    := a_tcb;
               end if;
            end if;
         end loop;

         -- Run the task
         --
         if not no_ready_task then
            elected_task.the_task.wait_for_processor;
            elected_task.the_task.release_processor;
         else
            Put_Line
              ("No task to run at time " &
               Integer'Image (user_level_scheduler.get_current_time));
         end if;

         -- Go to the next unit of time
         --
         user_level_scheduler.next_time;
         exit when user_level_scheduler.get_current_time >
                   duration_in_time_unit;

         -- release periodic tasks
         --
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_pended) then
               if user_level_scheduler.get_current_time mod a_tcb.period =
                  0
               then
                  Put_Line
                    ("Task" &
                     Integer'Image (i) &
                     " is released at time " &
                     Integer'Image (user_level_scheduler.get_current_time));
                  user_level_scheduler.set_task_status (i, task_ready);
               end if;
            end if;
         end loop;

      end loop;

   end rate_monotonic_schedule;

   -- EDF scheduling
   --
   procedure edf_schedule (duration_in_time_unit : Integer) is
      a_tcb           : tcb;
      no_ready_task   : Boolean;
      elected_task    : tcb;
      smallest_deadline : Integer;
   begin

      -- Loop on tcbs, and select tasks which are ready
      -- and which have smallest periods
      --
      loop

        -- Find the next task to run
        --
         no_ready_task   := True;
         smallest_deadline := Integer'Last;
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_ready) then
               no_ready_task := False;
               -- Deadline calcul
               if (a_tcb.period - (user_level_scheduler.get_current_time mod a_tcb.period))< smallest_deadline then
                  smallest_deadline := a_tcb.period;
                  elected_task    := a_tcb;
               end if;
            end if;
         end loop;

         -- Run the task
         --
         if not no_ready_task then
            elected_task.the_task.wait_for_processor;
            elected_task.the_task.release_processor;
         else
            Put_Line
              ("No task to run at time " &
               Integer'Image (user_level_scheduler.get_current_time));
         end if;

         -- Go to the next unit of time
         --
         user_level_scheduler.next_time;
         exit when user_level_scheduler.get_current_time >
                   duration_in_time_unit;

         -- release periodic tasks
         --
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_pended) then
               if user_level_scheduler.get_current_time mod a_tcb.period =
                  0
               then
                  Put_Line
                    ("Task" &
                     Integer'Image (i) &
                     " is released at time " &
                     Integer'Image (user_level_scheduler.get_current_time));
                  user_level_scheduler.set_task_status (i, task_ready);
               end if;
            end if;
         end loop;

      end loop;

   end edf_schedule;


   -- MUF scheduling
   --
   procedure muf_schedule (duration_in_time_unit : Integer) is
      a_tcb           : tcb;
      no_ready_task   : Boolean;
      elected_task    : tcb;
      highest_criticality : Integer;
      smallest_laxity : Integer;
      highest_user_priority : Integer;
      id_last_chef : Integer;
   begin

      -- Loop on tcbs, and select tasks which are ready
      -- and which have smallest periods
      --
      loop

        -- Find the next task to run
        --
         no_ready_task   := True;
         smallest_laxity := Integer'Last;
         highest_criticality := 0;
         highest_user_priority := 0;
         id_last_chef := 0;

         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);

            

            --Laxity gestion
            if(a_tcb.capacity_left = 0) then
            	a_tcb.laxity := Integer'Last;
	            --Put_Line("    TASK DONE");
	        else
		        --Laxity calcul
	            --Next deadline - current time - capacity left
	            a_tcb.laxity := (user_level_scheduler.get_current_time + a_tcb.period - (user_level_scheduler.get_current_time mod a_tcb.period)) 
	                             - user_level_scheduler.get_current_time - a_tcb.capacity_left;
	           
	            --Put ("    Laxity of task " & Integer'Image(i) & " =" & Integer'Image(a_tcb.laxity)); 
	            --Printing calcul
	            --Put (" ->      (" & Integer'Image(user_level_scheduler.get_current_time) & " +" & Integer'Image(a_tcb.period) & " - (" & Integer'Image(user_level_scheduler.get_current_time) & " %" & Integer'Image(a_tcb.period) & " ) -" & Integer'Image(user_level_scheduler.get_current_time) & " -" & Integer'Image(a_tcb.capacity_left));
	        	--New_Line;
	        end if;

               --Picking the most critical task   

            if (a_tcb.status = task_ready) then
               no_ready_task := False;

               if(a_tcb.criticality > highest_criticality) then
                  --Put_Line ("    Task " & Integer'Image(i) & " took advantage over Task " & Integer'Image(id_last_chef) & 
                  --          " with a new criticality of " & Integer'Image(a_tcb.criticality) & " above old " & Integer'Image(highest_criticality));
                 
                  highest_criticality := a_tcb.criticality;
                  smallest_laxity := a_tcb.laxity;
                  highest_user_priority := a_tcb.user_priority;
                  id_last_chef := i;
                  elected_task := a_tcb;
               end if;

               --If equal criticality
               if(a_tcb.criticality = highest_criticality) then
                  if (a_tcb.laxity < smallest_laxity) then
                     --Put_Line ("    Task " & Integer'Image(i) & " took advantage over Task " & Integer'Image(id_last_chef) & 
                     --          " with a new laxity of " & Integer'Image(a_tcb.laxity) & " above old " & Integer'Image(smallest_laxity) & " (left " & Integer'Image(a_tcb.capacity_left) & ")");

                     smallest_laxity := a_tcb.laxity;
                     highest_user_priority := a_tcb.user_priority;
                     id_last_chef := i;
                     elected_task := a_tcb;
                  end if;

                  --If equal criticality and laxity
                  if(a_tcb.laxity = smallest_laxity) then
                     if (a_tcb.user_priority > highest_user_priority) then
                        --Put_Line ("    Task " & Integer'Image(i) & " took advantage over Task " & Integer'Image(id_last_chef) & 
                        --          " with a new user priority of " & Integer'Image(a_tcb.user_priority) & " above old " & Integer'Image(highest_user_priority));

                        highest_user_priority := a_tcb.user_priority;
                        id_last_chef := i;
                        elected_task := a_tcb;
                     end if;

                  end if; -- If equal criticality and laxity
               end if; -- If equal criticality
            end if; -- If task is ready 

         end loop;

         -- Run the task
         --

         if not no_ready_task then
            --Put_Line("    ELECTED TASK: " & Integer'Image(id_last_chef) &  ", remaining capa : " & Integer'Image(elected_task.capacity_left - 1) & ")");
            elected_task.the_task.wait_for_processor;
            elected_task.the_task.release_processor;
            user_level_scheduler.decrease_remaining_capacity(id_last_chef);
         else
            Put_Line
              ("No task to run at time " &
               Integer'Image (user_level_scheduler.get_current_time));
         end if;

         -- Go to the next unit of time
         --
         user_level_scheduler.next_time;
         exit when user_level_scheduler.get_current_time >
                   duration_in_time_unit;

         -- release periodic tasks
         --
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_pended) then
               if user_level_scheduler.get_current_time mod a_tcb.period =
                  0
               then
                  Put_Line
                    ("Task" &
                     Integer'Image (i) &
                     " is released at time " &
                     Integer'Image (user_level_scheduler.get_current_time));
                
                    --Resert capacity
	            	if(a_tcb.capacity_left = 0) then
	               		user_level_scheduler.reset_remaining_capacity(i);
	            	end if;

                  user_level_scheduler.set_task_status (i, task_ready);
               end if;
            end if;
         end loop;

      end loop;

   end muf_schedule;

   procedure abort_tasks is
      a_tcb : tcb;
   begin
      if (user_level_scheduler.get_number_of_task = 0) then
         raise Constraint_Error;
      end if;

      for i in 1 .. user_level_scheduler.get_number_of_task loop
         a_tcb := user_level_scheduler.get_tcb (i);
         abort a_tcb.the_task.all;
      end loop;
   end abort_tasks;

   protected body user_level_scheduler is

      procedure set_task_status (id : Integer; s : task_status) is
      begin
         tcbs (id).status := s;
      end set_task_status;

      --Functions to manipulate the priorities
      procedure set_task_criticality (id : Integer; s : Integer) is
      begin
         tcbs (id).criticality := s;
      end set_task_criticality;

      procedure set_task_user_priority (id : Integer; s : Integer) is
      begin
         tcbs (id).user_priority := s;
      end set_task_user_priority;

      procedure decrease_remaining_capacity (id : Integer) is
      begin
         tcbs (id).capacity_left := tcbs (id).capacity_left - 1;
      end decrease_remaining_capacity;

      procedure reset_remaining_capacity (id : Integer) is
      begin
         tcbs (id).capacity_left := tcbs (id).capacity;
      end reset_remaining_capacity;

      function get_tcb (id : Integer) return tcb is
      begin
         return tcbs (id);
      end get_tcb;

      procedure new_user_level_task
        (id         : in out Integer;
         period     : in Integer;
         capacity   : in Integer;
         subprogram : in run_subprogram)
      is
         a_tcb : tcb;
      begin
         if (number_of_task + 1 > max_user_level_task) then
            raise Constraint_Error;
         end if;

         number_of_task        := number_of_task + 1;
         a_tcb.period          := period;
         a_tcb.capacity        := capacity;
         a_tcb.capacity_left   := capacity;
         --Criticality is 'not critical' by default
         a_tcb.criticality     := 0;
         a_tcb.user_priority   := 0;
         a_tcb.status          := task_ready;
         a_tcb.the_task        :=
           new user_level_task (number_of_task, subprogram);
         tcbs (number_of_task) := a_tcb;
         id                    := number_of_task;
      end new_user_level_task;

      function get_number_of_task return Integer is
      begin
         return number_of_task;
      end get_number_of_task;

      function get_current_time return Integer is
      begin
         return current_time;
      end get_current_time;

      procedure next_time is
      begin
         current_time := current_time + 1;
      end next_time;

   end user_level_scheduler;

end user_level_schedulers;
