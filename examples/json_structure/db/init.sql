drop schema if exists json_structure cascade;
create schema json_structure;
set search_path to json_structure, public;

create table people (
  id serial primary key,
  name text not null,
  bio json not null default '{}'::json,
  created_at timestamptz not null default now()
);

comment on column people.bio is E'@overrideType MyCustomType';