-- ******************************************************		THIS STORED IS DEPRECATED // FRANCISCO LARA
CREATE Procedure [dbo].[st_SaveOtherProductsByIdOtherProduct] (
	@IdAgent int,
    @IdOtherProduct int,
	@ConfigProduct XML,
    @ProductEnable bit,
	@IsSpanishLanguage bit,
	@HasError bit out,
	@MessageOut varchar(max) out
)            
AS            
Begin Try
	SELECT 'THIS STORED IS DEPRECATED, USE [dbo].[st_SaveOtherProducts]' [Message]
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveOtherProductsByIdOtherProduct',Getdate(),'THIS STORED IS DEPRECATED, USE [dbo].[st_SaveOtherProducts]')
	/* -- Add by Francisco Lara (Remove)
	Set @HasError=0
    Select @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)	

	Declare 	
	@IdFeeByOtherProducts int = null,
	@IdCommissionByOtherProducts int = null,
	@AmmountForClassF money,
	@IdAgentOtherProductInfo int ,
    @IdTable int
	Declare @DocHandle INT 
    
	create table #OtherProducts
	(		
        IdTable int identity(1,1),
		IdFeeByOtherProducts int null,
		IdCommissionByOtherProducts int null,
		AmmountForClassF money,
		IdAgentOtherProductInfo int
	)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @ConfigProduct
	
	insert into #OtherProducts 

	SELECT IdFeeByOtherProducts, IdCommissionByOtherProducts,AmmountForClassF, IdAgentOtherProductInfo From OPENXML (@DocHandle, '/OtherProducts/Detail',2)
    WITH 
	(        
		IdFeeByOtherProducts int,
		IdCommissionByOtherProducts int,
		AmmountForClassF money,
		IdAgentOtherProductInfo int
    )

	EXEC sp_xml_removedocument @DocHandle
    
    if (@ProductEnable=0)
    begin
        if(@IdOtherProduct = 1)
	        delete from AgentBillPaymentInfo where idagent=@idAgent
	    if(@IdOtherProduct = 5)
		    delete from AgentPureMinutesInfo where idagent=@idAgent
	    if(@IdOtherProduct > 6)
    		delete from AgentOtherProductInfo where idagent=@idAgent and IdOtherProduct=@IdOtherProduct
	
        update AgentProducts set IdGenericStatus = 2 where IdAgent = @idAgent and IdOtherProducts=@IdOtherProduct
        return;
    end
       
        if(exists (select top 1 1 from AgentProducts where IdAgent = @idAgent and IdOtherProducts = @IdOtherProduct))   		
            update AgentProducts set IdGenericStatus = 1 where IdAgent = @idAgent and IdOtherProducts=@IdOtherProduct
        else
            insert into AgentProducts (IdAgent,IdGenericStatus,IdOtherProducts) values (@idagent,1,@IdOtherProduct)        
    

	/*
    if (@IdOtherProduct=7) and not exists(select top 1 1 from TransFerTo.AgentCredential where idagent=@idAgent)
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

		select top 1 @IdTable=IdTable, @IdFeeByOtherProducts = IdFeeByOtherProducts, @IdCommissionByOtherProducts = IdCommissionByOtherProducts, @AmmountForClassF = AmmountForClassF, @IdAgentOtherProductInfo = IdAgentOtherProductInfo from  #OtherProducts
        	
				if(@IdOtherProduct = 1)
					if(exists (select top 1 1  from AgentBillPaymentInfo where IdAgent = @idAgent))
						update AgentBillPaymentInfo set IdFeeByOtherProducts = @IdFeeByOtherProducts, IdCommissionByOtherProducts = @IdCommissionByOtherProducts, AmountForClassF = @AmmountForClassF where IdAgent = @idAgent
					else 
						insert into AgentBillPaymentInfo (IdAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts, AmountForClassF) values (@idAgent, @IdFeeByOtherProducts, @IdCommissionByOtherProducts, @AmmountForClassF)
				else
					if(@IdOtherProduct = 5)
						if(exists (select top 1 1  from AgentPureMinutesInfo where IdAgent = @idAgent))
							update AgentPureMinutesInfo set IdCommissionByOtherProducts = @IdCommissionByOtherProducts where IdAgent = @idAgent
						else
							insert into AgentPureMinutesInfo (IdAgent, IdCommissionByOtherProducts) values (@idAgent, @IdCommissionByOtherProducts)
					else
							if(exists(select top 1 1 from AgentOtherProductInfo where IdAgentOtherProductInfo = @IdAgentOtherProductInfo) and @IdOtherProduct not in (1,6,5))
								Begin
									if(@IdFeeByOtherProducts = 0)
										set @IdFeeByOtherProducts = null
									if(@IdCommissionByOtherProducts = 0)
										set @IdCommissionByOtherProducts = null
									update AgentOtherProductInfo set IdAgent = @idAgent, IdOtherProduct = @IdOtherProduct, AmountForAgent = @AmmountForClassF, IdFeeByOtherProducts = @IdFeeByOtherProducts, IdCommissionByOtherProducts = @IdCommissionByOtherProducts where IdAgentOtherProductInfo = @IdAgentOtherProductInfo
								End
							else
								Begin
									if(@IdFeeByOtherProducts = 0)
										set @IdFeeByOtherProducts = null
									if(@IdCommissionByOtherProducts = 0)
										set @IdCommissionByOtherProducts = null
									insert into AgentOtherProductInfo(IdAgent, IdOtherProduct, AmountForAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts) values (@idAgent,  @IdOtherProduct, @AmmountForClassF, @IdFeeByOtherProducts, @IdCommissionByOtherProducts)
								End
			
		delete  #OtherProducts where IdTable = @IdTable

	end
	*/ -- Add by Francisco Lara (Remove)
End Try                                     
Begin Catch
	Set @HasError=1
	Select dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)                                                   
	Select @ErrorMessage=ERROR_MESSAGE()                                                
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveOtherProductsByIdOtherProduct',Getdate(),@ErrorMessage)
End Catch