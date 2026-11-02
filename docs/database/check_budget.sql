--This is my budget logic checking function

create or replace function check_budget(p_user_id uuid, p_category_id bigint, p_amount numeric)
returns text
language plpgsql
as $$
declare
  v_limit numeric;
  v_spent numeric;
begin
  select amount_limit into v_limit
  from budgets
  where user_id = p_user_id and category_id = p_category_id
  order by start_date desc limit 1;

  if v_limit is null then
    return 'NO_BUDGET_SET';
  end if;

  select coalesce(sum(amount), 0) into v_spent
  from transactions
  where user_id = p_user_id and category_id = p_category_id and status = 'completed';

  if (v_spent + p_amount) > v_limit then
    return 'BLOCKED';
  else
    return 'ALLOWED';
  end if;
end;
$$;

select check_budget('7c553c07-bde0-4244-b3cf-d8dcc029e4c1', 2, 2500);
-- should return BLOCKED
