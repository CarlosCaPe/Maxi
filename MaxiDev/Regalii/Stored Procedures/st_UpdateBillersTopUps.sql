CREATE procedure [Regalii].[st_UpdateBillersTopUps]
    @Billers XML,
    @JsonResponse varchar(max),
    @Error varchar(max) output
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez">Sp que actualiza los TopUps para Regalii mediante funcion MERGE</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
declare  @DocHandle INT 
declare @IdOtherProduct int = (Select top 1 IdOtherProducts from OtherProducts with(nolock) where Description = 'Regalii Top Up')
declare @Body varchar(max) = 'Regalii BillersTopUps: Process Complete'
declare @MessageMail varchar(max) = 'Regalii BillersTopUps: Process Complete'
Declare @recipients varchar (max)                        
Declare @EmailProfile varchar(max)    
Select @recipients=Value from GLOBALATTRIBUTES with(nolock) where Name='ListEmailRegalliError'  
Select @EmailProfile=Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler'  
declare @BillerTypeCell varchar(500) = (select Value from GlobalAttributes with(nolock) where Name='RegaliiBillerTypeCell')

	    
    INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		 VALUES ('BillersTopUps: Begin Load', getdate(),@jsonResponse)	

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Billers

	DECLARE @tableBillersArcus AS TABLE 
	(
		IdBiller INT ,
		Name varchar(MAX) ,
		Country varchar(MAX),
		BillerType varchar(MAX),
		CanCheckBalance bit,
		SupportsPartialPayments bit,
		RequiresNameOnAccount bit,
		AvailableTopupAmounts varchar(MAX),
		HoursToFulfill varchar(MAX),
		LocalCurrency varchar(MAX),
		AccountNumberDigits varchar(MAX),
		Mask varchar(MAX),
		BillType varchar(MAX),
		IdCountry int, 
		IdCurrency int,
		TopUpCommission money,
		IdGenericStatus int
	)

	INSERT INTO @tableBillersArcus
	(	
		IdBiller  ,
		Name  ,
		Country ,
		BillerType ,
		CanCheckBalance ,
		SupportsPartialPayments ,
		RequiresNameOnAccount ,
		AvailableTopupAmounts ,
		HoursToFulfill ,
		LocalCurrency ,
		AccountNumberDigits ,
		Mask ,
		BillType ,
		IdCountry , 
		IdCurrency ,
		TopUpCommission,
		IdGenericStatus
	)
	SELECT 
		id ,
		REPLACE(name, ' - Buena comision agente' ,''),
		country ,
		biller_type ,
		can_check_balance ,
		supports_partial_payments ,
		requires_name_on_account ,
		available_topup_amounts ,
		hours_to_fulfill ,
		local_currency ,
		account_number_digits ,
		mask ,
		bill_type,
		[Regalii].GetCountryId(country),
		[Regalii].GetCurrencyId(local_currency) ,
		topup_commission,
		1
	FROM OPENXML (@DocHandle, '/billers/biller',2)
	With (
		id int,
		name varchar(500),
		country varchar(500),
		biller_type varchar(500),
		can_check_balance bit,
		supports_partial_payments bit,
		requires_name_on_account bit,
		available_topup_amounts varchar(500),
		hours_to_fulfill varchar(500),
		local_currency varchar(500),
		account_number_digits varchar(500),
		mask varchar(500),
		bill_type varchar(500),
		topup_commission money,
		IdGenericStatus int
	)
	WHERE available_topup_amounts != '' or biller_type like '__Cell' or bill_type in ('Cell')


	--Sincronizar la tabla TARGET con
	--los datos actuales de la tabla SOURCE
	MERGE Regalii.Billers AS TARGET
	USING @tableBillersArcus AS SOURCE 
	ON (TARGET.IdBiller = SOURCE.IdBiller) 
	--Cuandos los registros concuerdan por la llave se actualizan los registros si tienen alguna variación en alguno de sus campos
	WHEN MATCHED AND TARGET.Name <> SOURCE.Name 
	OR TARGET.Country <> SOURCE.Country
	OR TARGET.BillerType <> SOURCE.BillerType
	OR TARGET.CanCheckBalance <> SOURCE.CanCheckBalance
	OR TARGET.SupportsPartialPayments <> SOURCE.SupportsPartialPayments
	OR TARGET.RequiresNameOnAccount <> SOURCE.RequiresNameOnAccount
	OR TARGET.AvailableTopupAmounts <> SOURCE.AvailableTopupAmounts
	OR TARGET.HoursToFulfill <> SOURCE.HoursToFulfill
	OR TARGET.LocalCurrency <> SOURCE.LocalCurrency
	OR TARGET.AccountNumberDigits <> SOURCE.AccountNumberDigits
	OR TARGET.Mask <> SOURCE.Mask
	OR TARGET.BillType <> SOURCE.BillType
	OR TARGET.TopUpCommission <> SOURCE.TopUpCommission
	OR TARGET.IdGenericStatus <> 1
	and (TARGET.AvailableTopupAmounts != '' or TARGET.BillerType like '__Cell%' or TARGET.BillerType in ('Cell'))
	THEN UPDATE SET TARGET.Name = SOURCE.Name, 
	TARGET.Country = SOURCE.Country,
	TARGET.BillerType = SOURCE.BillerType,
	TARGET.CanCheckBalance = SOURCE.CanCheckBalance,
	TARGET.SupportsPartialPayments = SOURCE.SupportsPartialPayments,
	TARGET.RequiresNameOnAccount = SOURCE.RequiresNameOnAccount,
	TARGET.AvailableTopupAmounts = SOURCE.AvailableTopupAmounts,
	TARGET.HoursToFulfill = SOURCE.HoursToFulfill,
	TARGET.LocalCurrency = SOURCE.LocalCurrency,
	TARGET.AccountNumberDigits = SOURCE.AccountNumberDigits,
	TARGET.Mask = SOURCE.Mask,
	TARGET.BillType = SOURCE.BillType,
	TARGET.TopUpCommission = SOURCE.TopUpCommission,
	TARGET.DateOfLastChange = GETDATE(),
	TARGET.IdOtherProduct = @IdOtherProduct,
	TARGET.IdGenericStatus = 1
	--Cuando los registros no concuerdan por la llave indica que es un dato nuevo, se inserta el registro en la tabla TARGET proveniente de la tabla SOURCE
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT ([IdBiller],[Name],[Country],[BillerType],[CanCheckBalance],[SupportsPartialPayments],[RequiresNameOnAccount],[AvailableTopupAmounts],[HoursToFulfill],[LocalCurrency],[AccountNumberDigits],[Mask],[BillType],[TopUpCommission],IdGenericStatus, DateOfLastChange, IdOtherProduct) 
	VALUES (SOURCE.IdBiller, SOURCE.Name, SOURCE.Country,SOURCE.BillerType,SOURCE.CanCheckBalance,SOURCE.SupportsPartialPayments,SOURCE.RequiresNameOnAccount,SOURCE.AvailableTopupAmounts,SOURCE.HoursToFulfill,SOURCE.LocalCurrency,SOURCE.AccountNumberDigits,SOURCE.Mask,SOURCE.BillType,SOURCE.TopUpCommission,1, GETDATE(),@IdOtherProduct)
	--Cuando el registro existe en TARGET y no existe en SOURCE se deshabilita el registro en TARGET
	WHEN NOT MATCHED BY SOURCE and (TARGET.AvailableTopupAmounts != '' or TARGET.BillType like '__Cell' or TARGET.BillerType in ('Cell')) THEN 
	UPDATE SET TARGET.IdGenericStatus = 2,
	TARGET.DateOfLastChange = GETDATE();


	DECLARE @tableBillers AS TABLE 
	(
	Id INT NOT NULL identity PRIMARY KEY,
	IdBiller INT 
	)

	Insert into @tableBillers
	Select 
		IdBiller 
	From Regalii.Billers with(nolock) where IdGenericStatus = 1 --where AvailableTopupAmounts != '' or BillerType like '__Cell' OR BillerType in ('Cell')
	
	--SELECT * FROM @tableBillers
	--Select Count(Id) From @tableBillers

	declare @Id int = 1
	declare @IdTot int = (Select Count(Id) From @tableBillers)
	declare @IdBiller int = 0
	
	While (@Id <= @IdTot)
	Begin
	Select @IdBiller = IdBiller from @tableBillers where Id = @Id
	--print 'IdBiller:' + cast(@IdBiller as varchar(6))
	Update Regalii.Billers set IdCountry = (Select [Regalii].GetCountryId((Select Country from Regalii.Billers with(nolock) where IdBiller = @IdBiller))) where IdBiller = @IdBiller
	--print 'IdBiller:' + cast(@IdBiller as varchar(2))
	Update Regalii.Billers set LocalCurrency = ISNULL((Select [Regalii].GetCurrency((Select Country from Regalii.Billers with(nolock) where IdBiller = @IdBiller))),'') where IdBiller = @IdBiller
	Update Regalii.Billers set IdCurrency = (Select [Regalii].GetCurrencyId((Select Country from Regalii.Billers with(nolock) where IdBiller = @IdBiller))) where IdBiller = @IdBiller
	Set @Id = @Id + 1
	set @IdBiller = 0
	End



	select  B.Country, B.AccountNumberDigits
	into #TempCellLenght
	from Regalii.Billers B with(nolock)
	where B.billerType=@BillerTypeCell
	group by B.Country, B.AccountNumberDigits

	Update CM set CM.PhoneLenght=T.AccountNumberDigits
	from [Regalii].[CountryMap] CM with(nolock)
		inner join #TempCellLenght  T on T.Country=CM.RegaliiCountryName

	update [Regalii].[CountryMap]
	set PhoneCode = c.Prefix--, PhoneLenght = c.PhoneLength
	from [Regalii].[CountryMap] a with(nolock)
	inner join Country b with(nolock) on a.CountryCode = b.CountryCode
	inner join DialingCodePhoneNumber c with(nolock) on c.IdCountry = b.IdCountry

	if exists (select top 1 1 from [Regalii].[Billers] with(nolock) where idcurrency is null and (AvailableTopupAmounts != '' or BillerType like '__Cell' OR BillerType in ('Cell')))--AND BillerType like '__Cell%' and BillerType in ('Cell'))
    begin
        set @MessageMail = 'BillersTopUps: Error Load One or Many Currencies'
        set @Body ='Regalii BillersTopUps: Error Load One or Many Currencies'
        INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		VALUES ('Billers: Error', getdate(),@Body)
    end
    else
    begin
        if exists (select top 1 1 from [Regalii].[Billers] with(nolock) where idcountry is null AND (AvailableTopupAmounts != ''or BillerType like '__Cell' OR BillerType in ('Cell')))--AND BillerType like '__Cell%' and BillerType in ('Cell'))
        begin
            set @MessageMail = 'Regalii BillersTopUps: Error Load One or Many Countries'
            set @Body ='Regalii BillersTopUps: Error Load One or Many Countries'
            INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		    VALUES ('BillersTopUps: Error', getdate(),@Body)
        end
        else
        begin
            if not exists (select top 1 1 from [Regalii].[Billers] with(nolock) )
            begin
                set @MessageMail = 'Regalii BillersTopUps: Error Load BillersTopUps Data'
                set @Body ='Regalii Billers: BillersTopUps Load BillersTopUps Data'
                INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		        VALUES ('BillersTopUps: Error', getdate(),@Body)
            end
            else
            begin
                if exists (select top 1 1 from [Regalii].[Billers] with(nolock) where CanCheckBalance=0 and SupportsPartialPayments=0 AND AvailableTopupAmounts != '')--AND BillerType like '__Cell%' and BillerType in ('Cell'))
                begin
                    set @MessageMail = 'Regalii BillersTopUps: Error BillersTopUps Data Review Data CanCheckBalance and SupportsPartialPayments'
                    set @Body ='Regalii BillersTopUps: Error BillersTopUps Data Review Data CanCheckBalance and SupportsPartialPayments'
                    INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		            VALUES ('BillersTopUps: Error', getdate(),@Body)
                end
				else
				begin
					if( exists (select 1 from #TempCellLenght group by country having count(1)>1))
					begin
						set @MessageMail = 'Regalii BillersTopUps: Error BillersTopUps Data'
						set @Body ='Regalii BillersTopUps: Error BillersTopUps Data diferent AccountNumberDigits for country'
						INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
						VALUES ('BillersTopUps: Error', getdate(),@Body)
					end
					else
					begin
						if( exists (select 1 from #TempCellLenght where ISNUMERIC(AccountNumberDigits)<>1) )
						begin
							set @MessageMail = 'Regalii BillersTopUps: Error BillersTopUps Data'
							set @Body ='Regalii BillersTopUps: Error BillersTopUps Data AccountNumberDigits not numeric check Transaction.BeneficiaryPhoneNumberChange'
							INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
							VALUES ('BillersTopUps: Error', getdate(),@Body)
						end
					End
				end
            end
        end
    end

    EXEC msdb.dbo.sp_send_dbmail                          
                @profile_name=@EmailProfile,                                                     
                @recipients = @recipients,                                                          
                @body = @body,                                                           
                @subject = @MessageMail

    INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail])
		 VALUES ('BillersTopUps: End Load', getdate(),'')	

 End Try                                                                                            
Begin Catch
	
	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in BillersTopUps', GETDATE(),ISNULL(@jsonResponse,'Json Null'))
	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in BillersTopUps', GETDATE(),CONVERT(NVARCHAR(MAX),ISNULL(@Billers,'Xml Null')))

    set @MessageMail = 'Regalii BillersTopUps: Error Load BillersTopUps Data'
    set @Body ='Regalii BillersTopUps: Error Load BillersTopUps Data'

        EXEC msdb.dbo.sp_send_dbmail                          
            @profile_name=@EmailProfile,                                                     
            @recipients = @recipients,                                                          
            @body = @body,                                                           
            @subject = @MessageMail
    
	set @Error ='Error in Regalii.st_UpdateBillersTopUps'
	Declare @ErrorMessage nvarchar(max) =ERROR_MESSAGE()      
	Declare @Line varchar(10) = convert(varchar(10), Error_Line());                                       
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalli.st_UpdateBillersTopUps ('+@Line+')',Getdate(),@ErrorMessage)                                                                                            
End Catch