CREATE function [dbo].[GetNoteValueFromGatewayResponse]
(
    @idtransfer int,
    @Name nvarchar(max)
)
returns nvarchar(max)
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin

declare @idstatus int
declare @note nvarchar(max)
declare @sDelimiter nvarchar(1)
declare @sItem nvarchar(max)
declare @idVar int
declare @idTmp int
declare @id int
declare @value nvarchar(max)

set @idstatus=30
--set @value=''

--set @idtransfer =
--4817020 --TNW
--4763679 --bts
--4809370 --GL
--4817410 --cibanco
--4809920 --citibank
--4811478 --banrural
set @sDelimiter='='
set @note=''

declare @notes table
(
    idnote int identity(1,1),
    value nvarchar(max)
);

insert into @notes
select note from [Transfer] t with(nolock)
join Transferdetail td with(nolock) on  td.idtransfer=t.idtransfer and td.IdStatus in (@idstatus)
join TransferNote tn with(nolock) on tn.IdTransferDetail=td.IdTransferDetail 
where 
    t.IdTransfer=@idtransfer 

if not exists(select 1 from @notes)
begin
insert into @notes
select note from Transferclosed t with(nolock) 
join Transfercloseddetail td with(nolock) on  td.idtransferclosed=t.idtransferclosed and td.IdStatus in (@idstatus)
join TransferclosedNote tn with(nolock) on tn.IdTransferclosedDetail=td.IdTransferclosedDetail
where 
    t.IdTransferClosed=@idtransfer
end    

set @id =1

WHILE @id <= (select count(1) from @notes)     
Begin  
    select @note=@note+';'+value from @notes where idnote=@id
    set @id=@id+1
end

declare @tmp table
(
    idTmp int identity(1,1),
    value nvarchar(max)
);

declare @vars table
(   
    idVar int identity(1,1),
    variable nvarchar(max),
    value nvarchar(max)
);

insert into @tmp
select * from fnSplit(@note, ';');

--select * from @tmp

set @id =1

WHILE @id <= (select count(1) from @tmp)     
Begin      
 Select @idTmp=idTmp,@note=value from @tmp where idTmp=@id;

   /*limpiar nota*/
   --TNW
   set @note = replace (@note,'NOTIFICATION code 1001,Transaction has been canceled ','')
   set @note = replace (@note,'NOTIFICATION code 9002,The transfer request has been cancelled ','')
   set @note = replace (@note,'NOTIFICATION code 1000,Payment has been completed ','')
   
   --BTS
   set @note = replace (@note,'NOTIFICATION code 1100,Paid ','')

   --GL
   set @note = replace (@note,'NOTIFICATION code 4,Transaction Paid ','')   
   set @note = replace (@note,'NOTIFICATION code 8,Cancelled ','')   
   
   --citibank
   set @note = replace (@note,'NOTIFICATION code PAGADA,Paid - Pagado ','')
   set @note = replace (@note,'NOTIFICATION code CANCELADA,Cancelled - Cancelado ','')

   --banrural
   set @note = replace (@note,'NOTIFICATION code Pagada,Paid ','')
   set @note = replace (@note,'NOTIFICATION code Cancelada,Cancelada ','')

   --PI
   set @note = replace (@note,'NOTIFICATION code P ','')
   set @note = replace (@note,'NOTIFICATION code CA ','')
 
   WHILE CHARINDEX(@sDelimiter,@note,0) <> 0
    BEGIN
        SELECT
            @sItem=RTRIM(LTRIM(SUBSTRING(@note,1,CHARINDEX(@sDelimiter,@note,0)-1))),
            @note=RTRIM(LTRIM(SUBSTRING(@note,CHARINDEX(@sDelimiter,@note,0)+LEN(@sDelimiter),LEN(@note))))
 
        IF LEN(@sItem) > 0
        begin
            INSERT INTO @vars (variable) SELECT @sItem
            set @idVar = SCOPE_IDENTITY();
        end
    END
    
    IF LEN(@sItem) > 0
        update @vars set value=@note where idVar=@idVar;    
    set @sItem=''
    set @id=@id+1
End

select @value=isnull(value,'') from @vars where variable=@name;

return @value

end