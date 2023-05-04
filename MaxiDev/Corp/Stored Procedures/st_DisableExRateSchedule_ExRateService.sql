CREATE PROCEDURE [Corp].[st_DisableExRateSchedule_ExRateService]
(
    @IdExRateSchedule int,	
	@EnterByIdUser int,
    @IdLenguage int,
    @HasError bit out,  
    @MessageOut nvarchar(max) out    
)
as
begin try

    if @IdLenguage is null 
        set @IdLenguage=2

    UPDATE ExRateService.[ExRateSchedule]
       SET 
           [EnterByIdUser] = @EnterByIdUser
          ,[DateOfLastChange] = getdate()    
          ,[IdGenericStatus] = 2              
    WHERE IdExRateSchedule=@IdExRateSchedule

    set @HasError =0    
    SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE0')

end try
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DisableExRateSchedule_ExRateService]',Getdate(),@ErrorMessage)   
   set @HasError =1    
   SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE1')
End catch 
