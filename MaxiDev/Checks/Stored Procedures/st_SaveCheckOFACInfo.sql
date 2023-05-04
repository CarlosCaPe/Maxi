
CREATE procedure [Checks].[st_SaveCheckOFACInfo]
(
    @IdCheck int,    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),    
    @IssuerName nvarchar(max),    
    @IsOFAC bit out,
    @IsOFACDoubleVerification bit out
)
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="23/01/2018" Author="jdarellano" Name="#1">Performance: se agregan with(nolock) y se mejora método de búsqueda.</log>
<log Date="19/12/2018" Author="jmolina" Name="">Performance: se agregan ; por cada insert/update.</log>
<log Date="04/09/2020" Author="jsierra" Name="">Se agrega nuevo algoritmo de OFAC</log>
</ChangeLog>
*********************************************************************/

declare     
            @CustomerPercentMatch float=0,    
            @IssuerPercentMatch float=0,
            @xmlDataCustomer xml,
            @xmlDataBeneficiary xml,
            @PercentOfacMatchBit float,
            @PercentOfac float,
            @PercentDoubleVerification float = 0,
            @IsCustomerFullMatch bit = 0,
            @IsIssuerFullMatch bit = 0,
            @IsCustomerOldProccess BIT = 0,
			@UseMaxiOFAC BIT = 0,
			@UseMaxiOFACEntity BIT = 0


begin try

	IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatch' AND ga.Value = '1')
		SET @UseMaxiOFAC = 1

	IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatchWithEntity' AND ga.Value = '1')
		SET @UseMaxiOFACEntity = 1

    set @CustomerName = dbo.fn_EspecialChrOFF(@CustomerName)
    set @CustomerFirstLastName = dbo.fn_EspecialChrOFF(@CustomerFirstLastName)
    set @CustomerSecondLastName = dbo.fn_EspecialChrOFF(@CustomerSecondLastName)   

--if exists (select top 1 1 from [CheckOFACInfo] where IdCheck=@IdCheck) return
if exists (select 1 from [dbo].[CheckOFACInfo] with(nolock) where IdCheck=@IdCheck) return--#1

select  @PercentOfacMatchBit=[dbo].[GetGlobalAttributeByName]('PercentOfacMatchBit'), 
        @PercentOfac=[dbo].[GetGlobalAttributeByName]('MinOfacMatchCheck'),
        @IsOFAC=0,
        @IsOFACDoubleVerification=0,
        @PercentDoubleVerification=[dbo].[GetGlobalAttributeByName]('PercentOfacDoubleVerificationCheck')

/*Customer*/
Declare @CustomerPercentDataMatch table
(
    [name] nvarchar(max),
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
/*
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
*/


--if exists(select top 1 1 from @EntNumCus)
if exists(select 1 from @EntNumCus)--#1
BEGIN
    SET @IsCustomerOldProccess = 1

    --if exists(select top 1 1 from @EntNumCus where IsFullMatch=1)
	if exists(select 1 from @EntNumCus where IsFullMatch=1)--#1
    begin
        set @CustomerPercentMatch = 100
        set @IsCustomerFullMatch = 1
    end
    else
    begin
        set @CustomerPercentMatch = @PercentOfac
    end
        
    insert into @CustomerPercentDataMatch
    select sdn_name,@CustomerPercentMatch,0 from [dbo].[OFAC_SDN] with(nolock) where ent_num in(select ent_num from @EntNumCus)    
    
    insert into @CustomerDataMatch    
    SELECT SDN_NAME, ISNULL(REMARKS,'') SDN_REMARKS,ISNULL(ALT_TYPE,'') ALT_TYPE,ISNULL(ALT_NAME,'') ALT_NAME, ISNULL(ALT_REMARKS,'') ALT_REMARKS,isnull([address],'') ADD_ADDRESS,isnull(CITY_NAME,'') ADD_CITY_NAME,isnull(COUNTRY,'') ADD_COUNTRY,isnull(ADD_REMARKS,'') ADD_REMARKS,0,0 FROM [dbo].[OFAC_SDN]
    LEFT join [dbo].[OFAC_ALT] ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM
    LEFT JOIN [dbo].[OFAC_ADD] ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
    WHERE OFAC_SDN.ENT_NUM in (select ent_num from @EntNumCus);   
    
    --if not exists(select top 1 1 from @CustomerDataMatch where alt_name='')
	if not exists(select 1 from @CustomerDataMatch where alt_name='')--#1
        begin
        insert into @CustomerDataMatch
            (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
        select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @CustomerDataMatch;
        end
        else
        begin
            update @CustomerDataMatch set alt_name=SDN_NAME where alt_name='';
        end 
                
        update @CustomerDataMatch set Percent_Match=@CustomerPercentMatch where ALT_NAME in (select fullname from @EntNumCus);
        update @CustomerDataMatch set FULL_Match=1 where ALT_NAME in (select fullname from @EntNumCus where IsFullMatch=1);

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
			@CustomerPercentMatch		OUT,
			@IsCustomerFullMatch		OUT,
			@xmlDataCustomer			OUT
	END
	ELSE
	BEGIN
		insert into @CustomerPercentDataMatch
		(name,percentMatch)
		exec [st_OfacSearchDetailsLetterPairsByNameClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName;

		delete from @CustomerPercentDataMatch where percentMatch<@PercentOfac;

		update @CustomerPercentDataMatch set IsCustomerFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end;

		select top 1 @CustomerPercentMatch=percentMatch,@IsCustomerFullMatch=IsCustomerFullMatch from @CustomerPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

		if @CustomerPercentMatch>=@PercentOfac
		begin
			insert into @CustomerDataMatch
			(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
			exec [st_OfacSearchDetailsLetterPairsClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName;

			--if not exists(select top 1 1 from @CustomerDataMatch where alt_name='')
			if not exists(select 1 from @CustomerDataMatch where alt_name='')--#1
			begin
			insert into @CustomerDataMatch
				(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
			select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @CustomerDataMatch;
			end
			else
			begin
				update @CustomerDataMatch set alt_name=SDN_NAME where alt_name='';
			end

			update @CustomerDataMatch set Full_Match=t.IsCustomerFullMatch,Percent_Match=t.percentMatch
			from 
			(select * from @CustomerPercentDataMatch) t
			where alt_name=t.[name];

			set @xmlDataCustomer=(select *,'Percent' Method from @CustomerDataMatch FOR XML RAW,ROOT('OFACInfo'))
		end
	END
end


IF @UseMaxiOFAC = 1 AND @UseMaxiOFACEntity = 1
BEGIN
	EXEC st_MaxiOFACValidateEntity
		@IssuerName,
		'',
		'',
		@IssuerPercentMatch		OUT,
		@IsIssuerFullMatch		OUT,
		@xmlDataBeneficiary		OUT
END
ELSE
BEGIN
	/*Beneficiary*/
	Declare @IssuerPercentDataMatch table
	(
		[name] nvarchar(max),
		percentMatch float,
		IsIssuerFullMatch bit not null default 0
	)

	insert into @IssuerPercentDataMatch
	(name,percentMatch)
	exec [st_OfacSearchDetailsLetterPairsByNameClr] @IssuerName,'','';

	delete from @IssuerPercentDataMatch where percentMatch<@PercentOfac;

	update @IssuerPercentDataMatch set IsIssuerFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end;

	select top 1 @IssuerPercentMatch=percentMatch,@IsIssuerFullMatch=IsIssuerFullMatch from @IssuerPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

	if @IssuerPercentMatch>=@PercentOfac
	begin
		Declare @IssuerDataMatch table
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

		insert into @IssuerDataMatch
		(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
		exec [st_OfacSearchDetailsLetterPairsClr] @IssuerName,'','';

		--if not exists(select top 1 1 from @IssuerDataMatch where alt_name='')
		if not exists(select 1 from @IssuerDataMatch where alt_name='')--#1
		begin
		insert into @IssuerDataMatch
			(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)
		select top 1 SDN_NAME,SDN_REMARKS,'a.k.a.',SDN_NAME,'-0- ','','','','',0,0 from @IssuerDataMatch;
		end
		else
		begin
			update @IssuerDataMatch set alt_name=SDN_NAME where alt_name='';
		end

		update @IssuerDataMatch set Full_Match=t.IsIssuerFullMatch,Percent_Match=t.percentMatch
		from 
		(select * from @IssuerPercentDataMatch) t
		where alt_name=t.name;

		set @xmlDataBeneficiary=(select *,'Percent' Method from @IssuerDataMatch FOR XML RAW,ROOT('OFACInfo'))
	end
END

if (@CustomerPercentMatch>=@PercentOfac) or (@IssuerPercentMatch>=@PercentOfac)
begin
	set @IsOFAC=1

	if (@CustomerPercentMatch>=@PercentDoubleVerification) or (@IssuerPercentMatch>=@PercentDoubleVerification)
	begin
		set @IsOFACDoubleVerification=1
	end 


	INSERT INTO [dbo].[CheckOFACInfo]
			   ([Idcheck]           
			   ,[CustomerOfacPercent]
			   ,[CustomerMatch]           
			   ,[IssuerOfacPercent]
			   ,[IssuerMatch]
			   ,[PercentOfacMatchBit]
			   ,[MinPercentOfacMatch]
			   ,CustomerName
			   ,CustomerFirstLastName
			   ,CustomerSecondLastName
			   ,IssuerName           
			   ,IsCustomerFullMatch
			   ,IsIssuerFullMatch
			   ,IsOFACDoubleVerification
			   ,PercentDoubleVerification
			   ,IsCustomerOldProccess
			   ,IsIssuerOldProccess           
			   )
		 VALUES
			   (@IdCheck
			   ,@CustomerPercentMatch
			   ,@xmlDataCustomer           
			   ,@IssuerPercentMatch
			   ,@xmlDataBeneficiary
			   ,@PercentOfacMatchBit
			   ,@PercentOfac
			   ,@CustomerName
			   ,@CustomerFirstLastName
			   ,@CustomerSecondLastName
			   ,@IssuerName           
			   ,@IsCustomerFullMatch
			   ,@IsIssuerFullMatch 
			   ,@IsOFACDoubleVerification
			   ,@PercentDoubleVerification
			   ,@IsCustomerOldProccess
			   ,0          
			   );
end
end try                                                                                    
Begin Catch                                                                                            
    declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCheckOFACInfo',Getdate(),@ErrorMessage)                                                                                            
End Catch 
