drop table child purge;
drop table child2 purge;
drop table child3 purge;
drop table big_table purge;

create table big_table (
   id          number(10) constraint big_table_pk primary key,
   rand        number(10),
   sys_dt      date
);

create table child (
   id          number(10) constraint child_pk primary key,
   bigt_fk     number(10),
   rand        number(10),
   sys_dt      date,
   constraint bigt_child_fk foreign key (bigt_fk) references big_table(id) ON DELETE CASCADE
);

create table child2 (
   id          number(10) constraint child2_pk primary key,
   bigt_fk     number(10),
   rand        number(10),
   sys_dt      date,
   constraint bigt_child2_fk foreign key (bigt_fk) references big_table(id) ON DELETE CASCADE
);

create table child3 (
   id          number(10) constraint child3_pk primary key,
   bigt_fk     number(10),
   rand        number(10),
   sys_dt      date,
   constraint bigt_child3_fk foreign key (bigt_fk) references big_table(id) ON DELETE CASCADE
);

create index child_idx01 on child(bigt_fk);
create index child2_idx01 on child2(bigt_fk);
create index child3_idx01 on child3(bigt_fk);

INSERT INTO big_table (id, rand, sys_dt)
SELECT
   ROWNUM AS id,
   TRUNC(DBMS_RANDOM.VALUE(1, 101)) AS rand, -- random integer between 1 and 100
   SYSDATE AS sys_dt
FROM
   dual
CONNECT BY LEVEL <= 10000;


-- Insert into child 1
INSERT INTO child (id, bigt_fk, rand, sys_dt)
SELECT
   ROWNUM AS id,
   bt.id AS bigt_fk,
   TRUNC(DBMS_RANDOM.VALUE(1, 101)) AS rand,
   SYSDATE AS sys_dt
FROM (
   SELECT bt.id, LEVEL AS child_num
   FROM big_table bt
   CONNECT BY LEVEL <= TRUNC(DBMS_RANDOM.VALUE(100, 1001))
   AND PRIOR dbms_random.value IS NOT NULL
   AND PRIOR bt.id = bt.id
) bt;

-- Insert into child 2
INSERT INTO child2 (id, bigt_fk, rand, sys_dt)
SELECT
   ROWNUM AS id,
   bt.id AS bigt_fk,
   TRUNC(DBMS_RANDOM.VALUE(1, 101)) AS rand,
   SYSDATE AS sys_dt
FROM (
   SELECT bt.id, LEVEL AS child_num
   FROM big_table bt
   CONNECT BY LEVEL <= TRUNC(DBMS_RANDOM.VALUE(100, 1001))
   AND PRIOR dbms_random.value IS NOT NULL
   AND PRIOR bt.id = bt.id
) bt;

-- Insert into child 3
INSERT INTO child3 (id, bigt_fk, rand, sys_dt)
SELECT
   ROWNUM AS id,
   bt.id AS bigt_fk,
   TRUNC(DBMS_RANDOM.VALUE(1, 101)) AS rand,
   SYSDATE AS sys_dt
FROM (
   SELECT bt.id, LEVEL AS child_num
   FROM big_table bt
   CONNECT BY LEVEL <= TRUNC(DBMS_RANDOM.VALUE(300, 1001))
   AND PRIOR dbms_random.value IS NOT NULL
   AND PRIOR bt.id = bt.id
) bt;

commit;

-- Counts

VARIABLE my_id NUMBER;
EXEC :my_id := 100;

select count(*) from big_table where id = :my_id;
select count(*) from child where bigt_fk = :my_id;
select count(*) from child2 where bigt_fk = :my_id;
select count(*) from child3 where bigt_fk = :my_id;

/*
select * from big_table where id = :my_id;
select * from child where bigt_fk = :my_id;
select * from child2 where bigt_fk = :my_id;
select * from child3 where bigt_fk = :my_id;



