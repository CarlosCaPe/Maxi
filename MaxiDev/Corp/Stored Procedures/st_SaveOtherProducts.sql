CREATE PROCEDURE [Corp].[st_SaveOtherProducts]
(
	@idAgent int,
	@otherProducts XML,

	@IsSpanishLanguage bit,
	@HasError bit out,
	@MessageOut varchar(max) out
)            
AS            
Begin Try
	
	Set @HasError=0
    Select @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)	

	INSERT INTO [dbo].[AgentOtherProductInfoLog]([IdAgent],[Detail])
     VALUES (@idAgent,@otherProducts)

	Declare 
	@IdTable int,
	@IdOtherProduct int,
	@IsEnable int,
	@IdFeeByOtherProducts int = null,
	@IdCommissionByOtherProducts int = null,
	@AmmountForClassF money,
	@IdAgentOtherProductInfo int 

	Declare @DocHandle INT 
    
	create table #OtherProducts
	(
		IdTable int identity, 
		IdOtherProduct int,
		IsEnable int,
		IdFeeByOtherProducts int null,
		IdCommissionByOtherProducts int null,
		AmmountForClassF money,
		IdAgentOtherProductInfo int
	)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @otherProducts
	
	insert into #OtherProducts 

	SELECT IdOtherProduct,IsEnable, IdFeeByOtherProducts, IdCommissionByOtherProducts,AmmountForClassF, IdAgentOtherProductInfo From OPENXML (@DocHandle, '/OtherProducts/Detail',2)
    WITH 
	(
        IdOtherProduct int,
		IsEnable int,
		IdFeeByOtherProducts int,
		IdCommissionByOtherProducts int,
		AmmountForClassF money,
		IdAgentOtherProductInfo int
    )

	EXEC sp_xml_removedocument @DocHandle

	--select * into tempdata from #OtherProducts
	
	select IdOtherProducts  IdOtherProduct into #otherproductdelete from OtherProducts with(nolock) where IdOtherProducts not in (select IdOtherProduct from #otherproducts)

	WHILE exists (select top 1 1 from #otherproductdelete)
	BEGIN
		select top 1 @IdOtherProduct = IdOtherProduct from #otherproductdelete
		if(@IdOtherProduct = 1)
			delete from AgentBillPaymentInfo where idagent=@idAgent
		if(@IdOtherProduct = 5)
			delete from AgentPureMinutesInfo where idagent=@idAgent
		if(@IdOtherProduct > 6)
			delete from AgentOtherProductInfo where idagent=@idAgent and IdOtherProduct=@IdOtherProduct
		delete from #otherproductdelete where IdOtherProduct=@IdOtherProduct
	end

	update AgentProducts set IdGenericStatus = 2 where IdAgent = @idAgent
	
	delete from AgentOtherProductInfo 
	where 
		idagent=@idAgent 
		and 
		IdOtherProduct=8 
		and 
		exists (select  top 1 1 from  #OtherProducts where (isnull(IdAgentOtherProductInfo,0)=0) and IdOtherProduct=8)

	/*
	if exists(select top 1 1 from #OtherProducts where IdOtherProduct=7) and not exists(select top 1 1 from TransFerTo.AgentCredential where idagent=@idAgent)
    begin
        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max) 
        Declare @AgentCode nvarchar(max)  =' '
        Declare @AgentName nvarchar(max)  =' '

        select @AgentName=agentname,@AgentCode=agentcode from agent where idagent=@idAgent

        Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailTransferTo'    
        select @body = 'Agent '+isnull(@AgentCode,'')+' - '+ @AgentName+' Required TransferTo Credentials'
        select @subject = 'Agent '+isnull(@AgentCode,'')+' - '+ @AgentName+' Required TransferTo Credentials'

        Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    
	    Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	    EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,                                                             
		        @subject = @subject     
    end
	*/

	WHILE exists (select top 1 1 from #OtherProducts)

	BEGIN

		select top 1 @IdOtherProduct = IdOtherProduct, @IsEnable = IsEnable , @IdFeeByOtherProducts = IdFeeByOtherProducts, @IdCommissionByOtherProducts = IdCommissionByOtherProducts, @AmmountForClassF = AmmountForClassF, @IdAgentOtherProductInfo = IdAgentOtherProductInfo, @IdTable = IdTable from  #OtherProducts

		if(exists (select top 1 1 from AgentProducts with(nolock) where IdAgent = @idAgent and IdOtherProducts = @IdOtherProduct))
			begin 
				update AgentProducts set IdGenericStatus = @IsEnable where IdAgent = @idAgent and IdOtherProducts = @IdOtherProduct

				if(@IdOtherProduct = 1)
					if(exists (select top 1 1  from AgentBillPaymentInfo with(nolock) where IdAgent = @idAgent))
						update AgentBillPaymentInfo set IdFeeByOtherProducts = @IdFeeByOtherProducts, IdCommissionByOtherProducts = @IdCommissionByOtherProducts, AmountForClassF = @AmmountForClassF where IdAgent = @idAgent
					else 
						insert into AgentBillPaymentInfo (IdAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts, AmountForClassF) values (@idAgent, @IdFeeByOtherProducts, @IdCommissionByOtherProducts, @AmmountForClassF)
				else
					if(@IdOtherProduct = 5)
						if(exists (select top 1 1  from AgentPureMinutesInfo with(nolock) where IdAgent = @idAgent))
							update AgentPureMinutesInfo set IdCommissionByOtherProducts = @IdCommissionByOtherProducts where IdAgent = @idAgent
						else
							insert into AgentPureMinutesInfo (IdAgent, IdCommissionByOtherProducts) values (@idAgent, @IdCommissionByOtherProducts)
					else
						if(@IdOtherProduct not in (1,6,5))
							Begin
								if(exists(select top 1 1 from AgentOtherProductInfo with(nolock) where IdAgent = @idAgent and IdOtherProduct = @IdOtherProduct) )
									Begin
										if(@IdFeeByOtherProducts = 0)
											set @IdFeeByOtherProducts = null
										if(@IdCommissionByOtherProducts = 0)
											set @IdCommissionByOtherProducts = null
										update AgentOtherProductInfo set  AmountForAgent = @AmmountForClassF, IdFeeByOtherProducts = @IdFeeByOtherProducts, IdCommissionByOtherProducts = @IdCommissionByOtherProducts where IdAgent = @idAgent and IdOtherProduct = @IdOtherProduct
									End
								else
									Begin
										if(@IdFeeByOtherProducts = 0)
											set @IdFeeByOtherProducts = null
										if(@IdCommissionByOtherProducts = 0)
											set @IdCommissionByOtherProducts = null
										insert into AgentOtherProductInfo(IdAgent, IdOtherProduct, AmountForAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts) values (@idAgent,  @IdOtherProduct, @AmmountForClassF, @IdFeeByOtherProducts, @IdCommissionByOtherProducts)
									End
							END
			end
		else
			begin
			if(@IsEnable = 1)
				begin

					insert into AgentProducts (IdAgent, IdOtherProducts, IdGenericStatus) values (@idAgent, @IdOtherProduct, @IsEnable)

					if(@IdOtherProduct = 1)
						insert into AgentBillPaymentInfo (IdAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts, AmountForClassF) values (@idAgent, @IdFeeByOtherProducts, @IdCommissionByOtherProducts, @AmmountForClassF)

					if(@IdOtherProduct = 5)
						insert into AgentPureMinutesInfo (IdAgent, IdCommissionByOtherProducts) values (@idAgent, @IdCommissionByOtherProducts)

					--if(@IdOtherProduct = 6)--No existe producto 6
					--	insert into AgentPureMinutesTopUpInfo (IdAgent, IdCommissionByOtherProducts) values (@idAgent, @IdCommissionByOtherProducts)

					if(@IdOtherProduct not in (1,5,6))
						Begin
							if(@IdFeeByOtherProducts = 0)
								set @IdFeeByOtherProducts = null
							if(@IdCommissionByOtherProducts = 0)
								set @IdCommissionByOtherProducts = null
							insert into AgentOtherProductInfo(IdAgent, IdOtherProduct, AmountForAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts) values (@idAgent,  @IdOtherProduct, @AmmountForClassF, @IdFeeByOtherProducts, @IdCommissionByOtherProducts)
						End

				end
			end

		delete  #OtherProducts where IdTable = @IdTable

	end

End Try
                                     
Begin Catch                                                

	Set @HasError=1
	Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)                                                   
	Select @ErrorMessage=ERROR_MESSAGE()                                                
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveOtherProducts',Getdate(),@ErrorMessage)
End Catch 

