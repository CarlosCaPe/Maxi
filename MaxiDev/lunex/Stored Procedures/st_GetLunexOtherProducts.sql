-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-07
-- Description:	Returns Lunex Other Products // This stored is used in MaxiBackOffice and BillPayments
-- =============================================
CREATE PROCEDURE [lunex].[st_GetLunexOtherProducts]
AS

	SELECT
		[IdOtherProducts]
		, [Description]
	FROM [dbo].[OtherProducts] WITH (NOLOCK)
	WHERE [IdOtherProducts] IN (10,11,13,16)
	ORDER BY [Description]


