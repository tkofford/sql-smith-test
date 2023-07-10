### sql-smith Test Project
Project with several pytest tests to confirm query building functionality with the sql-smith package. Tests exist for 
several types of queries, mostly nexted queries in the FROM or WHERE clause. These are functionally equivalent to a common 
tables expression (CTE). 

At the time this project was developed, CTEs were not natively supported in sql-smith, well at least the specific CTE syntax 
was not supported. Nested queries could still be built with sql-smith, but it wasn't really very intuitive. Several tests 
exist to show how this can be done successfully. 

Starting with sql-smith version 1.1.0, CTE syntax was officially supported, but that version of sql-smith also upped the 
minimal version of python to 3.10, see the [github project page](https://github.com/fbraem/sql-smith) for more information.

**Note** There are also some commented out remnants of the sqlparse package too
