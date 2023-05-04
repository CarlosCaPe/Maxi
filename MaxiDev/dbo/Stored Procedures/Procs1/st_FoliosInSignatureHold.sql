CREATE Procedure [dbo].[st_FoliosInSignatureHold]
(
@IdAgent int
)
as
Set nocount on 


Declare  @Temp   Table   
(      
Id int identity(1,1),      
Folio varchar(max)
)
Insert into @Temp (Folio)
Select convert(varchar,A.Folio)   from Transfer A   
Join TransferHolds Th on (A.IdTransfer=Th.IdTransfer and Th.IdStatus=3 and Th.IsReleased is null)  
Join Agent C on (A.IdAgent=C.IdAgent)  
Where A.IdStatus=41 and A.IdAgent=@IdAgent
Order by A.Folio

Declare @Folios nvarchar(max),@Folio nvarchar(max),@Id int
Set @Folios=''

While exists(Select top 1 1 from @Temp)
Begin
   Select top 1 @Id=Id,@Folio=Folio from @Temp
   Set @Folios=@Folios+@Folio+','
   Delete @Temp where Id=@Id
End

if LEN(@Folios)>0
 Select substring(@Folios,1,Len(@Folios)-1) as Folios


 
