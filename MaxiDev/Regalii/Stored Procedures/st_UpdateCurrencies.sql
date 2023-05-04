
CREATE procedure [Regalii].[st_UpdateCurrencies]
    @Currencies XML,
    @JsonResponse varchar(max),
    @Error varchar(max) output
as

BEGIN TRY
declare  @DocHandle INT 
declare @Body nvarchar(max) = 'Regalii Rates: Process Complete'
declare @MessageMail nvarchar(max) = 'Regalii Rates: Process Complete'
Declare @recipients nvarchar (max)                        
Declare @EmailProfile nvarchar(max)    
Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailRegalliError'  
Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'     

    truncate table [Regalii].[Currencies]

	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		 VALUES ('Rates: Begin Load', getdate(),@jsonResponse)	

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@currencies
	INSERT INTO [Regalii].[Currencies] ([Currency], [Exchange],IdCurrency)
	SELECT code, exchangerate,[Regalii].[GetCurrencyfromCode](code)
	FROM OPENXML (@DocHandle, '/currencies/currency',2)
	With (
			code varchar(5),
			exchangerate money
	)       

	
	update [Regalii].[Currencies] set IdCurrency = (Select top 1 IdCurrency from Currency with(nolock) where CurrencyCode = Currency order by 1 desc)

    if exists (select top 1 1 from [Regalii].[Currencies] where idcurrency is null)
    begin
		DECLARE @CurrenciesError VARCHAR(1000)
		SELECT @CurrenciesError= COALESCE(@CurrenciesError + ', ', '') + Currency FROM  [Regalii].[Currencies] where idcurrency is null
        set @MessageMail = 'Regalii Rates: Error Load One or Many Currencies'
        set @Body ='Regalii Rates: Error Load One or Many Currencies ' + @CurrenciesError
        INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		VALUES ('Rates: Error', getdate(),@Body)
    end
    else
    begin
        if not exists (select top 1 1 from [Regalii].[Currencies] )
        begin
            set @MessageMail = 'Regalii Rates: Error Load Currencies Data'
            set @Body ='Regalii Rates: Error Load Currencies Data'
            INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		    VALUES ('Rates: Error', getdate(),@Body)
        end
    end


    EXEC msdb.dbo.sp_send_dbmail                          
                @profile_name=@EmailProfile,                                                     
                @recipients = @recipients,                                                          
                @body = @body,                                                           
                @subject = @MessageMail

    INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		 VALUES ('Rates: End Load', getdate(),'')

 End Try                                                                                            
Begin Catch

	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in Rates', GETDATE(),ISNULL(@jsonResponse,'Json Null'))
	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in Rates', GETDATE(),CONVERT(NVARCHAR(MAX),ISNULL(@Currencies,'Xml Null')))


    set @MessageMail = 'Regalii Rates: Error Load Currencies Data'
    set @Body ='Regalii Rates: Error Load Currencies Data'

        EXEC msdb.dbo.sp_send_dbmail                          
            @profile_name=@EmailProfile,                                                     
            @recipients = @recipients,                                                          
            @body = @body,                                                           
            @subject = @MessageMail
        
	set @Error ='Error in Regalii.st_UpdateCurrencies'
	Declare @ErrorMessage nvarchar(max) =ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalli.st_UpdateCurrencies',Getdate(),@ErrorMessage)                                                                                            
End Catch