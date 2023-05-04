CREATE PROCEDURE [dbo].[st_FetchAgentCollectType]
(
	@IdState		INT,

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Catalogs</app>
<Description>This stored is used in CorporativeServices.Catalogs API</Description>

<ChangeLog>
	<log Date="17/08/2022" Author="maprado">Add IdState parameter </log>
</ChangeLog>
*********************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	SELECT T.*
	FROM (
		SELECT
			ACT.IdAgentCollectType,
			ACT.Name,
			ACT.CreationDate,
			ACT.DateofLastChange,
			ACT.EnterByIdUser,
			ACT.IdStatus,
			COUNT(*) OVER() _PagedResult_Total
		FROM AgentBankDepositStateRelation ABDSR WITH (NOLOCK)
		INNER JOIN AgentBankDepositAgentCollectTypeRelation ABDCTR WITH (NOLOCK) ON ABDSR.IdAgentBankDeposit = ABDCTR.IdAgentBankDeposit
		INNER JOIN AgentCollectType ACT WITH (NOLOCK) ON ABDCTR.IdAgentCollectType = ACT.IdAgentCollectType
		WHERE (@IdState IS NULL OR ABDSR.IdState = @IdState)
		GROUP BY ACT.IdAgentCollectType,
			ACT.Name,
			ACT.CreationDate,
			ACT.DateofLastChange,
			ACT.EnterByIdUser,
			ACT.IdStatus) AS T
	ORDER BY T.IdAgentCollectType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY;

END