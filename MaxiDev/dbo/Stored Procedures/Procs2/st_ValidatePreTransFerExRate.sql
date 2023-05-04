
CREATE procedure [dbo].[st_ValidatePreTransFerExRate]
as

BEGIN TRY

	SET NOCOUNT ON;

	--declaracion de variables
	declare @IdPreTransfer int,
			@OriginExrate money,
			@ActualExrate money

	create table #PreTransferTMP
	(
		IdPreTransfer int,
		OriginExrate money,
		ActualExrate money
	);
	
	--obtener preenvios y su tipo de cambio actual
	insert into #PreTransFerTmp
	select idpretransfer,originexrate,dbo.FunCurrentExRate(IdCountryCurrency,IdGateway,IdPayer,Idagent,idcity,IdPaymentType,IdAgentSchema,AmountInDollars) ActualExrate 
	from pretransfer with(nolock)
	where isvalid!=1 
		and originexrate!=1 
		and IdCountryCurrency!=8

	-------- Main loop ---------------------------------------------------------------------------      
	While exists (Select 1 from #PreTransFerTmp)      
	Begin      
	  Select top 1 @IdPreTransfer=IdPreTransfer,@OriginExrate=OriginExrate,@ActualExrate=ActualExrate from #PreTransFerTmp;

	  if @OriginExrate!=@ActualExrate
	  begin
		update pretransfer set isvalid=1 where IdPreTransfer=@IdPreTransfer;
	  end
 
	  Delete #PreTransFerTmp where IdPreTransfer=@IdPreTransfer;
	End
END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ValidatePreTransFerExRate', GETDATE(), @Message)
END CATCH