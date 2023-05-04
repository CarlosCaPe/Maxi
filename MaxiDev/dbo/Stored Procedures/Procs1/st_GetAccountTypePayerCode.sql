
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 08/10/2019
-- Description: SP para obtener los mensajes de error
-- M00103 - CR Banco Industrial, Notificación Pago
-- =============================================

CREATE PROCEDURE [dbo].[st_GetAccountTypePayerCode]
	
	@IdGateway int,
	@ReturnCode varchar(10),
	@idLenguage int

AS

Select [Description] from dbo.GatewayReturnCode with(nolock)
where IdGateway = @IdGateway AND ReturnCode = @ReturnCode AND idLenguage = @idLenguage
