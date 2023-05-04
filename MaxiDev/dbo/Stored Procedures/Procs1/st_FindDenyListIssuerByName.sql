CREATE procedure [dbo].[st_FindDenyListIssuerByName]  
(  
    @Name varchar(max),  
    @IdLenguage int,
    @HasError bit output,            
    @Message nvarchar(max) output    
)  
As  
Set nocount on  
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

select @Tot=count(1) from IssuerChecks  Where Name like '%'+@Name+'%' and IdIssuer in (select IdIssuerCheck from [dbo].[DenyListIssuerChecks] where idgenericstatus=1)

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
            insert into #result
            Select  distinct IdDenyListIssuerCheck,C.IdIssuer,Name,'','','','','','','','','',NoteIntoList,NoteOutFromList from IssuerChecks  c
            join [dbo].[DenyListIssuerChecks] d on d.idgenericstatus=1 and c.IdIssuer=d.IdIssuerCheck
            Where Name like '%'+@Name+'%'
            --and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] where idgenericstatus=1)
        end
end