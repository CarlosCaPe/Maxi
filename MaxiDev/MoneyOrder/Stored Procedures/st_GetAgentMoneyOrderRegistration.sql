CREATE   PROCEDURE [MoneyOrder].[st_GetAgentMoneyOrderRegistration]
(
	@IdAgent			INT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		SELECT 
			ar.IdAgentRegistration,
			ar.IdAgent,
			ar.PIN,
			ar.TransactionFee,
			ar.[GUID],
			ar.PrivateKey,
			ar.PublicKey,
			ar.EffectiveStartDate,
			ar.EffectiveEndDate,
			ar.RouteCode,
			ar.AccountNo,
			ar.CompanyId,
			ar.StoreId,
			ar.IdGenericStatus,
			ar.CreationDate,
			ar.DateOfLastChange,
			ar.EnterByIdUser,
			ar.TransactionFeeTop,
			ar.TransactionFeeBottom,
			ar.VerifySequence,
			IIF((ar.GUID IS NULL OR ar.GUID = '') 
			OR (ar.PrivateKey IS NULL OR ar.PrivateKey = '') 
			OR (ar.PublicKey IS NULL OR ar.PublicKey = '')
			, 1, 0) IsKeyEmpty
		FROM MoneyOrder.AgentRegistration ar WITH(NOLOCK) 
		WHERE ar.IdAgent = @IdAgent
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END