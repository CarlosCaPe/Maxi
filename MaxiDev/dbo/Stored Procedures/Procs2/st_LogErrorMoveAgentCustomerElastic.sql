CREATE PROCEDURE [dbo].[st_LogErrorMoveAgentCustomerElastic]
(
    @IdAgentOrigin int,
    @IdAgentDestiny int,
	@IdElasticCustomers VARCHAR(MAX),
    @EnterByIdUser int
)
AS
BEGIN TRY
	INSERT INTO dbo.AgentCustomerMovementElasticError 
	(
		[IdAgentOrigin], [IdAgentDestiny], [IdElasticCustomers], [EnterByIdUser], [DateOfMovement]
	)
	VALUES 
	(
		@IdAgentOrigin, @IdAgentDestiny, @IdElasticCustomers, @EnterByIdUser, GETDATE()
	)
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()                                                
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_LogErrorMoveAgentCustomerElastic',Getdate(),@ErrorMessage)
END CATCH