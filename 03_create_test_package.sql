CREATE OR REPLACE PACKAGE demo AS
   PROCEDURE insert_demo(data_io IN demo_ot);
   PROCEDURE upsert_demo(data_io IN demo_ot);
   PROCEDURE change_demo(data_io IN demo_ot);
   PROCEDURE calculate_demo(data_io IN demo_ot);
END;
/

CREATE OR REPLACE PACKAGE BODY demo AS

procedure insert_demo(data_io IN demo_ot) as
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   dbms_application_info.set_module(module_name => 'DEMO', action_name => 'INSERT_DEMO');

-- Delete all data
   delete from big_table t where t.id = data_io.id;
   
   dbms_output.put_line('INSERT_DEMO - DELETE big_table: '||sql%rowcount);
 
-- Insert parent data again  
   insert into big_table(id, rand, sys_dt) 
      select data_io.id, data_io.rand, sysdate 
      from dual;
   
   dbms_output.put_line('INSERT_DEMO - INSERT big_table: '||sql%rowcount);

-- Insert child data again (for simplicity I use the CHANGE_TYPE here)   
   insert into child(id, bigt_fk, rand, sys_dt) 
      select l.id, data_io.id, l.rand, sysdate
      from table(data_io.list_of_childs) l
      where nvl(l.change_type,0)<>3;
      
   dbms_output.put_line('INSERT_DEMO - INSERT child    : '||sql%rowcount);
   
-- Insert child2 data again (for simplicity I use the CHANGE_TYPE here)   
   insert into child2(id, bigt_fk, rand, sys_dt) 
      select l.id, data_io.id, l.rand, sysdate
      from table(data_io.list_of_childs2) l
      where nvl(l.change_type,0)<>3;
      
   dbms_output.put_line('INSERT_DEMO - INSERT child2   : '||sql%rowcount);

-- Insert child3 data again (for simplicity I use the CHANGE_TYPE here)   
   insert into child3(id, bigt_fk, rand, sys_dt) 
      select l.id, data_io.id, l.rand, sysdate
      from table(data_io.list_of_childs3) l
      where nvl(l.change_type,0)<>3;
      
   dbms_output.put_line('INSERT_DEMO - INSERT child3   : '||sql%rowcount);
   dbms_application_info.set_module(module_name => '', action_name => '');
   
   --commit;
   rollback;
exception
   when others then
      dbms_output.put_line(SQLCODE ||' - '||SQLERRM);
      rollback;
end;

procedure upsert_demo(data_io IN demo_ot) as
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   dbms_application_info.set_module(module_name => 'DEMO', action_name => 'UPSERT_DEMO');

-- update big_table
   update big_table b2 
      set b2.rand = data_io.rand, 
          b2.sys_dt = sysdate
      where b2.id = data_io.id;
   
   dbms_output.put_line('UPSERT_DEMO - update big_table: '||sql%rowcount);
   
-- *** CHILD1 ***
-- Merge
   merge into child c2
      using (select id, rand from table(data_io.list_of_childs)) o on (c2.id = o.id)
      when matched then
         update set c2.rand = o.rand, c2.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
            
   dbms_output.put_line('UPSERT_DEMO - MERGE  child    : '||sql%rowcount);

-- Clean deleted rows (for similicity I use the CHANGE_TYPE here)
   delete from child c2 
      where c2.bigt_fk = data_io.id
        and id in (
         select id from child where bigt_fk = data_io.id
         minus
         select id from table(data_io.list_of_childs) where nvl(change_type,0) <> 3
      );
   
   dbms_output.put_line('UPSERT_DEMO - DELETE child    : '||sql%rowcount);

-- *** CHILD2 ***
-- Merge
   merge into child2 c2
      using (select id, rand from table(data_io.list_of_childs2)) o on (c2.id = o.id)
      when matched then
         update set c2.rand = o.rand, c2.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
            
   dbms_output.put_line('UPSERT_DEMO - MERGE  child2   : '||sql%rowcount);

-- Clean deleted rows (for similicity I use the CHANGE_TYPE here)
   delete from child2 c2 
      where c2.bigt_fk = data_io.id
        and id in (
         select id from child2 where bigt_fk = data_io.id
         minus
         select id from table(data_io.list_of_childs2) where nvl(change_type,0) <> 3
      );
   
   dbms_output.put_line('UPSERT_DEMO - DELETE child2   : '||sql%rowcount);

-- *** CHILD3 ***
-- Merge
   merge into child3 c2
      using (select id, rand from table(data_io.list_of_childs3)) o on (c2.id = o.id)
      when matched then
         update set c2.rand = o.rand, c2.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
            
   dbms_output.put_line('UPSERT_DEMO - MERGE  child3   : '||sql%rowcount);

-- Clean deleted rows (for similicity I use the CHANGE_TYPE here)
   delete from child3 c2 
      where c2.bigt_fk = data_io.id
        and id in (
         select id from child3 where bigt_fk = data_io.id
         minus
         select id from table(data_io.list_of_childs3) where nvl(change_type,0) <> 3
      );
   
   dbms_output.put_line('UPSERT_DEMO - DELETE child3   : '||sql%rowcount);
   
   dbms_application_info.set_module(module_name => '', action_name => '');
   
   --commit;
   rollback;
exception
   when others then
      dbms_output.put_line(SQLCODE ||' - '||SQLERRM);
      rollback;   
end;

procedure change_demo(data_io IN demo_ot) as
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   dbms_application_info.set_module(module_name => 'DEMO', action_name => 'CHANGE_DEMO');

-- update big_table
   update big_table b3
      set b3.rand = data_io.rand, 
          b3.sys_dt = sysdate
      where b3.id = data_io.id;
   
   dbms_output.put_line('CHANGE_DEMO - UPDATE big_table: '||sql%rowcount);

-- *** Child 1 ***
-- update 
   merge into child c3
      using (select id, rand from table(data_io.list_of_childs) 
             where change_type in (1,2)) o on (c3.id = o.id)
      when matched then
         update set c3.rand = o.rand, c3.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CHANGE_DEMO - MERGE  child    : '||sql%rowcount);

-- delete from child
   delete from child c3
      where c3.id in (
         select o.id from table(data_io.list_of_childs) o
         where change_type = 3 
      );
      
   dbms_output.put_line('CHANGE_DEMO - DELETE child    : '||sql%rowcount);

-- *** Child 2 ***
-- update 
   merge into child2 c3
      using (select id, rand from table(data_io.list_of_childs2) 
             where change_type in (1,2)) o on (c3.id = o.id)
      when matched then
         update set c3.rand = o.rand, c3.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CHANGE_DEMO - MERGE  child2   : '||sql%rowcount);

-- delete from child2
   delete from child2 c3
      where c3.id in (
         select o.id from table(data_io.list_of_childs2) o
         where change_type = 3 
      );
      
   dbms_output.put_line('CHANGE_DEMO - DELETE child2   : '||sql%rowcount);
   
-- *** Child 3 ***
-- update 
   merge into child3 c3
      using (select id, rand from table(data_io.list_of_childs3) 
             where change_type in (1,2)) o on (c3.id = o.id)
      when matched then
         update set c3.rand = o.rand, c3.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CHANGE_DEMO - MERGE  child3   : '||sql%rowcount);

-- delete from child3
   delete from child3 c3
      where c3.id in (
         select o.id from table(data_io.list_of_childs3) o
         where change_type = 3 
      );
      
   dbms_output.put_line('CHANGE_DEMO - DELETE child3   : '||sql%rowcount);
   
   dbms_application_info.set_module(module_name => '', action_name => '');
   
   --commit;
   rollback;
exception
   when others then
      dbms_output.put_line(SQLCODE ||' - '||SQLERRM);
      rollback;  
end;

procedure calculate_demo(data_io IN demo_ot) as
   l_new_childs  child_nt := child_nt();
   l_new_childs2 child_nt := child_nt();
   l_new_childs3 child_nt := child_nt();
   
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   dbms_application_info.set_module(module_name => 'DEMO', action_name => 'CALCUL_DEMO');

-- update big_table
   update big_table b4
      set b4.rand = data_io.rand, 
          b4.sys_dt = sysdate
      where b4.id = data_io.id;
   
   dbms_output.put_line('CALCUL_DEMO - UPDATE big_table: '||sql%rowcount);

-- Calculate changes
   SELECT 
      cast (
         multiset (
            SELECT child_ot(nvl(c.id,n.id), nvl(c.rand,n.rand), sysdate, 
                         case when c.id is null then 1
                              when n.change_type=3 then 3
                              when c.rand <> n.rand then 2
                              else null 
                         end) 
            FROM (select id, rand from child WHERE bigt_fk = data_io.id) c FULL OUTER JOIN table(data_io.list_of_childs) n ON (c.id = n.id)
         ) as child_nt
      ),
      cast (
         multiset (
            SELECT child_ot(nvl(c.id,n.id), nvl(c.rand,n.rand), sysdate, 
                         case when c.id is null then 1
                              when n.change_type=3 then 3
                              when c.rand <> n.rand then 2
                              else null 
                         end) 
            FROM (select id, rand from child2 WHERE bigt_fk = data_io.id) c FULL OUTER JOIN table(data_io.list_of_childs2) n ON (c.id = n.id)
         ) as child_nt
      ),
      cast (
         multiset (
            SELECT child_ot(nvl(c.id,n.id), nvl(c.rand,n.rand), sysdate, 
                         case when c.id is null then 1
                              when n.change_type=3 then 3
                              when c.rand <> n.rand then 2
                              else null 
                         end) 
            FROM (select id, rand from child3 WHERE bigt_fk = data_io.id) c FULL OUTER JOIN table(data_io.list_of_childs3) n ON (c.id = n.id)
         ) as child_nt
      )
      into l_new_childs, l_new_childs2, l_new_childs3
   FROM dual;
   
-- Debug (see data - comment out if not wanted)
 --  for rec in (select rownum rn, id, rand, change_type from table(l_new_childs)) loop
 --     dbms_output.put_line(rec.rn || ' - ' || rec.id ||' - '|| rec.rand ||' - '||rec.change_type);
 --  end loop;

-- *** Child 1 ***
-- delete from child
   delete from child c4
      where c4.id in (
         select o.id from table(l_new_childs) o
         where o.change_type = 3 
      );
      
   dbms_output.put_line('CALCUL_DEMO - DELETE child    : '||sql%rowcount);
      
-- update 
   merge into child c4
      using (select id, rand from table(l_new_childs) 
             where change_type in (1,2)) o on (c4.id = o.id)
      when matched then
         update set c4.rand = o.rand, c4.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CALCUL_DEMO - MERGE  child    : '||sql%rowcount);

-- *** Child 2 ***
-- delete from child2
   delete from child2 c4
      where c4.id in (
         select o.id from table(l_new_childs2) o
         where o.change_type = 3 
      );
      
   dbms_output.put_line('CALCUL_DEMO - DELETE child2   : '||sql%rowcount);
      
-- update 
   merge into child2 c4
      using (select id, rand from table(l_new_childs2) 
             where change_type in (1,2)) o on (c4.id = o.id)
      when matched then
         update set c4.rand = o.rand, c4.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CALCUL_DEMO - MERGE  child2   : '||sql%rowcount);

-- *** Child 3 ***
-- delete from child3
   delete from child3 c4
      where c4.id in (
         select o.id from table(l_new_childs3) o
         where o.change_type = 3 
      );
      
   dbms_output.put_line('CALCUL_DEMO - DELETE child3   : '||sql%rowcount);
      
-- update 
   merge into child3 c4
      using (select id, rand from table(l_new_childs3) 
             where change_type in (1,2)) o on (c4.id = o.id)
      when matched then
         update set c4.rand = o.rand, c4.sys_dt = sysdate
      when not matched then 
         insert (id, bigt_fk, rand, sys_dt)
            values (o.id, data_io.id, o.rand, sysdate);
   
   dbms_output.put_line('CALCUL_DEMO - MERGE  child3   : '||sql%rowcount);
   
   dbms_application_info.set_module(module_name => '', action_name => '');
   
   --commit;
   rollback;
exception
   when others then
      dbms_output.put_line(SQLCODE ||' - '||SQLERRM);
      rollback;   
end;

END;
/

