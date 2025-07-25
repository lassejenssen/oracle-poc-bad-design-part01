drop type demo_ot;
drop type child_nt;
drop type child_ot;

create or replace type child_ot force as object(
    id               number(10),
    rand             number(10),
    sys_dt           date,
    change_type      number(1)    -- null = not changed, 1 = inserted, 2 = updated, 3 = deleted
);
/

create or replace type child_nt as table of child_ot;
/

create or replace type demo_ot FORCE AS OBJECT(
    id               NUMBER(10),
    rand             number(10),
    sys_dt           date,
    list_of_childs   child_nt,
    list_of_childs2  child_nt,
    list_of_childs3  child_nt
);
/

