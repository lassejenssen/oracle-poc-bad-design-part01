set serveroutput on
declare
   l_demo      demo_ot;
   l_childs    child_nt := child_nt();
   l_childs2   child_nt := child_nt();
   l_childs3   child_nt := child_nt();
   l_child_id  number(10);
BEGIN
   -- Step 1: Load data for big_table.id = 100
   SELECT demo_ot(
            bt.id,
            bt.rand,
            bt.sys_dt,
            CAST(
               MULTISET(
                  SELECT c.id, c.rand, c.sys_dt, NULL
                  FROM child c
                  WHERE c.bigt_fk = bt.id
               ) AS child_nt
            ),
            CAST(
               MULTISET(
                  SELECT c.id, c.rand, c.sys_dt, NULL
                  FROM child2 c
                  WHERE c.bigt_fk = bt.id
               ) AS child_nt
            ),
            CAST(
               MULTISET(
                  SELECT c.id, c.rand, c.sys_dt, NULL
                  FROM child3 c
                  WHERE c.bigt_fk = bt.id
               ) AS child_nt
            )
          )
   INTO l_demo
   FROM big_table bt
   WHERE bt.id = 100;

   -- Step 2: Update parent rand to 100
   l_demo.rand := 100;

   -- Step 3: Modify child list
   -- Find first and last child by ID
   DECLARE
      v_min_id NUMBER;
      v_max_id NUMBER;
   BEGIN
      -- Child 1
      SELECT MIN(id), MAX(id) INTO v_min_id, v_max_id
      FROM TABLE(l_demo.list_of_childs);

      FOR i IN 1 .. l_demo.list_of_childs.COUNT LOOP
         IF l_demo.list_of_childs(i).id = v_min_id THEN
            l_demo.list_of_childs(i).change_type := 3; -- delete
         ELSIF l_demo.list_of_childs(i).id = v_max_id THEN
            l_demo.list_of_childs(i).rand := 100;
            l_demo.list_of_childs(i).change_type := 2; -- update
         END IF;
      END LOOP;
      
      -- Child 2
      SELECT MIN(id), MAX(id) INTO v_min_id, v_max_id
      FROM TABLE(l_demo.list_of_childs2);

      FOR i IN 1 .. l_demo.list_of_childs2.COUNT LOOP
         IF l_demo.list_of_childs2(i).id = v_min_id THEN
            l_demo.list_of_childs2(i).change_type := 3; -- delete
         ELSIF l_demo.list_of_childs2(i).id = v_max_id THEN
            l_demo.list_of_childs2(i).rand := 100;
            l_demo.list_of_childs2(i).change_type := 2; -- update
         END IF;
      END LOOP;
      
      -- Child 3
      SELECT MIN(id), MAX(id) INTO v_min_id, v_max_id
      FROM TABLE(l_demo.list_of_childs3);

      FOR i IN 1 .. l_demo.list_of_childs3.COUNT LOOP
         IF l_demo.list_of_childs3(i).id = v_min_id THEN
            l_demo.list_of_childs3(i).change_type := 3; -- delete
         ELSIF l_demo.list_of_childs3(i).id = v_max_id THEN
            l_demo.list_of_childs3(i).rand := 100;
            l_demo.list_of_childs3(i).change_type := 2; -- update
         END IF;
      END LOOP;
   END;

   -- Step 4: Add a new child
   -- Child1
   select max(id)+1 into l_child_id from child;
   --dbms_output.put_line('New id: '|| l_child_id);
   l_demo.list_of_childs.EXTEND;
   l_demo.list_of_childs(l_demo.list_of_childs.count) := child_ot(l_child_id, 100, sysdate, 1);
   
   -- Child2
   select max(id)+1 into l_child_id from child2;
   --dbms_output.put_line('New id: '|| l_child_id);
   l_demo.list_of_childs2.EXTEND;
   l_demo.list_of_childs2(l_demo.list_of_childs2.count) := child_ot(l_child_id, 100, sysdate, 1);
   
   -- Child3
   select max(id)+1 into l_child_id from child3;
   --dbms_output.put_line('New id: '|| l_child_id);
   l_demo.list_of_childs3.EXTEND;
   l_demo.list_of_childs3(l_demo.list_of_childs3.count) := child_ot(l_child_id, 100, sysdate, 1);

   -- Debug (see data - comment out if not wanted)
  -- for rec in (select rownum rn, id, rand, change_type from table(l_demo.list_of_childs)) loop
  --    dbms_output.put_line(rec.rn || ' - ' || rec.id ||' - '|| rec.rand ||' - '||rec.change_type);
  -- end loop;
   
   -- Step 5: Call the demo package procedures
   dbms_output.put_line('----------------------------------------');
   demo.insert_demo(l_demo);
   dbms_output.put_line('----------------------------------------');
   demo.upsert_demo(l_demo);
   dbms_output.put_line('----------------------------------------');
   demo.change_demo(l_demo);
   dbms_output.put_line('----------------------------------------');
   demo.calculate_demo(l_demo);
   dbms_output.put_line('----------------------------------------');

   DBMS_OUTPUT.PUT_LINE('Test case executed successfully.');
END;
/


