select
  sql_id, parsing_schema_name usr,
  round(s.buffer_gets/ case when s.executions = 0 then 1
                            else s.executions
                       end, 2)                            gets_pr_exe,
  round(s.buffer_gets/
     case when s.rows_processed=0 and s.executions=0 then 1
          when s.rows_processed<s.executions         then s.executions  
          else s.rows_processed end, 2)                   gets_pr_row,
  buffer_gets lio, executions nr_exe, rows_processed nr_rows, module, action, plan_hash_value, child_number, sql_text
from gv$sql s
where 1=1
  and module='DEMO'
order by action,4 desc;

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
