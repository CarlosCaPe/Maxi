CREATE PROCEDURE st_GatewayBranchCodeSync
(@idGateway INT,
 @idBranch  INT 
)
AS
/********************************************************************
<Author>Fabián González</Author>
<app>Corporative</app>
<Description>Sincroniza el Branch Code con la tabla de branches</Description>

<ChangeLog>
<log Date="09/03/2017" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN 
DECLARE @GatewayCode  NVARCHAR(max)

--Se obtien el codigo recien actualizado
SELECT @GatewayCode=GatewayBranchCode FROM GatewayBranch WHERE IdGateway = @idGateway AND IdBranch =@idBranch

-- Se actualiza el codigo del branch
UPDATE Branch SET code = @GatewayCode WHERE IdBranch = @idBranch


END 

