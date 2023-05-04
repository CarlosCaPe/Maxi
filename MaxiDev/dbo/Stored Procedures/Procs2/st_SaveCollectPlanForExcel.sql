-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-08
-- Description:	This stored is used in Collect Plan By Commission screen (Corporate / Collection)
-- =============================================
CREATE PROCEDURE [dbo].[st_SaveCollectPlanForExcel]
	-- Add the parameters for the stored procedure here
	@UserId INT,
	@Guid VARCHAR(100),
	@Items XML,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DELETE FROM [CollectPlanForExcel] WHERE [CreationDate] < DATEADD(DAY,-1,GETDATE())

	DECLARE @Date DATETIME = GETDATE(), @DocHandle INT

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Items

	INSERT INTO [CollectPlanForExcel]
		SELECT
			@Guid,
			@Date,
			@UserId,
			[AgentCollectionId],
			[AgentCode],
			[AgentName],
			[Percentage],
			[Commission],
			[ExpectedAmount],
			[Amount],
			[Note],
			[AgentClass],
			[Fee],
			[TotalDebt],
			[FixedCommission],
			[SpecialCommission],
			[SpecialCommissionToApply],
			[BonusApplied],
			[BonusDebt]
		FROM OPENXML (@DocHandle, '/Items/Item', 2)
		WITH(
			[AgentCollectionId] INT,
			[AgentCode] NVARCHAR(MAX),
			[AgentName] NVARCHAR(MAX),
			[Percentage] INT,
			[Commission] MONEY,
			[ExpectedAmount] MONEY,
			[Amount] MONEY,
			[Note] NVARCHAR(MAX),
			[AgentClass] NVARCHAR(MAX),
			[Fee] MONEY,
			[TotalDebt] MONEY,
			[FixedCommission] MONEY,
			[SpecialCommission] MONEY,
			[SpecialCommissionToApply] MONEY,
			[BonusApplied] MONEY,
			[BonusDebt] MONEY
		)

	SET @HasError = 0
	SELECT @Message = 'Operation was performed successfully'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_SaveCollectPlanForExcel', GETDATE(), @ErrorMessage)
	SET @HasError = 1
	SELECT @Message = 'Error trying save temp data'
END CATCH
