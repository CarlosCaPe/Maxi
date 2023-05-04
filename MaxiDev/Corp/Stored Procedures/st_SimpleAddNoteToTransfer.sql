CREATE PROCEDURE [Corp].[st_SimpleAddNoteToTransfer]                
(                
 @IdTransfer Int,                
 @Note nvarchar(max)                
)                
/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
</ChangeLog>
*********************************************************************/
AS                

Set nocount on                 

Begin Try

Declare @IdSystemUser int, @NoteTemp varchar(max),@IdTransferDetail int            

 Select  top 1 @IdTransferDetail=A.IdTransferDetail,@NoteTemp=Rtrim(B.Note) from TransferDetail A WITH(NOLOCK)      

 Join TransferNote B WITH(NOLOCK) on (A.IdTransferDetail=B.IdTransferDetail)      

 Where A.IdTransfer=@IdTransfer Order by B.IdtransferNote desc             

 If @Note<>@NoteTemp           

 Begin    

    Select  @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')         

    Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdTransferDetail,1,@IdSystemUser,@Note,GETDATE())                 

 End      

 Else    

 Begin    

 Update TransferDetail set DateOfMovement=GETDATE() where IdTransferDetail=@IdTransferDetail    

 End

 End try
begin catch   
Declare @ErrorMessage nvarchar(max)                                                                                             
Select @ErrorMessage=ERROR_MESSAGE()                                                      
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SimpleAddNoteToTransfer',Getdate(),@ErrorMessage)                                                                                            
end catch
