CREATE Procedure [dbo].[st_InsertOnWhoseBehalf]    
(               
@IdAgentCreatedBy int,    
@IdGenericStatus int,    
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
@SSNumber nvarchar(max),    
@BornDate datetime,    
@Occupation nvarchar(max),  
@IdOccupation int = 0,/*M00207*/
@IdSubcategoryOccupation int = 0,/*M00207*/
@SubcategoryOccupationOther nvarchar(max) =null,/*M00207*/  
@IdentificationNumber nvarchar(max),    
@PhysicalIdCopy int,    
@IdCustomerIdentificationType int,    
@ExpirationIdentification datetime,    
@Purpose nvarchar(max),    
@Relationship nvarchar(max),    
@MoneySource nvarchar(max),    
@DateOfLastChange datetime,    
@EnterByIdUser int,    
@IdOnWhoseBehalfOutput int Output    
)    
AS 
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/     
    
 Insert into OnWhoseBehalf     
 (    
 IdAgentCreatedBy,    
 IdGenericStatus,    
 Name,    
 FirstLastName,    
 SecondLastName,    
 Address,    
 City,    
 State,    
 Country,    
 Zipcode,    
 PhoneNumber,    
 CelullarNumber,    
 SSNumber,    
 BornDate,    
 Occupation,
 IdOccupation,/*M00207*/
 IdSubcategoryOccupation,/*M00207*/
 SubcategoryOccupationOther,/*M00207*/      
 IdentificationNumber,    
 PhysicalIdCopy,    
 IdCustomerIdentificationType,    
 ExpirationIdentification,    
 Purpose,    
 Relationship,    
 MoneySource,    
 DateOfLastChange,    
 EnterByIdUser    
 )    
 Values     
 (    
 @IdAgentCreatedBy,    
 @IdGenericStatus,    
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
 @SSNumber,    
 @BornDate,    
 @Occupation, 
 @IdOccupation,/*M00207*/
 @IdSubcategoryOccupation,/*M00207*/
 @SubcategoryOccupationOther,/*M00207*/     
 @IdentificationNumber,    
 @PhysicalIdCopy,    
 @IdCustomerIdentificationType,    
 @ExpirationIdentification,    
 @Purpose,    
 @Relationship,    
 @MoneySource,    
 @DateOfLastChange,    
 @EnterByIdUser    
 )    
     
 Select @IdOnWhoseBehalfOutput=SCOPE_IDENTITY()
