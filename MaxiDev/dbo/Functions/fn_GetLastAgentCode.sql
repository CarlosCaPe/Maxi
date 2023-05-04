-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-04
-- Description:	Return last agent code transfer by customer id or beneficiary id
-- =============================================
CREATE FUNCTION [dbo].[fn_GetLastAgentCode]
(
	-- Add the parameters for the function here
	@ReferenceId INT
	, @IsCustomer BIT
	, @SearchInChecks BIT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @AgentId INT, @AgentCode NVARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here

	IF @IsCustomer = 1 AND @SearchInChecks = 1
		SELECT TOP 1 @AgentId = L.IdAgent
		FROM (
			SELECT [T].[IdAgent], T.[DateOfTransfer]
			FROM [dbo].[Transfer] T WITH (NOLOCK)
			WHERE [IdCustomer] = @ReferenceId
			UNION ALL
			SELECT [T].[IdAgent], T.[DateOfTransfer]
			FROM [dbo].[TransferClosed] T WITH (NOLOCK)
			WHERE [IdCustomer] = @ReferenceId
			UNION ALL
			SELECT C.[IdAgent], C.[DateofMovement]
			FROM [dbo].[Checks] C WITH (NOLOCK)
			WHERE [IdCustomer] = @ReferenceId)L
		ORDER BY [L].[DateOfTransfer] DESC
	ELSE IF @IsCustomer = 1
		SELECT TOP 1 @AgentId = L.IdAgent
		FROM (
			SELECT [T].[IdAgent], T.[IdTransfer]
			FROM [dbo].[Transfer] T WITH (NOLOCK)
			WHERE [IdCustomer] = @ReferenceId
			UNION ALL
			SELECT [T].[IdAgent], T.[IdTransferClosed]
			FROM [dbo].[TransferClosed] T WITH (NOLOCK)
			WHERE [IdCustomer] = @ReferenceId)L
		ORDER BY [L].[IdTransfer] DESC
	ELSE
		SELECT TOP 1 @AgentId = L.IdAgent
		FROM (
			SELECT [T].[IdAgent], T.[IdTransfer]
			FROM [dbo].[Transfer] T WITH (NOLOCK)
			WHERE [IdBeneficiary] = @ReferenceId
			UNION ALL
			SELECT [T].[IdAgent], T.[IdTransferClosed]
			FROM [dbo].[TransferClosed] T WITH (NOLOCK)
			WHERE [IdBeneficiary] = @ReferenceId )L
		ORDER BY [L].[IdTransfer] DESC

	SELECT @AgentCode = [AgentCode] FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgent] = @AgentId

	-- Return the result of the function
	RETURN @AgentCode

END
