CREATE PROCEDURE [dbo].[st_FetchAgentBankDeposit]
(
	@IdAgentCollectType		INT,
	@IdState				INT,

	@Offset					BIGINT,
	@Limit					BIGINT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Catalogs</app>
<Description>This stored is used in CorporativeServices.Catalogs API</Description>

<ChangeLog>
	<log Date="17/08/2022" Author="maprado">Add @IdAgentCollectType, IdState parameter </log>
</ChangeLog>
*********************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	SELECT T.*
	FROM (
		SELECT
			ABD.IdAgentBankDeposit,
			ABD.BankName,
			ABD.AccountNumber,
			ABD.DateofLastChange,
			ABD.EnterByIdUser,
			ABD.IdGenericStatus,
			ABD.IsTablet,
			ABD.SubAccountRequired,
			COUNT(*) OVER() _PagedResult_Total
		FROM AgentBankDepositStateRelation ABDSR WITH (NOLOCK)
		INNER JOIN AgentBankDepositAgentCollectTypeRelation ABDCTR WITH (NOLOCK) ON ABDSR.IdAgentBankDeposit = ABDCTR.IdAgentBankDeposit
		INNER JOIN AgentBankDeposit ABD WITH (NOLOCK) ON ABDCTR.IdAgentBankDeposit = ABD.IdAgentBankDeposit
		WHERE (@IdState IS NULL OR ABDSR.IdState = @IdState)
		AND (@IdAgentCollectType IS NULL OR ABDCTR.IdAgentCollectType = @IdAgentCollectType)
		GROUP BY ABD.IdAgentBankDeposit,
			ABD.BankName,
			ABD.AccountNumber,
			ABD.DateofLastChange,
			ABD.EnterByIdUser,
			ABD.IdGenericStatus,
			ABD.IsTablet,
			ABD.SubAccountRequired) AS T
	ORDER BY T.IdAgentBankDeposit
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY;

END
