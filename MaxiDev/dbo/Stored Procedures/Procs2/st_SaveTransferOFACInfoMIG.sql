create procedure st_SaveTransferOFACInfoMIG
(
    @IdTransfer int,    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),    
    @BeneficiaryName nvarchar(max),
    @BeneficiaryFirstLastName nvarchar(max),
    @BeneficiarySecondLastName nvarchar(max),
    @IsOFAC bit out
)
as
declare     
            @CustomerPercentMatch float=0,    
            @BeneficiaryPercentMatch float=0,
            @xmlDataCustomer xml,
            @xmlDataBeneficiary xml,
            @PercentOfacMatchBit float,
            @PercentOfac float,
            @IsCustomerFullMatch bit = 0,
            @IsBeneficiaryFullMatch bit = 0

begin try

if exists (select top 1 1 from [TransferOFACInfo] where idtransfer=@IdTransfer) return

select @PercentOfacMatchBit=[dbo].[GetGlobalAttributeByName]('PercentOfacMatchBit'), @PercentOfac=[dbo].[GetGlobalAttributeByName]('MinOfacMatch'),@IsOFAC=0

/*Customer*/
Declare @CustomerPercentDataMatch table
(
    name nvarchar(max),
    percentMatch float,
    IsCustomerFullMatch bit not null default 0
)

insert into @CustomerPercentDataMatch
(name,percentMatch)
exec [st_OfacSearchDetailsLetterPairsByNameClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName

update @CustomerPercentDataMatch set IsCustomerFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end

select top 1 @CustomerPercentMatch=percentMatch,@IsCustomerFullMatch=IsCustomerFullMatch from @CustomerPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

if @CustomerPercentMatch>=@PercentOfac
begin

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

insert into @CustomerDataMatch
(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
exec [st_OfacSearchDetailsLetterPairsClr] @CustomerName,@CustomerFirstLastName,@CustomerSecondLastName

if not exists(select top 1 1 from @CustomerDataMatch where alt_name='')
begin
insert into @CustomerDataMatch
    (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
select top 1 SDN_NAME,SDN_REMARKS,'"aka"',SDN_NAME,'-0- ','','','','',0,0 from @CustomerDataMatch
end
else
begin
    update @CustomerDataMatch set alt_name=SDN_NAME where alt_name=''
end

update @CustomerDataMatch set Full_Match=t.IsCustomerFullMatch,Percent_Match=t.percentMatch
from 
(select * from @CustomerPercentDataMatch) t
where alt_name=t.name

set @xmlDataCustomer=(select * from @CustomerDataMatch FOR XML RAW,ROOT('OFACInfo'))
end

/*Beneficiary*/
Declare @BeneficiaryPercentDataMatch table
(
    name nvarchar(max),
    percentMatch float,
    IsBeneficiaryFullMatch bit not null default 0
)

insert into @BeneficiaryPercentDataMatch
(name,percentMatch)
exec [st_OfacSearchDetailsLetterPairsByNameClr] @BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName

update @BeneficiaryPercentDataMatch set IsBeneficiaryFullMatch=case when percentMatch>=@PercentOfacMatchBit then 1 else 0 end

select top 1 @BeneficiaryPercentMatch=percentMatch,@IsBeneficiaryFullMatch=IsBeneficiaryFullMatch from @BeneficiaryPercentDataMatch order by percentMatch desc--where percentMatch>=@PercentOfacMatchBit

if @BeneficiaryPercentMatch>=@PercentOfac
begin

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

insert into @BeneficiaryDataMatch
(SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
exec [st_OfacSearchDetailsLetterPairsClr] @BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName

if not exists(select top 1 1 from @BeneficiaryDataMatch where alt_name='')
begin
insert into @BeneficiaryDataMatch
    (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS,FULL_Match,Percent_Match)        
select top 1 SDN_NAME,SDN_REMARKS,'"aka"',SDN_NAME,'-0- ','','','','',0,0 from @BeneficiaryDataMatch
end
else
begin
    update @BeneficiaryDataMatch set alt_name=SDN_NAME where alt_name=''
end

update @BeneficiaryDataMatch set Full_Match=t.IsBeneficiaryFullMatch,Percent_Match=t.percentMatch
from 
(select * from @BeneficiaryPercentDataMatch) t
where alt_name=t.name

set @xmlDataBeneficiary=(select * from @BeneficiaryDataMatch FOR XML RAW,ROOT('OFACInfo'))
end

if (@CustomerPercentMatch>=@PercentOfac) or (@BeneficiaryPercentMatch>=@PercentOfac)
begin
set @IsOFAC=1

    declare @iduser int
    declare @note nvarchar(max)
    declare @enterdate datetime
  
    select top 1 @iduser=iduser,@note=note,@enterdate=enterdate from transfernote where idtransferdetail in (select top 1 idtransferdetail from transferdetail where idtransfer=@idtransfer and idstatus=16) order by enterdate

    if (@iduser is null)
    begin
        select top 1 @iduser=iduser,@note=note,@enterdate=enterdate from transferclosednote where idtransfercloseddetail in (select top 1 idtransfercloseddetail from transfercloseddetail where idtransferclosed=@idtransfer and idstatus=16) order by enterdate
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
           ,IdUserRelease1
           ,UserNoteRelease1	
           ,DateOfRelease1
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
           ,@Iduser
           ,@note
           ,@enterdate
           )
end
end try                                                                                    
Begin Catch                                                                                            
    declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveTransferOFACInfoMIG',Getdate(),@ErrorMessage)                                                                                            
End Catch 