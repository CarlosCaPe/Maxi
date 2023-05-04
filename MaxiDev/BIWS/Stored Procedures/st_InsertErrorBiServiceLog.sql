
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 16/04/2020
-- Description: SP para validar el tiempo de cada vez que falle el servicio de BI y mandar correo
-- M00176 - Manejo de error en la validación de la cuenta de BI por conectividad
-- Log 08-07-2020 Autor: Jgomez CR M00235 - Mejoras en el manejo de error en la validacion de la cuenta de BI por conectividad
-- =============================================

CREATE PROCEDURE [BIWS].[st_InsertErrorBiServiceLog]
(
	@IdAgent int = null,
	@TipoCuenta	int = null,
	@DepositAccountNumber NVARCHAR(250) = null,
	@IsEnable bit
)

AS

if (@IsEnable = 0)
	BEGIN

UPDATE [MAXILOG].[BIWS].[ErrorBiServiceLog] set IsEnable = 0

END
ELSE
BEGIN
if NOT EXISTS (SELECT * FROM [MAXILOG].[BIWS].[ErrorBiServiceLog] WITH(NOLOCK) WHERE [IsEnable] = 1)
	BEGIN
		INSERT INTO [MAXILOG].[BIWS].[ErrorBiServiceLog]
            ([IdAgent]
		    ,[DateTime]
			,[TipoCuenta]
			,[DepositAccountNumber]
			,[IsEnable])
		VALUES
           (@IdAgent
		   ,GETDATE()
		   ,@TipoCuenta
           ,@DepositAccountNumber
		   ,@IsEnable)		
END
END
