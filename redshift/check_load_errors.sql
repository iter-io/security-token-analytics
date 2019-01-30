
select
  starttime,
  query,
  filename as filename,
  line_number as line,
  colname as column,
  type,
  position as pos,
  raw_line as line_text,
  raw_field_value as field_text,
  err_reason as reason
from stl_load_errors
order by starttime desc
limit 200;
