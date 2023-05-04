CREATE PROCEDURE [Corp].[st_SENDKYCCheckMessage_msg]
(	
	@IdCheck int,
    @MessageTEXT nvarchar(max),
    @IdUser int,
    @IsSpanishLanguage INT,
	@IsReleasedFromVerifyHold bit,
    @HasError BIT OUTPUT,
    @Message varchar(max) OUTPUT
)
as
--Declaracion de variables
DECLARE @IdAgent int
DECLARE @IdMessageProvider int
DECLARE @IdMessage INT
DECLARE @IdCallStatus int
DECLARE @IsReleased varchar(10)
DECLARE @MessageJSON varchar(MAX)
DECLARE @IdUserCheckCreator int
DECLARE @CustomerName varchar(MAX)
DECLARE @Folio varchar(MAX)
DECLARE @DateOfTransfer varchar(MAX)
DECLARE @AgentCode varchar(max)
DECLARE @AgentName varchar(MAX)
DECLARE @Claimcheck varchar(max)
DECLARE @CheckNumber varchar(20)
--Inicializacion de variables

SET @HasError=1
SET @Message='Error Trying to send notification'
SET @IdMessageProvider = 6
SET @IsReleased = (select CASE When @IsReleasedFromVerifyHold = 1 Then 'true' else 'false' end)
--SET @IdAgent = (select IdAgent from checks where IdCheck = @IdCheck)
SET @IdUserCheckCreator = (select EnteredByIdUser from checks where IdCheck = @IdCheck)
SET @CustomerName = (select (Name + ' '+ FirstLastName + ' ' + SecondLastName) as Name from checks where IdCheck = @IdCheck)
SET @Folio = (select IdCheck from checks where IdCheck = @IdCheck)
SET @DateOfTransfer = (select DateOfMovement from checks where IdCheck = @IdCheck)

select 
@IdAgent = c.IdAgent, 
@CheckNumber = c.CheckNumber,
@AgentName = a.AgentName,
@AgentCode = a.AgentCode,
@Claimcheck = c.ClaimCheck
from checks c 
join Agent a on a.idAgent = c.IdAgent
where c.IdCheck = @IdCheck


if(@IsReleased = 'true')
	Begin 
		SET @MessageJSON = '{"IdCheck":'+(select CONVERT(varchar(20), @IdCheck))+',"IdMessageSource":1,"IsIntrusive":true,"Message":"'+ @MessageTEXT + '|' + @CheckNumber + '","CanClose":true, "MessageUs": "Operation Approved","MessageES":"Operación Aprobada", "IsReleased":'+@IsReleased+',"EnteredByIdUser":'+(select CONVERT(varchar(20), @IdUserCheckCreator))+',"Folio":"'+@Folio+'","CustomerName":"'+@CustomerName+'","DateOfTransfer":"'+@DateOfTransfer+'"}'
	End
Else 
	Begin 
		SET @MessageJSON = '{"IdCheck":'+(select CONVERT(varchar(20), @IdCheck))+',"IsRejectCheck":true,"IdMessageSource":1,"IsIntrusive":true,"Message":"'+ @MessageTEXT + '|' + @CheckNumber +'","CanClose":true, "MessageUs": "Operation Rejected","MessageES":"Operación Rechazada","IsReleased":'+@IsReleased+',"EnteredByIdUser":'+(select CONVERT(varchar(20), @IdUserCheckCreator))+',"Folio":"'+@Folio+'","CustomerName":"'+@CustomerName+'","DateOfTransfer":"'+@DateOfTransfer+'"}'
	End

begin try
    if not exists (select top 1 1 from agent where idagentcommunication in (1,4) and idagent=@IdAgent)
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
	        @HasError = @HasError OUTPUT,
			@Message = @Message OUTPUT

	SET @HasError=0
	SET @Message='Operation Successfull'

end try
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = 'Error Sending Message'
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SENDKYCCheckMessage_msg]',Getdate(),@ErrorMessage)    
END CATCH
