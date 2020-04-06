#!/usr/bin/env bash
set -e

psql postgres:///postgres <<HERE
DROP DATABASE IF EXISTS graphile_cookbook;
DROP ROLE IF EXISTS graphile_cookbook_visitor;
CREATE ROLE graphile_cookbook_visitor;
CREATE DATABASE graphile_cookbook;
HERE
psql -X1 graphile_cookbook -f schema.sql
