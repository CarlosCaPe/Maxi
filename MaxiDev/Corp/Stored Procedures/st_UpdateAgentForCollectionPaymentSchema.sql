CREATE PROCEDURE [Corp].[st_UpdateAgentForCollectionPaymentSchema]
(
    @IdLenguage int,
    @EnterByIdUser int,
    @IdAgent int,
    @DonOnMonday int,
    @DonOnTuesday int,
    @DonOnWednesday int,
    @DonOnThursday int,
    @DonOnFriday int,
    @DonOnSaturday int,
    @DonOnSunday int,
    @HasError bit OUTPUT,
	@Message nvarchar(max) OUTPUT      
)
as
Begin Try 

declare @IsSpanishLenguage bit

set @IsSpanishLenguage = case when isnull(@IdLenguage,1)=1 then 0 else 1 end
    --Guardar Mirror
    Exec [Corp].[st_SaveAgentMirror] @IdAgent
    
    --Actualizar datos
    update agent set
       [DoneOnSundayPayOn] = @DonOnSunday
      ,[DoneOnMondayPayOn] = @DonOnMonday
      ,[DoneOnTuesdayPayOn] = @DonOnTuesday
      ,[DoneOnWednesdayPayOn] = @DonOnWednesday
      ,[DoneOnThursdayPayOn] = @DonOnThursday
      ,[DoneOnFridayPayOn] = @DonOnFriday
      ,[DoneOnSaturdayPayOn] = @DonOnSaturday
      ,[DateOfLastChange] = getdate()
      ,[EnterByIdUser] = @EnterByIdUser
    where idagent=@IdAgent
    Set @HasError=0 
    SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLenguage,81)
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLenguage,33)
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_UpdateAgentForCollectionPaymentSchema',Getdate(),@ErrorMessage)                                                                                            
End Catch
