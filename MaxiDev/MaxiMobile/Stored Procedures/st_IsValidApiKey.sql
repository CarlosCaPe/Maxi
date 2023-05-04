/********************************************************************
<Author> Mhinojo </Author>
<app> WebApi </app>
<Description> Sp que valida si una key o token es valido aun </Description>

<ChangeLog>
<log Date="05/06/2017" Author="Mhinojo">Creation</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [MaxiMobile].[st_IsValidApiKey]
	@apikey NVARCHAR(50),
	@isvalid BIT OUT,
	@messageout NVARCHAR(500) OUT
AS
DECLARE @currentdate DATETIME= GETDATE()

SET @messageout = ''

SELECT @isvalid=isvalid FROM [MaxiMobile].[ApiKey] WHERE apikey=@apikey and isvalid=1 and ISNULL(expire,@currentdate)>=@currentdate

IF ISNULL(@isvalid,0)=0
	SET @isvalid = 'La clave secreta del cliente no es valida'

