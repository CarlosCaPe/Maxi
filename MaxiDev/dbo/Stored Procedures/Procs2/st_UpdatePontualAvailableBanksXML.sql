CREATE PROCEDURE [dbo].[st_UpdatePontualAvailableBanksXML]
(
    @AvailableBanks xml ,
    @IdUser int = 0 ,
    @IsSpanishLanguage bit = 1,
	@Id uniqueidentifier, 
    @HasError bit Output ,
    @Message varchar(5000) Output
)
AS
--declaracion de variables
Declare @DocHandle INT 
Declare @i int
Declare @BankID int, 
		@BankName varchar(250), 
		@LocationCode varchar(50), 
		@CountryBankCode varchar(50), 
		@SendInconsistencias bit, 
		@recipients varchar(200),
		@SendBody varchar (max);

Create Table #AvailableBanks
(
    Id int identity(1,1),
	LocationCode varchar(50),
	BankID int,
	BankName varchar(250),
	CountryBankCode varchar(50),
)

Create Table #AvailableBanksTemp
(
    Id int identity(1,1),
	BankID int,
	BankName varchar(250)
)

SET @HasError = 0;
SET @Message = '';

begin try

	INSERT INTO [MAXILOG].[dbo].[ServiceLogDetails] ([ServiceSummaryLogId],[Message],[Category],[DateLog], [XMLAvailableBanks]) 
		VALUES (@Id, 'Getting Available Banks', 'Information', GETDATE(), @AvailableBanks);

	--Inicializar Variables	

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @AvailableBanks;

	INSERT INTO #AvailableBanks (LocationCode, BankID,BankName,CountryBankCode)
		SELECT LocationCode, BankID,BankName,CountryBankCode
			FROM OPENXML (@DocHandle, '/Root/Location',2)
			With (
					LocationCode varchar(50),
					BankID int,
					BankName varchar(250),
					CountryBankCode varchar(50)
				);

	EXEC sp_xml_removedocument @DocHandle;

	while exists (select top 1 1 from #AvailableBanks)
	Begin

		if not exists (select top 1 1 from [dbo].[PontualAvailableBanks] PA 
							inner join [dbo].[Payer] P on PA.BankName = P.PayerName 
						where P.PayerCode = 'PONTUAL' 
							AND P.PayerName = @BankName 
							AND IdGenericStatus = 1)
		begin
			set @SendInconsistencias = 1;
			insert into #AvailableBanksTemp (BankID, BankName) values (@BankID, @BankName);
        end

		select top 1 
			@i= Id
			, @BankID = [BankID]
			, @LocationCode = LocationCode
			, @CountryBankCode = CountryBankCode
			, @BankName = BankName
		from #AvailableBanks

		if exists(SELECT TOP 1 1 FROM [dbo].[PontualAvailableBanks] with(nolock) where [BankID] = @BankID)
		BEGIN

			UPDATE [dbo].[PontualAvailableBanks] 
			SET 
				BankName = @BankName
				, DateOfLastChange = GETDATE()
				, LocationCode = @LocationCode
				, CountryBankCode = @CountryBankCode
			WHERE [BankID] = @BankID;
	
		END
		ELSE
		BEGIN

			insert into [dbo].[PontualAvailableBanks] (BankName, [BankID], [DateOfLastChange],[LocationCode], [CountryBankCode])
			values (@BankName,@BankID, GETDATE(), @LocationCode, @CountryBankCode);

		END

		delete from #AvailableBanks  where id = @i;

	end   

	set @SendBody = (select + 'The following banks were not related to payers: ' + STUFF((SELECT CAST('/  ' AS varchar(MAX)) + BankName FROM #AvailableBanksTemp ORDER BY BankName FOR XML PATH('')), 1, 1, ''));

    if (@SendInconsistencias = 1)
	BEGIN

		Declare @EmailProfile nvarchar(100);
		Select @EmailProfile = Value from GLOBALATTRIBUTES where Name='EmailProfiler';

		SET @recipients = ISNULL(
									(SELECT TOP 1 Value
										FROM [dbo].[GlobalAttributes] WITH(NOLOCK)
											WHERE [Name] = 'ListEmailUpdatePontual')
								,'soportemaxi@boz.mx');

		EXEC msdb.dbo.sp_send_dbmail  
			@profile_name = @EmailProfile,  -- Agregar perfil configurado
			@recipients = @recipients,  
			@body =  @SendBody,
			@body_format = 'HTML',
			@subject = 'Inconsistencies with Pontual Payers';  

	END

End Try
Begin Catch

	Set @HasError = 1;
	Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80);
	
	DECLARE @errorMessage NVARCHAR(4000) =  CONCAT('Line:', CONVERT(NVARCHAR(6),ERROR_LINE()),',Message:', ERROR_MESSAGE());	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) Values('[dbo].[st_UpdatePontualAvailableBanksXML]',Getdate(),@errorMessage);

End Catch