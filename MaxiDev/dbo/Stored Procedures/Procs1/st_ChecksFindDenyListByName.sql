CREATE procedure [dbo].[st_ChecksFindDenyListByName]  
(  
    @Name varchar(max),  
    @FirstLastName nvarchar(max),  
    @SecondLastName nvarchar(max),
    @IdLenguage int,
    @IsCustomer bit,
    @HasError bit output,            
    @Message nvarchar(max) output    
)  
As  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @Tot int

if @IdLenguage is null 
    set @IdLenguage=2
set @HasError=0
set @Message ='Ok'

create table #result
(
     IdDenyGeneric int,
     IdClienteGeneric int,
     Name nvarchar(max),
     FirstLastName nvarchar(max),
     SecondLastName nvarchar(max),
     Address nvarchar(max),
     City nvarchar(max),
     State nvarchar(max),
     ZipCode nvarchar(max),
     PhoneNumber nvarchar(max),
     CelullarNumber nvarchar(max),
     Country nvarchar(max),
     NoteIntoList nvarchar(max),
     NoteOutFromList nvarchar(max)
)

if (@IsCustomer=1)
begin
    select @Tot=count(1) from customer with(nolock) Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idcustomer in (select idcustomer from [dbo].[DenyListCustomer] with(nolock) where idgenericstatus=1)
end
else
    select @Tot=count(1) from beneficiary with(nolock) Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] with(nolock) where idgenericstatus=1)

if isnull(@Tot,0)>3000
begin 
    set @HasError=1
    set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR')         
end
else
begin
    if isnull(@Tot,0)=0
        begin 
            set @HasError=1
            set @Message=replace(replace([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias')
        end
    else
        begin
        if (@IsCustomer=1)
        begin
            insert into #result
            Select  distinct IdDenyListCustomer,c.IdCustomer,Name,FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList from customer  c with(nolock)
            join [dbo].[DenyListCustomer] d with(nolock) on d.idgenericstatus=1 and c.IdCustomer=d.IdCustomer
            Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%'
            --and idcustomer in (select idcustomer from [dbo].[DenyListCustomer] where idgenericstatus=1)
        end
        else
        begin
            insert into #result
            Select  distinct IdDenyListBeneficiary,c.IdBeneficiary,Name,FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList from beneficiary  c with(nolock)
            join [dbo].DenyListBeneficiary d with(nolock) on d.idgenericstatus=1 and c.IdBeneficiary=d.IdBeneficiary
            Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%'
            --and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] where idgenericstatus=1)
        end
        end
end