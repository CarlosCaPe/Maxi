CREATE PROCEDURE [Corp].[st_GetOfacAuditDetail] 
	@IdOfacAuditDetail INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdOfacAuditMatch], [IdOfacAuditDetail], [sdn_name], [sdn_remarks], [alt_type], [alt_name], [alt_remarks], [add_address], [add_city_name], [add_country], [add_remarks]
    FROM [dbo].[OfacAuditMatch] WITH(NOLOCK)
	WHERE IdOfacAuditDetail = @IdOfacAuditDetail 
	ORDER BY sdn_name, alt_name

END


