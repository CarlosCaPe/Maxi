/********************************************************************
<Author>jcsierra</Author>
<app>MoneyOrder</app>

<ChangeLog>
	<log Date="03/02/2023" Author="jcsierra"> Se crea SP para obtener status de MO </log>
</ChangeLog>
*********************************************************************/     
CREATE   PROCEDURE Corp.st_GetStatusMoneyOrder
AS
BEGIN
	SELECT 
		s.IdStatus,
		s.StatusName
	FROM [dbo].[Status] s WITH(NOLOCK)
	WHERE s.IdType = 3
END