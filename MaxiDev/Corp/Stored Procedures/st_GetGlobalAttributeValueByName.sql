CREATE PROCEDURE [Corp].[st_GetGlobalAttributeValueByName]
	-- Add the parameters for the stored procedure here
	@AttributeName NVARCHAR(MAX),
	@AttributeValue NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	SET @AttributeValue = [dbo].[GetGlobalAttributeByName](@AttributeName)
END

