CREATE procedure [dbo].[st_SaveTransferOFACInfo]
(
    @IdTransfer int,    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),    
    @BeneficiaryName nvarchar(max),
    @BeneficiaryFirstLastName nvarchar(max),
    @BeneficiarySecondLastName nvarchar(max),
    @IsOLDTransfer bit,
    @IsOFAC bit out,
    @IsOFACDoubleVerification bit out
	,@PercentMatchOfac float out  /*Requerimiento_013017-2*/ 
)
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="04/09/2020" Author="jsierra" Name="">Se agrega nuevo algoritmo de OFAC</log>
</ChangeLog>
*********************************************************************/
declare     
            @CustomerPercentMatch float=0,    
            @BeneficiaryPercentMatch float=0,
            @PercentDoubleVerification float = 0,
            @xmlDataCustomer xml,
            @xmlDataBeneficiary xml,
            @PercentOfacMatchBit float,
            @PercentOfac float,
            @IsCustomerFullMatch bit = 0,
            @IsBeneficiaryFullMatch bit = 0,
            @IsCustomerOldProccess BIT = 0,
            @IsBeneficiaryOldProccess BIT = 0,
			@UseMaxiOFAC BIT = 0

begin try

IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatch' AND ga.Value = '1')
	SET @UseMaxiOFAC = 1

if exists (select top 1 1 from [TransferOFACInfo] where idtransfer=@IdTransfer) return

select  @PercentOfacMatchBit=[dbo].[GetGlobalAttributeByName]('PercentOfacMatchBit'), 
        @PercentOfac=case when @IsOLDTransfer=1 then 70 else [dbo].[GetGlobalAttributeByName]('MinOfacMatch') end,
        @IsOFAC=0,
        @IsOFACDoubleVerification=0,
        @PercentDoubleVerification=[dbo].[GetGlobalAttributeByName]('PercentOfacDoubleVerification')        

/*Customer*/
Declare @CustomerPercentDataMatch table
(
    name nvarchar(max),
    percentMatch float,
    IsCustomerFullMatch bit not null default 0
)

Declare @CustomerDataMatch table
(
    SDN_NAME nvarchar(max),
    SDN_REMARKS nvarchar(max),
    ALT_TYPE nvarchar(max),
    ALT_NAME nvarchar(max),
    ALT_REMARKS nvarchar(max),
    ADD_ADDRESS nvarchar(max),
    ADD_CITY_NAME nvarchar(max),
    ADD_COUNTRY nvarchar(max),
    ADD_REMARKS nvarchar(max),
    FULL_Match bit not null default 0,
    Percent_Match NUMERIC(9, 2) not null default 0
)

declare @EntNumCus table
(
    ent_num bigint,
    fullname nvarchar(max),
    IsFullMatch bit not null default 0
)

if ltrim(rtrim(dbo.fn_EspecialChrOFF(@CustomerSecondLastName)))=''
begin
    insert into @EntNumCus
    select ent_num,sdn_name fullname,1 from ofac_sdn where SDN_PrincipalName=@CustomerName and SDN_FirstLastName = @CustomerFirstLastName
    union 
    select ent_num,alt_name fullname,1 from ofac_alt where alt_PrincipalName=@CustomerName and alt_FirstLastName = @CustomerFirstLastName

    insert into @EntNumCus
    select ent_num,sdn_name fullname,0 from ofac_sdn where SDN_PrincipalName like '%'+@CustomerName+'%'	and SDN_FirstLastName like '%'+@CustomerFirstLastName+'%' and ent_num not in (select ent_num from @EntNumCus)
    union 
    select ent_num,alt_name fullname,0 from ofac_alt where alt_PrincipalName like '%'+@CustomerName+'%'	and alt_FirstLastName like '%'+@CustomerFirstLastName+'%' and ent_num not in (select ent_num from @EntNumCus)
end


if exists(select top 1 1 from @EntNumCus)
BEGIN
    SET @IsCustomerOldProccess = 1

    if exists(select top 1 1 from @EntNumCus where IsFullMatch=1)
    begin
        set @CustomerPercentMatch = 100
        set @IsCustomerFullMatch = 1
    end
    else
    begin
        set @CustomerPercentMatch = @PercentOfac
    end
        
    insert into @CustomerPercentDataMatch
    select sdn_name,@CustomerPercentMatch,0 from ofac_sdn where ent_num in(select ent_num from @EntNumCus)    
    
    insert into @CustomerDataMatch    
    SELECT SDN_NAME, ISNULL(REMARKS,'') SDN_REMARKS,ISNULL(ALT_TYPE,'') ALT_TYPE,ISNULL(ALT_NAME,'') ALT_NAME, ISNULL(ALT_REMARKS,'') ALT_REMARKS,isnull(ADDRESS,'') ADD_ADDRESS,isnull(CITY_NAME,'') ADD_CITY_NAME,isnull(COUNTRY,'') ADD_COUNTRY,isnull(ADD_REMARKS,'') ADD_REMARKS,0,0 FROM OFAC_SDN
    LEFT join OFAC_ALT ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM
    LEFT JOIN OFAC_ADD ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
    WHERE OFAC_SDN.ENT_NUM in (select ent_num from @EntNumCus)   
    
    if not exists(select top 1 1 from @CustomerDataMatch where alt_name='')
        begin
        insert into @CustomerDataMatch
            (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
        select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @CustomerDataMatch
        end
        else
        begin
            update @CustomerDataMatch set alt_name=SDN_NAME where alt_name=''
        end 
                
        update @CustomerDataMatch set Percent_Match=@CustomerPercentMatch where ALT_NAME in (select fullname from @EntNumCus)
        update @CustomerDataMatch set FULL_Match=1 where ALT_NAME in (select fullname from @EntNumCus where IsFullMatch=1)

    set @xmlDataCustomer=(select *,'Comparison' Method  from @CustomerDataMatch FOR XML RAW,ROOT('OFACInfo'))
end
else
begin
	
	IF @UseMaxiOFAC = 1
	BEGIN
		EXEC st_MaxiOFACValidateEntity
			@CustomerName,
			@CustomerFirstLastName,
			@CustomerSecondLastName,
			@CustomerPercentMatch	OUT,
			@IsCustomerFullMatch	OUT,
			@xmlDataCustomer		OUT
	END
	ELSE
	BEGIN
		insert into @CustomerPercentDataMatch
		(name,percentMatch)
		exec [st_OfacSearchDetailsLetterPairsByNameClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName

		delete from @CustomerPercentDataMatch where percentMatch<@PercentOfac

		update @CustomerPercentDataMatch set IsCustomerFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end

		select top 1 @CustomerPercentMatch=percentMatch,@IsCustomerFullMatch=IsCustomerFullMatch from @CustomerPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

		if @CustomerPercentMatch>=@PercentOfac
		begin
			insert into @CustomerDataMatch
			(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
			exec [st_OfacSearchDetailsLetterPairsClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName

			if not exists(select top 1 1 from @CustomerDataMatch where alt_name='')
			begin
			insert into @CustomerDataMatch
				(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
			select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @CustomerDataMatch
			end
			else
			begin
				update @CustomerDataMatch set alt_name=SDN_NAME where alt_name=''
			end

			update @CustomerDataMatch set Full_Match=t.IsCustomerFullMatch,Percent_Match=t.percentMatch
			from 
			(select * from @CustomerPercentDataMatch) t
			where alt_name=t.name

			set @xmlDataCustomer=(select *,'Percent' Method from @CustomerDataMatch FOR XML RAW,ROOT('OFACInfo'))
		end
	END
end

/*Beneficiary*/
Declare @BeneficiaryPercentDataMatch table
(
    name nvarchar(max),
    percentMatch float,
    IsBeneficiaryFullMatch bit not null default 0
)

Declare @BeneficiaryDataMatch table
(
    SDN_NAME nvarchar(max),
    SDN_REMARKS nvarchar(max),
    ALT_TYPE nvarchar(max),
    ALT_NAME nvarchar(max),
    ALT_REMARKS nvarchar(max),
    ADD_ADDRESS nvarchar(max),
    ADD_CITY_NAME nvarchar(max),
    ADD_COUNTRY nvarchar(max),
    ADD_REMARKS nvarchar(max),
    FULL_Match bit not null default 0,
    Percent_Match NUMERIC(9, 2) not null default 0
)

declare @EntNumBen table
(
    ent_num bigint,
    fullname nvarchar(max),
    IsFullMatch bit not null default 0
)

if ltrim(rtrim(dbo.fn_EspecialChrOFF(@BeneficiarySecondLastName)))=''
begin
    insert into @EntNumBen
    select ent_num,sdn_name fullname,1 from ofac_sdn where SDN_PrincipalName=@BeneficiaryName and SDN_FirstLastName = @BeneficiaryFirstLastName
    union 
    select ent_num,alt_name fullname,1 from ofac_alt where alt_PrincipalName=@BeneficiaryName and alt_FirstLastName = @BeneficiaryFirstLastName

    insert into @EntNumBen
    select ent_num,SDN_name fullname,0 from ofac_sdn where SDN_PrincipalName like '%'+@BeneficiaryName+'%'	and SDN_FirstLastName like '%'+@BeneficiaryFirstLastName+'%' and ent_num not in (select ent_num from @EntNumBen)
    union 
    select ent_num,alt_name fullname,0 from ofac_alt where alt_PrincipalName like '%'+@BeneficiaryName+'%'	and alt_FirstLastName like '%'+@BeneficiaryFirstLastName+'%' and ent_num not in (select ent_num from @EntNumBen)
end

if exists(select top 1 1 from @EntNumBen)
BEGIN
    SET @IsBeneficiaryOldProccess = 1

    if exists(select top 1 1 from @EntNumBen where IsFullMatch=1)
    begin
        set @BeneficiaryPercentMatch = 100
        set @IsBeneficiaryFullMatch = 1
    end
    else
    begin
        set @BeneficiaryPercentMatch = @PercentOfac
    end

    insert into @BeneficiaryPercentDataMatch
    select sdn_name,@BeneficiaryPercentMatch,0 from ofac_sdn where ent_num in(select ent_num from @EntNumBen)    
    
    insert into @BeneficiaryDataMatch    
    SELECT SDN_NAME, ISNULL(REMARKS,'') SDN_REMARKS,ISNULL(ALT_TYPE,'') ALT_TYPE,ISNULL(ALT_NAME,'') ALT_NAME, ISNULL(ALT_REMARKS,'') ALT_REMARKS,isnull(ADDRESS,'') ADD_ADDRESS,isnull(CITY_NAME,'') ADD_CITY_NAME,isnull(COUNTRY,'') ADD_COUNTRY,isnull(ADD_REMARKS,'') ADD_REMARKS,0,0 FROM OFAC_SDN
    LEFT join OFAC_ALT ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM
    LEFT JOIN OFAC_ADD ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
    WHERE OFAC_SDN.ENT_NUM in (select ent_num from @EntNumBen)

     if not exists(select top 1 1 from @BeneficiaryDataMatch where alt_name='')
        begin
        insert into @BeneficiaryDataMatch
            (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
        select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @BeneficiaryDataMatch
        end
        else
        begin
            update @BeneficiaryDataMatch set alt_name=SDN_NAME where alt_name=''
        end

    update @BeneficiaryDataMatch set Percent_Match=@BeneficiaryPercentMatch where ALT_NAME in (select fullname from @EntNumBen)
    update @BeneficiaryDataMatch set FULL_Match=1 where ALT_NAME in (select fullname from @EntNumBen where IsFullMatch=1)

    set @xmlDataBeneficiary=(select *,'Comparison' Method from @BeneficiaryDataMatch FOR XML RAW,ROOT('OFACInfo'))
end
else
begin

	IF @UseMaxiOFAC = 1
	BEGIN
		EXEC st_MaxiOFACValidateEntity
			@BeneficiaryName,
			@BeneficiaryFirstLastName,
			@BeneficiarySecondLastName,
			@BeneficiaryPercentMatch	OUT,
			@IsBeneficiaryFullMatch		OUT,
			@xmlDataBeneficiary			OUT
	END
	ELSE
	BEGIN
		insert into @BeneficiaryPercentDataMatch
		(name,percentMatch)
		exec [st_OfacSearchDetailsLetterPairsByNameClr] @BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName

		delete from @BeneficiaryPercentDataMatch where percentMatch<@PercentOfac

		update @BeneficiaryPercentDataMatch set IsBeneficiaryFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end

		select top 1 @BeneficiaryPercentMatch=percentMatch,@IsBeneficiaryFullMatch=IsBeneficiaryFullMatch from @BeneficiaryPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

		if @BeneficiaryPercentMatch>=@PercentOfac
		begin
			insert into @BeneficiaryDataMatch
			(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
			exec [st_OfacSearchDetailsLetterPairsClr] @BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName

			if not exists(select top 1 1 from @BeneficiaryDataMatch where alt_name='')
			begin
			insert into @BeneficiaryDataMatch
				(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
			select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @BeneficiaryDataMatch
			end
			else
			begin
				update @BeneficiaryDataMatch set alt_name=SDN_NAME where alt_name=''
			end

			update @BeneficiaryDataMatch set Full_Match=t.IsBeneficiaryFullMatch,Percent_Match=t.percentMatch
			from 
			(select * from @BeneficiaryPercentDataMatch) t
			where alt_name=t.name

			set @xmlDataBeneficiary=(select *,'Percent' Method from @BeneficiaryDataMatch FOR XML RAW,ROOT('OFACInfo'))
		end
	END
end


/*S09:Requerimiento_013017-2*/
SET @PercentMatchOfac = 0;
IF(@CustomerPercentMatch>@BeneficiaryPercentMatch)
BEGIN
	SET @PercentMatchOfac = @CustomerPercentMatch;
END
ELSE
BEGIN
	SET @PercentMatchOfac = @BeneficiaryPercentMatch;
END
/**/

if (@CustomerPercentMatch>=@PercentOfac) or (@BeneficiaryPercentMatch>=@PercentOfac)
begin
set @IsOFAC=1

if (@CustomerPercentMatch>=@PercentDoubleVerification) or (@BeneficiaryPercentMatch>=@PercentDoubleVerification)
begin
    set @IsOFACDoubleVerification=1
end 

if (@IsOLDTransfer=1)
begin
    set @IsOFACDoubleVerification=0
    set @PercentDoubleVerification=0
    set @PercentOfac=70
end

INSERT INTO [dbo].[TransferOFACInfo]
           ([IdTransfer]           
           ,[CustomerOfacPercent]
           ,[CustomerMatch]           
           ,[BeneficiaryOfacPercent]
           ,[BeneficiaryMatch]
           ,[PercentOfacMatchBit]
           ,[MinPercentOfacMatch]
           ,CustomerName
           ,CustomerFirstLastName
           ,CustomerSecondLastName
           ,BeneficiaryName
           ,BeneficiaryFirstLastName
           ,BeneficiarySecondLastName
           ,IsCustomerFullMatch
           ,IsBeneficiaryFullMatch
           ,IsOFACDoubleVerification
           ,PercentDoubleVerification
           ,IsCustomerOldProccess
           ,IsBeneficiaryOldProccess
           )
     VALUES
           (@IdTransfer           
           ,@CustomerPercentMatch
           ,@xmlDataCustomer           
           ,@BeneficiaryPercentMatch
           ,@xmlDataBeneficiary
           ,@PercentOfacMatchBit
           ,@PercentOfac
           ,@CustomerName
           ,@CustomerFirstLastName
           ,@CustomerSecondLastName
           ,@BeneficiaryName
           ,@BeneficiaryFirstLastName
           ,@BeneficiarySecondLastName
           ,@IsCustomerFullMatch
           ,@IsBeneficiaryFullMatch
           ,@IsOFACDoubleVerification
           ,@PercentDoubleVerification
           ,@IsCustomerOldProccess
           ,@IsBeneficiaryOldProccess
           )
end

end try                                                                                    
Begin Catch                                                                                            
    declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveTransferOFACInfo',Getdate(),@ErrorMessage)                                                                                            
End Catch