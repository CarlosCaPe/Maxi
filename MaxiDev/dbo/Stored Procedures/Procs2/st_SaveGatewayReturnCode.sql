CREATE PROCEDURE [dbo].[st_SaveGatewayReturnCode]
@IdGatewayReturnCode int,
@IdGateway int,
@IdGatewayReturnCodeType int,
@ReturnCode varchar(16),
@Description varchar(512),
@IdStatusAction int,
@IsSpanishLanguage bit,
@HasError bit out,
@ResultMessage nvarchar(max) out
as

Begin try
	if (@IdStatusAction =0)
	Begin
		set @IdStatusAction=null
	End	
	set @ReturnCode =RTRIM(LTRIM(@ReturnCode))
	if exists(select 1 from dbo.GatewayReturnCode where IdGateway=@IdGateway and IdGatewayReturnCodeType=@IdGatewayReturnCodeType and ReturnCode=@ReturnCode and (@IdGatewayReturnCode=0 or IdGatewayReturnCode<>@IdGatewayReturnCode))
	Begin
		set @HasError =1
		set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,26)
		return
	End
	if @IdGatewayReturnCode<>0 and exists(select 1 from dbo.GatewayReturnCode
											where IdGatewayReturnCode =@IdGatewayReturnCode )
			Begin
				UPDATE [dbo].[GatewayReturnCode]
					   SET 
						  [IdGatewayReturnCodeType] = @IdGatewayReturnCodeType
						  ,[ReturnCode] = @ReturnCode
						  ,[Description] = @Description
						  ,[IdStatusAction] = @IdStatusAction
					 WHERE IdGatewayReturnCode= @IdGatewayReturnCode
			End		
	else	
			Begin 
				INSERT INTO [dbo].[GatewayReturnCode]
					   ([IdGateway]
					   ,[IdGatewayReturnCodeType]
					   ,[ReturnCode]
					   ,[Description]
					   ,[IdStatusAction])
				 VALUES
					   (@IdGateway
					   ,@IdGatewayReturnCodeType
					   ,@ReturnCode
					   ,@Description
					   ,@IdStatusAction)
			End
			set @HasError =0
			set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,25)
End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveGatewayReturnCode]',Getdate(),@ErrorMessage) 
		set @HasError =1
		set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,24)
		
End catch
