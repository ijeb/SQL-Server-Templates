/* sample demonstrating for xml path for string concat */


CREATE TABLE #EmailTable
(name VARCHAR(100),
 email VARCHAR(250))


INSERT INTO #EmailTable ( name, email )
VALUES  ( 'Bob', 'bob@hotmail.com' ),
		( 'Joe', 'joe@gmail.com'),
		( 'Lisa', 'lisa@outlook.com' ),
		( 'Eric', 'eric@yahoo.com');
GO

SELECT *
FROM #EmailTable;

SELECT STUFF(
(SELECT		'; ' + email
FROM		#EmailTable
FOR XML PATH(''), TYPE).value('.','varchar(max)'), 1, 2, ''
);