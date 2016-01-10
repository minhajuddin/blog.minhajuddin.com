title: pagination for performance intensive queries using nhibernate and sql server
  temporary tables
date: 2011-02-11
---

Pagination is a solved problem. A simple google search shows up *11,200,000* results. Whoa!
The basic implementation is simple. To paginate a result set you run two
almost *identical* queries, one which fetches the count of the result set. The
other which *skips* and *takes* the desired slice from the result set. 

This is fine in most of the cases, But, when your query is very performance intensive, you
just can't afford to run the same query twice. I ran into a similar situation
recently and was searching for a decent approach to solve this problem, and
then, I bumped into the **awesome** [Temporary tables in SQL Server](http://www.sqlteam.com/article/temporary-tables).
Once I knew about them the solution became very simple. It still needs execution
of two queries but it doesn't run the performance intesive query twice. See for
yourself:


~~~sql

-- first query
SELECT pi.*
INTO #TempPerfIntensiveTable
FROM
  .. a 100 JOINS or SPATIAL FUNCTIONS ...;

SELECT COUNT(*)
FROM 
INTO #TempPerfIntensiveTable;

-- end of first query

-- second query
-- :skip and :take are sql parameters for pagination
SELECT pr.* FROM 
(SELECT tp.*, ROW_NUMBER() OVER(ORDER BY tp.Id) AS ROWNUM
  FROM #TempPerfIntensiveTable tp)pr
WHERE pr.ROWNUM BETWEEN :skip AND :take + :skip;
-- end of second query


~~~


These queries need to be executed by calling `session.CreateSQLQuery(query).SetInt32.....` This stuff is not specific to 
NHibernate, I just put it out there to help future searchers :)
