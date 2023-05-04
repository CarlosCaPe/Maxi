create procedure [WellsFargo].st_SaveWFPIN
(   
    @IdCarrier int = null,
    @CelullarNumber nvarchar(1000)= null,
    @Email nvarchar(1000)= null,
    @PIN int,
    @EnterByIdUser int,
    @IdLenguage int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try

if @IdLenguage is null 
    set @IdLenguage=2 

declare @CellularNumberOLD nvarchar(max)
declare @EmailOLD nvarchar(max)
declare @IdCarrierOLD int
declare @IdUserOLD int
declare @EmailProfile nvarchar(max)
declare @body nvarchar(max)
declare @subject nvarchar(max)

select @IdUserOLD=enterbyiduser,@CellularNumberOLD=[CelullarNumber],@EmailOLD=[Email],@IdCarrierOLD=[IdCarrier] from [WellsFargo].WFPIN where enterbyiduser=@EnterByIdUser

if (isnull(@IdUserOLD ,0)!=0)
begin
    UPDATE [WellsFargo].WFPIN
        SET 
             [IdCarrier] = isnull(@IdCarrier,[IdCarrier])
            ,[CelullarNumber] = isnull(@CelullarNumber,[CelullarNumber])
            ,[Email] = isnull(@Email,[Email])
            ,[PIN] = @PIN
            ,[EnterByIdUser] = @EnterByIdUser            
            ,[DateOfLastChange] = getdate()
            ,[IdGenericStatus] = 1
    WHERE enterbyiduser=@EnterByIdUser
    /*
    select @subject = 'Wells Fargo Agent PIN has been changed'
    select @body = 'Dear User. Your Wells Fargo Agent PIN is:'+convert(varchar,@PIN)
    Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'   
    
    if (ltrim(rtrim(isnull(@EmailOLD,'')))!='')
    begin            
	        Insert into EmailCellularLog values (@EmailOLD,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @EmailOLD,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end

    if (ltrim(rtrim(isnull(@CellularNumberOLD,'')))!='' and @IdCarrierOLD is not null)
    begin          
         select @Email= Replace (Replace (Replace (Replace(@CellularNumberOLD,'-',''),' ',''),'(',''),')','')+Email  from carriers where idcarrier=@IdCarrierOLD

         Insert into EmailCellularLog values (@Email,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @Email,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end
    */

end
else
Begin
    INSERT INTO [WellsFargo].WFPIN
           (
            [IdCarrier]
           ,[CelullarNumber]
           ,[Email]
           ,[PIN]
           ,[EnterByIdUser]
           ,[CreationDate]
           ,[DateOfLastChange]
           ,[IdGenericStatus])
     VALUES
           (
            @IdCarrier
           ,@CelullarNumber
           ,@Email
           ,@PIN
           ,@EnterByIdUser
           ,getdate()
           ,getdate()
           ,1)
end

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SAVEWFPIN')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSAVEWFPIN')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_SaveWFPIN',Getdate(),@ErrorMessage)
End Catch
