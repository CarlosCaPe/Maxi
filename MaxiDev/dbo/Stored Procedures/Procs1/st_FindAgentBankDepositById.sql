
CREATE PROCEDURE [dbo].[st_FindAgentBankDepositById]
    @IdAgentBankDeposit int
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [IdAgentBankDeposit] as [Id] 
      ,[BankName] as  [Name]
    FROM [dbo].[AgentBankDeposit]
	WHERE IdAgentBankDeposit = @IdAgentBankDeposit

END