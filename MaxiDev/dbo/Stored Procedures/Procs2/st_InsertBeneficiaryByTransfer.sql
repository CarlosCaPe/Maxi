CREATE Procedure [dbo].[st_InsertBeneficiaryByTransfer]    
(    
@IdBeneficiary int,    
@Name nvarchar(max),    
@FirstLastName nvarchar(max),    
@SecondLastName nvarchar(max),    
@Address nvarchar(max),    
@City nvarchar(max),    
@State nvarchar(max),    
@Country nvarchar(max),    
@Zipcode nvarchar(max),    
@PhoneNumber nvarchar(max),    
@CelullarNumber nvarchar(max),    
@SSnumber nvarchar(max),    
@BornDate datetime,    
@Occupation nvarchar(max),    
@Note nvarchar(max),    
@IdGenericStatus int,    
@DateOfLastChange datetime,    
@EnterByIdUser int,  
@IdBeneficiaryIdentificationType int,
@BeneficiaryIdentificationNumber nvarchar(max),
@IdBeneficiaryCountryOfBirth int = null,
@IdBeneficiaryOutput int Output,
@IdDialingCodePhoneNumber INT = NULL
)    
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
    <log Date="19/12/2018" Author="jmolina">Add ;</log>
	<log Date="2022/04/11" Author="jcsierra" Name="DomesticTransfers">Se agrega el parametro @IdDialingCodePhoneNumber </log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;    
If @IdBeneficiary=0     
Begin    
 Insert into Beneficiary     
 (    
 Name,    
 FirstLastName,    
 SecondLastName,    
 [Address],    
 City,    
 [State],    
 Country,    
 Zipcode,    
 PhoneNumber,    
 CelullarNumber,    
 SSnumber,    
 BornDate,    
 Occupation,    
 Note,    
 IdGenericStatus,    
 DateOfLastChange,    
 EnterByIdUser,
 IdBeneficiaryIdentificationType,
 IdentificationNumber,
 IdCountryOfBirth,
 IdDialingCodePhoneNumber
 )    
 Values    
 (    
 @Name,    
 @FirstLastName,    
 @SecondLastName,    
 @Address,    
 @City,    
 @State,    
 @Country,    
 @Zipcode,    
 @PhoneNumber,    
 @CelullarNumber,    
 @SSnumber,    
 @BornDate,    
 @Occupation,    
 @Note,    
 @IdGenericStatus,    
 @DateOfLastChange,    
 @EnterByIdUser,
 @IdBeneficiaryIdentificationType,
 @BeneficiaryIdentificationNumber,
 @IdBeneficiaryCountryOfBirth,
 @IdDialingCodePhoneNumber 
 ) ;   
 Select @IdBeneficiaryOutput=SCOPE_IDENTITY()  
End    
Else    
Begin    
 Update Beneficiary Set    
 Name=@Name,    
 FirstLastName=@FirstLastName,    
 SecondLastName=@SecondLastName,    
 [Address]=case 
			when @Address='' then [Address]
			else @Address
		end,    
 City=case 
			when @City='' then City
			else @City
		end,    
 [State]=case 
			when @State='' then [State]
			else @State
		end,    
 Country=case 
			when @Country='' then Country
			else @Country
		end,    
 Zipcode=case 
			when @Zipcode='' then Zipcode
			else @Zipcode
		end,    
 PhoneNumber=@PhoneNumber,    
 CelullarNumber=case 
			when @CelullarNumber='' then CelullarNumber
			else @CelullarNumber
		end,    
 SSnumber=@SSnumber,    
 BornDate=case 
			when @BornDate IS NULL then BornDate
			else @BornDate
		end,  
 Occupation=@Occupation,    
 Note=@Note,    
 IdGenericStatus=@IdGenericStatus,    
 DateOfLastChange=@DateOfLastChange,    
 EnterByIdUser=@EnterByIdUser,
 IdBeneficiaryIdentificationType=isnull(@IdBeneficiaryIdentificationType,IdBeneficiaryIdentificationType),
 IdentificationNumber=isnull(@BeneficiaryIdentificationNumber,IdentificationNumber),
 IdCountryOfBirth =case 
			when @IdBeneficiaryCountryOfBirth IS NULL then IdCountryOfBirth
			else @IdBeneficiaryCountryOfBirth
		end,
 IdDialingCodePhoneNumber = @IdDialingCodePhoneNumber
 Where IdBeneficiary=@IdBeneficiary;   
   
 Select @IdBeneficiaryOutput=@IdBeneficiary;    
End
