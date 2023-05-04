CREATE procedure [dbo].[st_TransferOFACReport]
as
truncate table TransferOFACReport

insert into TransferOFACReport
(idtransfer,idstatus,claimcode,idcustomer,Customername,CustomerFirstLastName,CustomerSecondLastName,idbeneficiary,BeneficiaryName,BeneficiaryFirstLastName,BeneficiarySecondLastName,dateoftransfer)
select idtransfer,idstatus,claimcode,idcustomer,Customername,CustomerFirstLastName,CustomerSecondLastName,idbeneficiary,BeneficiaryName,BeneficiaryFirstLastName,BeneficiarySecondLastName,dateoftransfer from
(
select 
     idtransfer
    ,claimcode
    ,idcustomer
    ,Customername
    ,CustomerFirstLastName
    ,CustomerSecondLastName
    --,[dbo].[fun_OfacnamePercentLetterPairs](Customername,CustomerFirstLastName,CustomerSecondLastName) CustomerOfacPercent
    ,idbeneficiary
    ,BeneficiaryName
    ,BeneficiaryFirstLastName
    ,BeneficiarySecondLastName 
    ,dateoftransfer
    ,idstatus
    --,[dbo].[fun_OfacnamePercentLetterPairs](BeneficiaryName,BeneficiaryFirstLastName,BeneficiarySecondLastName) BeneficiaryOfacPercent
from transfer with(nolock)
where 
    idtransfer in (select idtransfer from transferdetail with(nolock) where idstatus=15)
    and
    dateoftransfer>='10/01/2013 00:00' and dateoftransfer<'10/01/2014 00:00'
union all
select 
     idtransferclosed idtransfer
    ,claimcode
    ,idcustomer
    ,Customername
    ,CustomerFirstLastName
    ,CustomerSecondLastName
    --,[dbo].[fun_OfacnamePercentLetterPairs](Customername,CustomerFirstLastName,CustomerSecondLastName) CustomerOfacPercent
    ,idbeneficiary
    ,BeneficiaryName
    ,BeneficiaryFirstLastName
    ,BeneficiarySecondLastName 
    ,dateoftransfer
    ,idstatus
    --,[dbo].[fun_OfacnamePercentLetterPairs](BeneficiaryName,BeneficiaryFirstLastName,BeneficiarySecondLastName) BeneficiaryOfacPercent
from transferclosed with(nolock)
where 
    idtransferclosed in (select idtransferclosed from transfercloseddetail with(nolock) where idstatus=15)
    and
    dateoftransfer>='10/01/2013 00:00' and dateoftransfer<'10/01/2014 00:00'
)t
order by idtransfer



create table #dataMatch
(
    SDN_NAME nvarchar(max),
    SDN_REMARKS nvarchar(max),
    ALT_TYPE nvarchar(max),
    ALT_NAME nvarchar(max),
    ALT_REMARKS nvarchar(max),
    ADD_ADDRESS nvarchar(max),
    ADD_CITY_NAME nvarchar(max),
    ADD_COUNTRY nvarchar(max),
    ADD_REMARKS nvarchar(max)
)

select id into #tmp from TransferOFACReport

declare @id int
declare @Customername	nvarchar(max)
declare @CustomerFirstLastName	nvarchar(max)
declare @CustomerSecondLastName	nvarchar(max)
declare @CustomerOfacPercent float
declare @BeneficiaryName	nvarchar(max)
declare @BeneficiaryFirstLastName	nvarchar(max)
declare @BeneficiarySecondLastName	nvarchar(max)
declare @BeneficiaryOfacPercent float
declare @CustomerXML xml
declare @BeneficiaryXML xml
declare @iduser int
declare @username nvarchar(max)
declare @note nvarchar(max)
declare @idtransfer int
declare @idstatus int



while exists(select top 1 1 from #tmp)
begin
    select top 1 @id=id from #tmp order by id    
    select 
        @idstatus=idstatus,
        @idtransfer=idtransfer,
        @Customername=Customername,
        @CustomerFirstLastName=CustomerFirstLastName,
        @CustomerSecondLastName=CustomerSecondLastName,
        @CustomerOfacPercent=[dbo].[fun_OfacnamePercentLetterPairs](Customername,CustomerFirstLastName,CustomerSecondLastName),
        @BeneficiaryName=BeneficiaryName,
        @BeneficiaryFirstLastName=BeneficiaryFirstLastName,
        @BeneficiarySecondLastName=BeneficiarySecondLastName,
        @BeneficiaryOfacPercent=[dbo].[fun_OfacnamePercentLetterPairs](BeneficiaryName,BeneficiaryFirstLastName,BeneficiarySecondLastName)
    from TransferOFACReport
    where id=@id
    --customer
    if @CustomerOfacPercent>=70
    begin
        insert into #dataMatch
        EXEC	[dbo].[ST_OFAC_SEARCH_DETAILS]
		@f_name = @Customername,
		@l_name_1 = @CustomerFirstLastName,
		@l_name_2 = @CustomerSecondLastName  
        
        update #dataMatch
            set 
            SDN_NAME = replace(SDN_NAME,'"',''),
            SDN_REMARKS = replace(SDN_REMARKS,'"',''),
            ALT_TYPE = replace(ALT_TYPE,'"',''),
            ALT_NAME = replace(ALT_NAME,'"',''),
            ALT_REMARKS = replace(ALT_REMARKS,'"',''),
            ADD_ADDRESS = replace(ADD_ADDRESS,'"',''),
            ADD_CITY_NAME = replace(ADD_CITY_NAME,'"',''),
            ADD_COUNTRY = replace(ADD_COUNTRY,'"',''),
            ADD_REMARKS = replace(ADD_REMARKS,'"','')
                      
        set @CustomerXML=(select * from #dataMatch FOR XML AUTO)                
        truncate table #dataMatch
    end

    --beneficiary
    if @BeneficiaryOfacPercent>=70
    begin
        insert into #dataMatch
        EXEC	[dbo].[ST_OFAC_SEARCH_DETAILS]
		@f_name = @BeneficiaryName,
		@l_name_1 = @BeneficiaryFirstLastName,
		@l_name_2 = @BeneficiarySecondLastName

        update #dataMatch
            set 
            SDN_NAME = replace(SDN_NAME,'"',''),
            SDN_REMARKS = replace(SDN_REMARKS,'"',''),
            ALT_TYPE = replace(ALT_TYPE,'"',''),
            ALT_NAME = replace(ALT_NAME,'"',''),
            ALT_REMARKS = replace(ALT_REMARKS,'"',''),
            ADD_ADDRESS = replace(ADD_ADDRESS,'"',''),
            ADD_CITY_NAME = replace(ADD_CITY_NAME,'"',''),
            ADD_COUNTRY = replace(ADD_COUNTRY,'"',''),
            ADD_REMARKS = replace(ADD_REMARKS,'"','')

        set @BeneficiaryXML=(select * from #dataMatch FOR XML AUTO)
        
        truncate table #dataMatch
    end 
    
    --if (@idstatus not in (31,22))
    --begin
        set @idstatus=16
    --end

    select top 1 @iduser=iduser,@note=note from transfernote where idtransferdetail in (select top 1 idtransferdetail from transferdetail where idtransfer=@idtransfer and idstatus=@idstatus) order by enterdate

    if (@iduser is null)
    begin
        select top 1 @iduser=iduser,@note=note from transferclosednote where idtransfercloseddetail in (select top 1 idtransfercloseddetail from transfercloseddetail where idtransferclosed=@idtransfer and idstatus=@idstatus) order by enterdate
    end


    select @username=username from users where iduser=@iduser



    update TransferOFACReport set 
        beneficiaryMatch=@BeneficiaryXML,
        customerMatch=@CustomerXML,
        CustomerOfacPercent=@CustomerOfacPercent,
        BeneficiaryOfacPercent=@BeneficiaryOfacPercent, 
        note=@note,
        iduserrelease=@iduser,
        usernamerelease=@username
    where id=@id        


    set @BeneficiaryXML=null
    set @CustomerXML=null
    set @CustomerOfacPercent=0
    set @BeneficiaryOfacPercent=0
    set @username=''
    set @note=''
    set @iduser=null

    delete from #tmp where id=@id
end

select * from #tmp

drop table #dataMatch
drop table #tmp

update TransferOFACReport set IsCustomerFullMatch = 1  where  CustomerOfacPercent=100
update TransferOFACReport set IsBeneficiaryFullMatch = 1  where  BeneficiaryOfacPercent=100


DECLARE	@return_value int

EXEC	@return_value = [dbo].[st_SendMail]
		@body = N'TransferOFACReport Finalizado',
		@subject = N'TransferOFACReport'

SELECT	'Return Value' = @return_value
