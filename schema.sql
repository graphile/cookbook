create schema app_private;
create schema app_public;
create extension if not exists citext;

create function app_private.tg__update_timestamps() returns trigger as $$
begin
  NEW.created_at = (case when TG_OP = 'INSERT' then NOW() else OLD.created_at end);
  NEW.updated_at = (case when TG_OP = 'UPDATE' and OLD.updated_at <= NOW() then OLD.updated_at + interval '1 millisecond' else NOW() end);
  return NEW;
end;
$$ language plpgsql volatile set search_path from current;

comment on function app_private.tg__update_timestamps() is
  E'This trigger should be called on all tables with created_at, updated_at - it ensures that they cannot be manipulated and that updated_at will always be larger than the previous updated_at.';

create function app_public.current_user_id() returns int as $$
  select nullif(current_setting('jwt.claims.user_id', true), '')::int;
$$ language sql stable set search_path from current;
comment on function  app_public.current_user_id() is
  E'@omit\nHandy method to get the current user ID for use in RLS policies, etc; in GraphQL, use `currentUser{id}` instead.';

--------------------------------------------------------------------------------

create table app_public.users (
  id serial primary key,
  username citext not null unique check(username ~ '^[a-zA-Z]([a-zA-Z0-9][_]?)+$'),
  name text,
  avatar_url text check(avatar_url ~ '^https?://[^/]+'),
	is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table app_public.users enable row level security;

--------------------------------------------------------------------------------

create table app_public.forums (
  id serial primary key,
  slug text not null check(length(slug) < 30 and slug ~ '^([a-z0-9]-?)+$') unique,
  name text not null check(length(name) > 0),
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table app_public.forums enable row level security;
create trigger _100_timestamps
  after insert or update on app_public.forums
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.forums is
  E'A subject-based grouping of topics and posts.';
comment on column app_public.forums.slug is
  E'An URL-safe alias for the `Forum`.';
comment on column app_public.forums.name is
  E'The name of the `Forum` (indicates its subject matter).';
comment on column app_public.forums.description is
  E'A brief description of the `Forum` including it''s purpose.';

--------------------------------------------------------------------------------

create table app_public.topics (
  id serial primary key,
  forum_id int not null references app_public.forums on delete cascade,
  author_id int not null default app_public.current_user_id() references app_public.users on delete cascade,
  title text not null check(length(title) > 0),
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table app_public.topics enable row level security;
create trigger _100_timestamps
  after insert or update on app_public.topics
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.topics is
  E'@omit all\nAn individual message thread within a Forum.';
comment on column app_public.topics.title is
  E'The title of the `Topic`.';
comment on column app_public.topics.body is
  E'The body of the `Topic`, which Posts reply to.';

create function app_public.topics_body_summary(
  t app_public.topics,
  max_length int = 30
)
returns text
language sql
stable
set search_path from current
as $$
  select case
    when length(t.body) > max_length
    then left(t.body, max_length - 3) || '...'
    else t.body
    end;
$$;

--------------------------------------------------------------------------------

create table app_public.posts (
  id serial primary key,
  topic_id int not null references app_public.topics on delete cascade,
  author_id int not null default app_public.current_user_id() references app_public.users on delete cascade,
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table app_public.posts enable row level security;
create trigger _100_timestamps
  after insert or update on app_public.posts
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.posts is
  E'@omit all\nAn individual message thread within a Forum.';
comment on column app_public.posts.id is
  E'@omit create,update';
comment on column app_public.posts.topic_id is
  E'@omit update';
comment on column app_public.posts.author_id is
  E'@omit create,update';
comment on column app_public.posts.body is
  E'The body of the `Topic`, which Posts reply to.';
comment on column app_public.posts.created_at is
  E'@omit create,update';
comment on column app_public.posts.updated_at is
  E'@omit create,update';

create function app_public.random_number() returns int
language sql stable
as $$
  select 4;
$$;

comment on function app_public.random_number()
  is 'Chosen by fair dice roll. Guaranteed to be random. XKCD#221';

create function app_public.forums_about_cats() returns setof app_public.forums
language sql stable
as $$
  select * from app_public.forums where slug like 'cat-%';
$$;

--------------------------------------------------------------------------------

insert into app_public.users(username) values ('Benjie'), ('ChadF'), ('BradleyA'), ('SamL'), ('MaxD');

insert into app_public.forums(slug, name, description) values
  ('testimonials', 'Testimonials', 'How do you rate PostGraphile?'),
  ('feedback', 'Feedback', 'How are you finding PostGraphile?'),
  ('cat-life', 'Cat Life', 'A forum all about cats and how fluffy they are and how they completely ignore their owners unless there is food. Or yarn.'),
  ('cat-help', 'Cat Help', 'A forum to seek advice if your cat is becoming troublesome.');


insert into app_public.topics(forum_id, author_id, title, body) values
  (1, 2, 'Thank you!', '500-1500 requests per second on a single server is pretty awesome.'),
  (1, 4, 'PostGraphile is powerful', 'PostGraphile is a powerful, idomatic, and elegant tool.'),
  (1, 5, 'Recently launched', 'At this point, it’s quite hard for me to come back and enjoy working with REST.'),
  (3, 1, 'I love cats!', 'They''re the best!');

insert into app_public.posts(topic_id, author_id, body) values
  (1, 1, 'I''m super pleased with the performance - thanks!'),
  (2, 1, 'Thanks so much!'),
  (3, 1, 'Tell me about it - GraphQL is awesome!'),
  (4, 1, 'Dont you just love cats? Cats cats cats cats cats cats cats cats cats cats cats cats Cats cats cats cats cats cats cats cats cats cats cats cats'),
  (4, 2, 'Yeah cats are really fluffy I enjoy squising their fur they are so goregous and fluffy and squishy and fluffy and gorgeous and squishy and goregous and fluffy and squishy and fluffy and gorgeous and squishy'),
  (4, 3, 'I love it when they completely ignore you until they want something. So much better than dogs am I rite?');
