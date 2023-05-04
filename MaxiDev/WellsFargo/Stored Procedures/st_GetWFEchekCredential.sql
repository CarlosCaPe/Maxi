
CREATE PROCEDURE [WellsFargo].[st_GetWFEchekCredential]
	-- Add the parameters for the stored procedure here
    @IdAgent int
AS
/**********************************************************************************************/
/* Autor:           Miguel Prado                                                              */
/* Fecha:           21/Julio/2022                                                             */
/* Proyecto:        Maxi.Core.WellsFargo MP-1175                                              */
/* Dependecia:      MaxiAgent                                                                 */
/* Descripción:     Se modifica Sp para obtener configuraciones de credenciales de WF         */
/*                  en base a IdAgente busca el StateCode correspondiente                     */
/**********************************************************************************************/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StateCode NVARCHAR(5)

	SELECT @StateCode = NULLIF((SELECT StateCode FROM WellsFargo.WFConfig WITH (NOLOCK) WHERE StateCode = (SELECT [AgentState] FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent)),'')

	SELECT 	   
		[MerchId]
		,[Key]      
		,[DateOfInitOperation]
		,[DateOfEndOperation]
		--,5 as AdditionalMinutes
	FROM WellsFargo.WFConfig WITH(NOLOCK)
	WHERE IdGenericStatus = 1
	AND ForService ='ECheck'
	AND (@StateCode IS NOT NULL AND StateCode = @StateCode) OR (@StateCode IS NULL AND StateCode IS NULL);
	
	SET NOCOUNT OFF;
END

