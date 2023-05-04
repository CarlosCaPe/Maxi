CREATE PROCEDURE sp_SchemaTables (@schema VARCHAR(200))
AS 
/********************************************************************
<Author> Fabian Gonzalez</Author>
<app>SQL </app>
<Description>Permite buscar tablas dentro de los esquemas</Description>

<ChangeLog>
<log Date="07/07/2017" Author="fgonzalez">Creacion</log>

</ChangeLog>

*********************************************************************/
BEGIN 


DECLARE @tablename VARCHAR(100) =''
IF (charindex('.',@schema,0) > 0) BEGIN 
set  @tablename = ltrim(rtrim(substring(@schema,charindex('.',@schema,0)+1,100)))
SET  @schema = substring(@schema,0,charindex('.',@schema,0))
END 


SELECT [Table]= TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
AND TABLE_SCHEMA LIKE '%'+@schema+'%' AND TABLE_NAME LIKE '%'+@tablename+'%'

END 

