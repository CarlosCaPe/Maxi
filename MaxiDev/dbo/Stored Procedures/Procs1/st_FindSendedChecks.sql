
-- =============================================
-- Author:		Aldo Morán Márquez
-- Create date: 18/05/2015
-- Description:	Find Sended checks
-- =============================================
CREATE PROCEDURE [dbo].[st_FindSendedChecks](@Checks XML)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN

	declare  @DocHandle INT 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Checks

	SELECT
	id,
	LTRIM(RTRIM(ISNULL(CheckNumber,''))) CheckNumber,
	LTRIM(RTRIM(ISNULL(AccountNumber,''))) AccountNumber,
	LTRIM(RTRIM(ISNULL(RoutingNumber,''))) RoutingNumber
	into #TempChecks
	FROM OPENXML (@DocHandle, '/Checks/Check',2)
	With (
			id int,
			CheckNumber varchar(500),
			AccountNumber varchar(500),
			RoutingNumber varchar(500)
	)
	
	select T.id
	from Checks C with(nolock)
	inner join #TempChecks T on T.CheckNumber = C.CheckNumber and T.RoutingNumber = C.RoutingNumber and T.AccountNumber = C.Account
	order by T.Id

END
