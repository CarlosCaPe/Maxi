CREATE PROCEDURE [dbo].[st_SaveDenyListCustomer]
(    
@IdDenyListCustomer int,    
@IdCustomer int,    
@NoteInToList nvarchar(max),  
@NoteOutFromList nvarchar(max),  
@IdGenericStatus int,  
@EnterByIdUser int,    
@XMLActions xml,  
@IsSpanishLanguage bit,  
@HasError bit out,    
@Message varchar(max) out,
@IdItem BIGINT OUT
)    
AS    
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>
<ChangeLog>
<log Date="14/05/2018" Author="mhinojo">S11 Anexo de columnas nuevas para deny list required. </log>
</ChangeLog>
********************************************************************/
Set nocount on     
Begin Try    
     
If  @IdDenyListCustomer=0 and @IdGenericStatus=1   
Begin     
 Insert into DenyListCustomer   
 (  
 IdCustomer,  
 DateInToList,  
 DateOutFromList,  
 IdUserCreater,  
 IdUserDeleter,  
 NoteInToList,  
 NoteOutFromList,  
 IdGenericStatus  
 )  
 Values  
 (  
 @IdCustomer,  
 GETDATE(),  
 null,  
 @EnterByIdUser,  
 null,  
 @NoteInToList,  
 null,  
 1  
 )  
   
 Set @IdDenyListCustomer= SCOPE_IDENTITY()  
 
 End  
 else 
 begin
  update DenyListCustomer set NoteInToList = @NoteInToList, DateOfLastChange = GetDate(), EnterByIdUser = @EnterByIdUser where IdDenyListCustomer = @IdDenyListCustomer 
 end

SET @IdItem = @IdDenyListCustomer

If  @IdDenyListCustomer<>0 and @IdGenericStatus=2   
Begin     
 Update DenyListCustomer  
 Set IdGenericStatus=2,  
 NoteOutFromList=@NoteOutFromList,  
 DateOutFromList=GETDATE(),
 IdUserDeleter=@EnterByIdUser  
 Where IdDenyListCustomer=@IdDenyListCustomer  
 End  
    
 -------------------------- Update Actions ------------------------------------    

 --update DenyListCustomer set NoteInToList = @NoteInToList where IdDenyListCustomer = @IdDenyListCustomer
     
 Delete DenyListCustomerActions where IdDenyListCustomer=@IdDenyListCustomer   
   
 Declare @DocHandle int  
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLActions     
 Insert into DenyListCustomerActions   
 (  
IdDenyListCustomer,  
IdKYCAction,  
MessageInEnglish,  
MessageInSpanish,
IdTypeRequired,
IdNumberRequired,
IdExpirationDateRequired,
IdStateCountryRequired,
DateOfBirthRequired,
OccupationRequired,
SSNRequired
)    
Select @IdDenyListCustomer,IdKYCAction,MessageInEnglish,MessageInSpanish,IdTypeRequired,IdNumberRequired,IdExpirationDateRequired,IdStateCountryRequired,DateOfBirthRequired,OccupationRequired,SSNRequired From OPENXML (@DocHandle, '/Actions/Detail',2)    
WITH (    
IdKYCAction int,    
MessageInEnglish nvarchar(max),  
MessageInSpanish nvarchar(max),
IdTypeRequired bit,
IdNumberRequired bit,
IdExpirationDateRequired bit,
IdStateCountryRequired bit,
DateOfBirthRequired bit,
OccupationRequired bit,
SSNRequired bit
 )     
 Exec sp_xml_removedocument @DocHandle    
  
  
   
 --------------------------------------------------------------------------------------------    
 Set @HasError=0    
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,32)    
End Try    
Begin Catch    
 Set @HasError=1    
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)    
 Declare @ErrorMessage nvarchar(max)     
 Select @ErrorMessage=ERROR_MESSAGE()    
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveDanyListCustomer',Getdate(),@ErrorMessage)    
End Catch
