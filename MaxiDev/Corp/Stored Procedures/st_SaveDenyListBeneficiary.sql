CREATE PROCEDURE [Corp].[st_SaveDenyListBeneficiary]
(  
@IdDenyListBeneficiary int,  
@IdBeneficiary int,  
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
If  @IdDenyListBeneficiary=0 and @IdGenericStatus=1 
Begin   
	Insert into DenyListBeneficiary 
	(
	IdBeneficiary,
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
	@IdBeneficiary,
	GETDATE(),
	null,
	@EnterByIdUser,
	null,
	@NoteInToList,
	null,
	1
	)
	
	Set @IdDenyListBeneficiary= SCOPE_IDENTITY()
	
 End
   else 
 begin
   update DenyListBeneficiary set NoteInToList = @NoteInToList, DateOfLastChange = GetDate(), EnterByIdUser = @EnterByIdUser where IdDenyListBeneficiary = @IdDenyListBeneficiary
 end 

 SET @IdItem = @IdDenyListBeneficiary

If  @IdDenyListBeneficiary<>0 and @IdGenericStatus=2 
Begin   
	Update DenyListBeneficiary
	Set	IdGenericStatus=2,
	NoteOutFromList=@NoteOutFromList,
	DateOutFromList=GETDATE(),
	IdUserDeleter=@EnterByIdUser
	Where IdDenyListBeneficiary=@IdDenyListBeneficiary
 End
  
 -------------------------- Update Actions ------------------------------------  
   
--update DenyListBeneficiary set NoteInToList = NoteInToList where IdDenyListBeneficiary = @IdDenyListBeneficiary

 Delete DenyListBeneficiaryActions where IdDenyListBeneficiary=@IdDenyListBeneficiary
 
 Declare @DocHandle int
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLActions   
 Insert into DenyListBeneficiaryActions 
 (
IdDenyListBeneficiary,
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
Select @IdDenyListBeneficiary,IdKYCAction,MessageInEnglish,MessageInSpanish,IdTypeRequired,IdNumberRequired,IdExpirationDateRequired,IdStateCountryRequired,DateOfBirthRequired,OccupationRequired,SSNRequired From OPENXML (@DocHandle, '/Actions/Detail',2)    
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
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveDenyListBeneficiary]',Getdate(),@ErrorMessage)  
End Catch

