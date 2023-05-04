CREATE Procedure [Corp].[st_SendDirectMessageForCall_msg]
(
    @IdAgent int,
    @MessageJSON nvarchar(max),
    @MessageTEXT nvarchar(max),
    @IdUser int,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
as
--Declaracion de variables
declare @IdMessageProvider int
DECLARE @Priority INT
DECLARE @IdMessage INT
declare @IdCallStatus int
declare @CurrentDate datetime

--Inicializacion de variables
SET @HasError=0
SET @Message='Operation Successfull'
set @Priority=1
set @IdMessageProvider=5
set @CurrentDate=dbo.RemoveTimeFromDatetime(getdate())

begin try
    if not exists (select top 1 1 from agent with(nolock) where idagentcommunication in (1,4) and idagent=@IdAgent)
    begin 
        Set @HasError=1                                                                                   
        Select @Message = 'Error Sending Message'
        return
    end

    EXEC @IdMessage = [Corp].[st_CreateMessageForAgent]
	        @IdAgent,
	        @IdMessageProvider,
	        @IdUser,
	        @MessageJSON,
	        @IsSpanishLanguage,
	        @HasError OUTPUT,
	        @Message OUTPUT
    

    IF (@HasError=0 AND @IdMessage>0)
    begin
        
        select top 1  @IdCallStatus=IdCallStatus from callhistory h with(nolock)
        where idagent=@IdAgent and h.DateOfLastChange>@CurrentDate and h.DateOfLastChange<@CurrentDate+1
        order by h.DateOfLastChange desc        

        set @IdCallStatus=isnull(@IdCallStatus,1)

        EXEC	[Corp].[st_AddNoteToCallHistory]
		        @IdAgent,
		        @IdUser,
		        @IdCallStatus,
		        @MessageTEXT,
		        @IsSpanishLanguage,
		        @HasError OUTPUT,
		        @Message OUTPUT,
                1
    end

end try
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = 'Error Sending Message'
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SendDirectMessageForCall_msg]',Getdate(),@ErrorMessage)    
END CATCH

