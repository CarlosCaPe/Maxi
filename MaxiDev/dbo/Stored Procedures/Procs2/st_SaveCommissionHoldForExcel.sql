-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-09
-- Description:	This stored is used in Commission Hold screen (Corporate / Collection)
-- =============================================
CREATE PROCEDURE [dbo].[st_SaveCommissionHoldForExcel]
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
	
	DELETE FROM [CommissionHoldForExcel] WHERE [CreationDate] < DATEADD(DAY,-1,GETDATE())

	DECLARE @Date DATETIME = GETDATE(), @DocHandle INT

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Items

	INSERT INTO [CommissionHoldForExcel]
		SELECT
			@Guid,
			@Date,
			@UserId,
			[AgentId],
			[AgentCode],
			[AgentName],
			[AgentClass],
			[TotalCommission],
			[SpecialCommission],
			[RetainCommission],
			[MonthlyCommission],
			[Debt],
			[Amount],
			[Notes],
			[BonusApplied],
			[BonusDebt]
		FROM OPENXML (@DocHandle, '/Items/Item', 2)
		WITH(
			[AgentId] INT,
			[AgentCode] NVARCHAR(MAX),
			[AgentName] NVARCHAR(MAX),
			[AgentClass] NVARCHAR(MAX),
			[TotalCommission] MONEY,
			[SpecialCommission] MONEY,
			[RetainCommission] MONEY,
			[MonthlyCommission] MONEY,
			[Debt] MONEY,
			[Amount] MONEY,
			[Notes] NVARCHAR(MAX),
			[BonusApplied] MONEY,
			[BonusDebt] MONEY
		)

	SET @HasError = 0
	SELECT @Message = 'Operation was performed successfully'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_SaveCommissionHoldForExcel', GETDATE(), @ErrorMessage)
	SET @HasError = 1
	SELECT @Message = 'Error trying save temp data'
END CATCH
