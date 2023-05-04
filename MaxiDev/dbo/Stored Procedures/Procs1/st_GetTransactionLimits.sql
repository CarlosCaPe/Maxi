
CREATE PROCEDURE [dbo].[st_GetTransactionLimits](
@ActorType INT,
@idPayer INT = NULL , 
@IdAgent INT = NULL, 
@idGAteway INT = NULL , 
@idState INT = NULL, 
@idStateDestination INT = NULL
)
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app>Agent </app>
<Description> Obtiene Limite Maximo Diario de Cliente o Beneficiario </Description>

<ChangeLog>
<log Date="24/08/2017" Author="Fgonzalez"> Creacion </log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>

*********************************************************************/
SET NOCOUNT ON;

BEGIN 
DECLARE @actor VARCHAR(20) 

IF @ActorType=1 
SET @actor='Customer'
ELSE 
SET @actor='Beneficiary'

SET @idPayer = nullif(@idPayer,0)
SET @IdAgent = nullif(@IdAgent,0)
SET @idGAteway = nullif(@idGAteway,0)
SET @idState = nullif(@idState,0)
SET @idStateDestination = nullif(@idStateDestination,0)


SELECT Amount=Convert(VARCHAR,Amount,100)+' '+c.CurrencyCode 
FROM KYCRule k with(nolock)
JOIN CountryCurrency cc with(nolock) 
ON cc.IdCountryCurrency=k.IdCountryCurrency
JOIN Currency c with(nolock) 
ON c.IdCurrency = cc.IdCurrency
WHERE Actor =@actor 
AND Symbol ='>'
AND IdGenericStatus =1 
AND TimeInDays = 1
AND (idAgent = @IdAgent OR IdAgent IS NULL)
AND (IdPayer = @idPayer OR IdPayer IS NULL)
AND (IdGateway =@idGAteway OR IdGateway IS NULL)
AND (IdState = @idState OR IdState IS NULL)
AND (IdStateDestination = @idStateDestination OR IdStateDestination IS NULL)
ORDER BY idAgent DESC , IdGateway DESC , IdPayer DESC, IdState DESC  ,IdStateDestination DESC , Amount DESC 

END 

