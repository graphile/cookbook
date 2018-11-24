drop schema if exists crud_replacements cascade;
create schema crud_replacements;
set search_path to crud_replacements, public;

create table my_table (
  id serial primary key,
  name text not null,
  description text,
  created_at timestamptz not null default now()
);

-- \i replace-crud.sql