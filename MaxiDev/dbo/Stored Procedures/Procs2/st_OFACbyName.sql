
CREATE PROCEDURE st_OFACbyName(@FirstName VARCHAR(4000),@FirstLastName VARCHAR(4000),@SecondLastname VARCHAR(4000)='')
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app>SQL Server </app>
<Description> Busca Ofac Test 1 </Description>

<ChangeLog>
<log Date="01/06/2017" Author="fgonzalez"> Creacion  </log>

</ChangeLog>

*********************************************************************/
BEGIN 

DECLARE @filter VARCHAR(8000)


SET @filter='"'+isnull(@FirstName,'')+'*" OR "'+isnull(@FirstLastName,'')+'*"'+CASE WHEN len(isnull(@SecondLastname,'')) > 0 THEN ' OR "'+isnull(@SecondLastname,'')+'*"' ELSE '' END 


SELECT OfacName= SDN_name  from OFAC_SDN (nolock)
WHERE CONTAINS(SDN_name,@filter)
union all
select alt_name text from OFAC_ALT (nolock)
WHERE CONTAINS(ALT_NAME,@filter)

END 

