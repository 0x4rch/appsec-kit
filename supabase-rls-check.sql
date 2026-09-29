-- supabase-rls-check.sql -- which tables have row level security off.
--
-- Run it in the Supabase SQL editor. Every row it returns is a table that the
-- public anon key can read and write in full, because without RLS there is no
-- policy to say otherwise. For each one, decide who should see which rows,
-- then:  alter table public.<name> enable row level security;  and add a policy.
--
-- A table with RLS ON but NO policies is locked to everyone except the
-- service role, which is safe and sometimes what you want. The second query
-- lists those so you are not surprised by an app that suddenly cannot read.

select
  n.nspname  as schema,
  c.relname  as table_name,
  'RLS OFF: anon key has full access' as status
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
  and n.nspname = 'public'
  and not c.relrowsecurity
order by c.relname;

-- Tables with RLS on and no policies at all: locked down completely.
select
  c.relname as table_name,
  'RLS ON, no policies: only the service role can read' as status
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
left join pg_policies p on p.schemaname = n.nspname and p.tablename = c.relname
where c.relkind = 'r'
  and n.nspname = 'public'
  and c.relrowsecurity
group by c.relname
having count(p.policyname) = 0
order by c.relname;

-- The policies you do have, in one list, so you can read them aloud.
select tablename, policyname, cmd, roles, qual as using_expression, with_check
from pg_policies
where schemaname = 'public'
order by tablename, cmd;
