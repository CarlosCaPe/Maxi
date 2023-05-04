CREATE Procedure [dbo].[st_SaveCustomerMirror]
(
    @IdCustomer int
)
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
begin try
set nocount on
INSERT INTO [dbo].[CustomerMirror]
           ([IdCustomer]
           ,[IdAgentCreatedBy]
           ,[IdCustomerIdentificationType]
           ,[IdGenericStatus]
           ,[Name]
           ,[FirstLastName]
           ,[SecondLastName]
           ,[Address]
           ,[City]
           ,[State]
           ,[Country]
           ,[Zipcode]
           ,[PhoneNumber]
           ,[CelullarNumber]
           ,[SSNumber]
           ,[BornDate]
           ,[Occupation]
           ,[IdentificationNumber]
           ,[PhysicalIdCopy]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[ExpirationIdentification]
           ,[IdCarrier]
           ,[IdentificationIdCountry]
           ,[IdentificationIdState]
           ,[SentAverage]
           ,[FullName]
		   ,[ReceiveSms]
		   ,[CreationDate]
		   ,[OccupationDetail] /*S44:REQ. MA.025*/
		   ,[IdOccupation] /*M00207*/
		   ,[IdSubcategoryOccupation] /*M00207*/
		   ,[SubcategoryOccupationOther] /*M00207*/
		   )
SELECT  [IdCustomer]
      ,[IdAgentCreatedBy]
      ,[IdCustomerIdentificationType]
      ,[IdGenericStatus]
      ,[Name]
      ,[FirstLastName]
      ,[SecondLastName]
      ,[Address]
      ,[City]
      ,[State]
      ,[Country]
      ,[Zipcode]
      ,[PhoneNumber]
      ,[CelullarNumber]
      ,[SSNumber]
      ,[BornDate]
      ,[Occupation]
      ,[IdentificationNumber]
      ,[PhysicalIdCopy]
      ,[DateOfLastChange]
      ,[EnterByIdUser]
      ,[ExpirationIdentification]
      ,[IdCarrier]
      ,[IdentificationIdCountry]
      ,[IdentificationIdState]
      ,[SentAverage]
      ,[FullName]
	  ,[ReceiveSms]
	  ,[CreationDate]
	  ,[OccupationDetail] /*S44:REQ. MA.025*/
	  ,[IdOccupation] /*M00207*/
	  ,[IdSubcategoryOccupation] /*M00207*/
	,[SubcategoryOccupationOther] /*M00207*/
  FROM [dbo].[Customer] WITH (NOLOCK) WHERE idcustomer=@IdCustomer
End Try                                                
Begin Catch	
	
	Declare @ErrorMessage nvarchar(max)  
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCustomerMirror',Getdate(),@ErrorMessage)                                                

End Catch

