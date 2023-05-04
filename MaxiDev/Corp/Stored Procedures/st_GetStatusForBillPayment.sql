CREATE PROCEDURE [Corp].[st_GetStatusForBillPayment]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
      
/********************************************************************
<Author>Amoreno</Author>
<app> </app>
<Description>busqueda de Status de los proveedores </Description>

<ChangeLog>
<log Date="2018-08-22" Author="amoreno"> Se modifica la consulta temporal  </log>

</ChangeLog>

*********************************************************************/  
  
    
     select [ProviderId], [StatusId], [StatusName] from BillPayment.StatusProvider	 with (nolock)
	/*
	DECLARE @StatusTable AS TABLE(
		[ProviderId] INT
		, [StatusId] INT
		, [StatusName] NVARCHAR(MAX)
	)

	INSERT INTO @StatusTable VALUES (-1,0,'All')

	-- Softgate
	INSERT INTO @StatusTable VALUES (1,0,'All')
	INSERT INTO @StatusTable VALUES (1,1,'Active')
	INSERT INTO @StatusTable VALUES (1,2,'Cancelled')

	-- Regalii
	DECLARE @StatusName NVARCHAR(MAX)
	SELECT @StatusName = [StatusName] FROM [dbo].[Status] WHERE [IdStatus] = 22 -- Cancelled
	INSERT INTO @StatusTable VALUES (14, 0, 'All')
	INSERT INTO @StatusTable VALUES (14, 22, @StatusName)
	SELECT @StatusName = [StatusName] FROM [dbo].[Status] WHERE [IdStatus] = 30 -- Paid
	INSERT INTO @StatusTable VALUES (14, 30, @StatusName)

	-- Get status result set
	SELECT [ProviderId], [StatusId], [StatusName] FROM @StatusTable
*/
END

