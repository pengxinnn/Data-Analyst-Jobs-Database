\echo ------------------------- Loading schema: --------------------------
\echo
\i  schema.ddl

\echo -------------------- Cleaning data and loading data: -------------------- 
\echo
\i clean_data.sql
\i load_data.sql

\echo -------------------- Loading the queries-------------------- 
\echo
\i queries.sql

\echo -------------------- Q1--------------------
\echo ------ The percentage of jobs which have the same category for rating and salary ------
\echo
SELECT * FROM Q1;

\echo -------------------- Q2 --------------------
\echo ------ Find city with the max average salary ------
\echo
SELECT * FROM Q2;


\echo -------------------- Q3 --------------------
\echo ------ Summary of each category of headquaters, including the name of the category and its total count. ------
\echo
SELECT * FROM Q3;

