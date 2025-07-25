# POC: Editing Dataset - Bad practises

## Description
In this situation there was an application running some kind of analysis. 
Every set of analysis had a set of metadata, starting of with a parent table.
Dependent of the kind of analysis and the objects involved in the analysis there was different child tables involved with different depths.

Some times the metadata needs to be changed. Then the user pulls all the data for one analysis into a parent object (object type) with data from all the related tables in nested collection (object and table types). The user then did changes on the object types. When ready the object was passed to an plsql procedure which deleted all the data, and inserted the new data.

The performance was (as expected) not to great. We suggested to rewrite to use MERGE instead, BUT then I really started to think about it.
Using this design you will always have to reread all the data. Even if only one of the rows in one of the child tables have changed.
This design could never really scale well.

## Oracle End-to-end Metrics
In the tests i set the Oracle end-to-end metrics (MODULE and ACTION).
This way I can - for instance - see how many data blocks was read by each approach:

```sql
select
  action,
  sum(round(s.buffer_gets/ case when s.executions = 0 then 1
                            else s.executions
                       end, 2))                           sum_gets_pr_exe
from gv$sql s
where 1=1
  and module='DEMO'
group by action
order by 2;
```
## Test cases
To prove this I wrote a small POC simulating the different approaches. 
The test includes this 4 senarios:

### Test: INSERT_DEMO
This was the original approach which when updating deleteted all the analysis data, and then re-inserting it.

### Test: UPSERT_DEMO 
The next approach is the UPSERT, which instead of deleting, do a MERGE, and then DELETE all data that no longer is in the pasted object type.

### Test: CHANGE_DEMO
In this approach we introduce a CHANGED_TYPE in the child tables with the following meaning:
- NULL = no change 
- 1    = INSERT
- 2    = UPDATE
- 3    = DELETE
This way the update can actually insert, update or delete only what has changed.

### Test: CALCULATE_DEMO
If we didn't have a CHANGE_TYPE, this could also be calculated when the plsql procedure receives the data. THe disadvantage is that all data has to be read, but the update could then use the approach from the CHANGE_DEMO test.

## Scripts

## Script: 01_create_test_tables.sql

This script creates the tables: big_table, child, child2 and child3.

```sql
sql> @01_create_test_tables.sql
```

## Script: 02_create_test_types.sql

This script create the object and nested table types.

```sql
sql> @02_create_test_types.sql
```

## Script: 03_create_test_package.sql

This script create the specification and body for the DEMO package.

```sql
sql> @03_create_test_package.sql
```

## Script: 04_run_test.sql

This script runs the tests. 
** Note! Before running flush the shared pool (in all instance if doing RAC). **

```sql
sql> @04_run_test.sql
```

## Script: 05_check_sql.sql

This script contains some SQLs to investigate SQLs and buffer gets in the shared pool.

The End. 
