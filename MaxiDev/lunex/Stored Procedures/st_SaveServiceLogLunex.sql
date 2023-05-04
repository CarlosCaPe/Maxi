CREATE procedure [lunex].[st_SaveServiceLogLunex]
(
    @TransactionID bigint,
    @IsSuccess bit,
    @Response nvarchar(max),
    @Request nvarchar(max),
    @HasError bit out
)
AS
/********************************************************************
<Author> </Author>
<app>Services</app>
<Description>Envia notificacion cuando hay un error en lunex</Description>

<ChangeLog>
<log Date="26/06/2017" Author="fgonzalez">Se reemplaza el envio de correo por el mailqueue</log>
<log Date="21/07/2017" Author="fgonzalez">Se evita que se manden correos de transacciones duplicadas</log>
</ChangeLog>

*********************************************************************/
Begin Try  
declare @Message nvarchar(max)
declare @Body nvarchar(max)
declare @Salto nvarchar(max) = char(13)+char(10)

     INSERT INTO [Lunex].[ServiceLogLunex]
           ([Request]
           ,[Response]
           ,[IsSuccess]
           ,[TransactionID]
           ,[DateLastChange])
     VALUES
           (@Request
           ,@Response
           ,@IsSuccess
           ,@TransactionID	
           ,getdate())

	
	if (@TransactionID=39946280) return

    if (@IsSuccess=0)
    begin
        set @Message = 'Lunex error in TransactionID: '+convert(nvarchar,@TransactionID)
        set @Body = @Message+@Salto+@Salto+'Lunex Request:'+@Salto+@Salto+@Request+@Salto+@Salto+'Lunex Response:'+@Salto+@Salto+@Response
        
        Declare @recipients nvarchar (max)                        
        Declare @EmailProfile nvarchar(max)    

        Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailErrorsLunex'  
        Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'  
    
           
        DECLARE @ProcID VARCHAR(200)
		SET @ProcID =OBJECT_NAME(@@PROCID)
		
		IF (@body NOT LIKE '%Transaction already exists%') BEGIN 
		
				IF NOT EXISTS (SELECT 1 FROM MailQueue WHERE MsgRecipient =@recipients AND  Subject =@Message AND Source=@ProcID) BEGIN 
					
					EXEC sp_MailQueue 
					@Source   =  @ProcID,
					@To 	  =  @recipients,      
					@Subject  =  @Message,
					@Body  	  =  @body
					
				END 
		END 
		
    end
	

    set @HasError = 0
End Try                                                                                            
Begin Catch                                                                                       
 Set @HasError=1                                                                                     
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Lunex.st_SaveServiceLogLunex',Getdate(),@ErrorMessage)                                                                                            
End Catch 
