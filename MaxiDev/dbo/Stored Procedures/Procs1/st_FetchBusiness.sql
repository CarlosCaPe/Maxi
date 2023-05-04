CREATE PROCEDURE [dbo].[st_FetchBusiness]
(
	@LegalName		VARCHAR(200),
	@OwnerName		VARCHAR(200),

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
/********************************************************************
<Author></Author>
<app>Maxi_CorporativeServices_Agents</app>
<Description>This stored is used to get data for Business</Description>
<ChangeLog>
	<log Date="16/08/2022" Author="maprado">Create Stored Procedure</log>
</ChangeLog>
*********************************************************************/
BEGIN

	SELECT
		COUNT(*) OVER() _PagedResult_Total,
		A.DoingBusinessAs AS LegalName,
		ISNULL(A.IdAgentEntityType, 0) AS EntityType,
		A.TaxID AS Tin,
		ISNULL(A.IdTaxIDType, 0) AS TinType,
		A.IdOwner
	FROM Agent A WITH (NOLOCK)
	INNER JOIN Owner O WITH (NOLOCK) ON A.IdOwner = O.IdOwner
	WHERE 
		A.DoingBusinessAs IS NOT NULL AND (ISNULL(@LegalName, '') = '' OR A.DoingBusinessAs LIKE CONCAT('%', @LegalName ,'%'))
		AND (ISNULL(@OwnerName, '') = '' OR CONCAT(O.NAME,' ',O.LastName,' ',O.SecondLastName) LIKE CONCAT('%', @OwnerName ,'%'))
	ORDER BY A.IdAgent
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END