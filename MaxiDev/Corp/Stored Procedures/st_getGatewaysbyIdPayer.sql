CREATE PROCEDURE [Corp].[st_getGatewaysbyIdPayer] (@idPayer INT)
/********************************************************************
<Author> Fgonzalez </Author>
<app> Corporate </app>
<Description> Obtiene los diferente gateway configurados para un Pagador </Description>

<ChangeLog>
<log Date="14/06/2017" Author="Fgonzalez"> Creation</log>
</ChangeLog>

*********************************************************************/

AS BEGIN
SELECT DISTINCT g.IdGateway, GatewayName,g.Code
FROM PayerConfig pc WITH (NOLOCK)
JOIN Gateway g WITH (NOLOCK)
ON g.IdGateway = pc.IdGateway 
WHERE IdPayer =@idPayer AND g.Status =1
END 
