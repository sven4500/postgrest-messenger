-- https://stackoverflow.com/questions/3327312/how-can-i-drop-all-the-tables-in-a-postgresql-database
DROP SCHEMA PUBLIC CASCADE;

CREATE SCHEMA PUBLIC;

GRANT ALL ON SCHEMA PUBLIC TO POSTGRES;

GRANT ALL ON SCHEMA PUBLIC TO PUBLIC;
