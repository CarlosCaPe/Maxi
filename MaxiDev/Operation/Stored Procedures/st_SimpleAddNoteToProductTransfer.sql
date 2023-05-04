CREATE Procedure [Operation].[st_SimpleAddNoteToProductTransfer]                
(                
    @IdProductTransfer bigInt,                
    @Note nvarchar(max)                
)                
AS                
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @IdSystemUser int, @NoteTemp varchar(max),@IdProductTransferDetail int            
                
 Select  top 1 @IdProductTransferDetail=A.IdProductTransferDetail,@NoteTemp=Rtrim(B.Note) from ProductTransferDetail A with(nolock)       
 Join ProductTransferNote B with(nolock) on (A.IdProductTransferDetail=B.IdProductTransferDetail)      
 Where A.IdProductTransfer=@IdProductTransfer Order by B.IdProducttransferNote desc             
             
             
 If @Note<>@NoteTemp           
 Begin    
    Select  @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID');         
    Insert into Operation.ProductTransferNote (IdProductTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdProductTransferDetail,1,@IdSystemUser,@Note,GETDATE());
 End      
 Else    
 Begin    
 Update Operation.ProductTransferDetail set DateOfMovement=GETDATE() where IdProductTransferDetail=@IdProductTransferDetail;    
 End
