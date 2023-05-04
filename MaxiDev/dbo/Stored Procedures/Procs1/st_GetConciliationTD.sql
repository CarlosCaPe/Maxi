-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[st_GetConciliationTD] 

AS
BEGIN
	declare @dayOfConciliation varchar(10)
	Select @dayOfConciliation = CONVERT(varchar, DATEADD(day, -1, GETDATE()), 23)
	--select @dayOfConciliation

	Select 
		'H1'											IdentificadorReg,
		'00018'											IdRemesadora,
		@dayOfConciliation								FechaConciliacion,
		Count(IdTransferClosed)								TotOperaciones,
		CONVERT(DECIMAL(10,2),Sum(AmountInMN))			ImporteTotal,
		CONVERT(DECIMAL(10,2),Sum(CorporateCommission)) ComisionTotal
	    from Maxi.dbo.TransferClosed t with(nolock)
	Where IdGateway = 57 
		and IdStatus = 30 
		and CONVERT(varchar, DateOfLastChange, 23) = @dayOfConciliation


	Select 
		'REG'									IdentificadorReg,
		CONVERT(varchar(10), t.DateOfTransfer, 120)			FechaCobro,
		substring(replace(CONVERT(varchar, t.DateOfTransfer, 114),':',''),1,6) HoraCobro,
		' '												Folio,
		' '												Autorizacion,
		' '												Ticket,
		t.ClaimCode										Claimcode,
		CONVERT(DECIMAL(10,2),t.AmountInMN)				Monto,
		CONVERT(DECIMAL(10,2),t.CorporateCommission)	Comision
	from Maxi.dbo.TransferClosed t with(nolock)
	Where IdGateway = 57 
		and IdStatus = 30 
		and CONVERT(varchar, DateOfLastChange, 23) = @dayOfConciliation
		order by IdTransferClosed
END

