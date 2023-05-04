
CREATE PROCEDURE [dbo].[st_FindIdAgentBankDepositById]
    @IdAgentBankDeposit int
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [IdAgentBankDeposit] as [Id] 
      ,[BankName] as  [Name]
    FROM [dbo].[AgentBankDeposit]
	WHERE IdAgentBankDeposit = @IdAgentBankDeposit

END