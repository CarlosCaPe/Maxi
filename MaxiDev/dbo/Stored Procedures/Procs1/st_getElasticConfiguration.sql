CREATE PROCEDURE [dbo].[st_getElasticConfiguration]
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Agent </app>
<Description> Obtiene credenciales para consulta de elastic Search </Description>

<ChangeLog>
<log Date="11/10/2017" Author="Fgonzalez">Creacion</log>
<log Date="18/01/2018" Author="azavala">Se agrego index de locaciones e index de customers</log>
<log Date="18/01/2018" Author="azavala">Se agrego index de agents</log>
</ChangeLog>

*********************************************************************/
BEGIN

SELECT 
MaxResult = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='MaxElasticResult'),
[Server] = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='URLServerElastic'),
UserName = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='UserServerElastic'),
[Password] = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='PaswServerElastic'),
IndexLocation = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='IndexLocation'),
IndexCustomer = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='IndexCustomer'),
IndexAgents = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='IndexAgents'),
ForceBySQL = (SELECT Value FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='ForceBySQL')

END 


