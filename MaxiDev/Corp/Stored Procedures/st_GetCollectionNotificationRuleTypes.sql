CREATE PROCEDURE [Corp].[st_GetCollectionNotificationRuleTypes]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCollectionNotificationRuleType], [Name], [CreationDate], [DateofLastChange], [EnterByIdUser], [IdStatus]
	FROM [dbo].[CollectionNotificationRuleType] WITH(NOLOCK)

END 



