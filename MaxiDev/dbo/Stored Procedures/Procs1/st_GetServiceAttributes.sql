
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-07
-- Description:	Returns global attributes all or filtered by name
-- =============================================
create PROCEDURE [dbo].[st_GetServiceAttributes]
	@Code NVARCHAR(MAX) = NULL
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used get attributes of service</Description>

<ChangeLog>
<log Date="07/09/2018" Author="snevarez">Add Parameter Code</log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF LTRIM(@Code) = ''
		SET @Code = NULL

	SELECT
		[Code]
		, [Key]
		, [Value]
	FROM [Services].[ServiceAttributes] WITH (NOLOCK)
	WHERE [Code]= ISNULL(@Code, [Code])
	
END

