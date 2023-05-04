CREATE PROCEDURE [Corp].[st_GetReturnsCodeByGateway]
@IdGateway int
as

select 
	G.IdGateway,
	G.GatewayName,
	GT.IdGatewayReturnCodeType,
	GT.ReturnCodeType,
	S.IdStatus,
	isnull(S.StatusName,'') StatusName,
	GC.IdGatewayReturnCode,
	GC.ReturnCode,
	GC.Description
from GatewayReturnCode GC
	inner join  Gateway G on G.IdGateway=GC.IdGateway
	inner join GatewayReturnCodeType GT on GT.IdGatewayReturnCodeType=GC.IdGatewayReturnCodeType
	left join Status S on S.IdStatus =GC.IdStatusAction
	where GC.IdGateway=@IdGateway
