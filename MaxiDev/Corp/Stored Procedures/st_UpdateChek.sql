CREATE procedure [Corp].[st_UpdateChek]
 @IdCheck INT,
	@RoutingNumber VARCHAR(MAX), 
	@Account VARCHAR(MAX),
	@CheckNumber VARCHAR(MAX),
	@IdIdentificationType INT,
    @IdentificationNumber VARCHAR(MAX), 
    @IdentificationDateOfExpiration VARCHAR(MAX), 
    @DateOfBirth DATETIME,
    @CountryOfBirthId INT, 
    @Ocupation VARCHAR(MAX),
	@IdOccupation int = 0, /*M00207*/
	@IdSubcategoryOccupation int = 0,/*M00207*/
	@SubcategoryOccupationOther nvarchar(max) ='',/*M00207*/ 
	@IsUpdateBen bit,
	@SSNumber VARCHAR(MAX)
	

as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2018/01/18" Author="azavala">Optimizacion Agente</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/

 if( @IsUpdateBen = 0)
 BEGIN

		UPDATE Checks set RoutingNumber = @RoutingNumber, Account = @Account, CheckNumber = @CheckNumber
		WHERE IdCheck = @IdCheck
		
END
 ELSE
 BEGIN

		UPDATE Checks set 
					IdentificationType = (SELECT TOP 1 Name FROM CustomerIdentificationType WITH(NOLOCK) WHERE IdCustomerIdentificationType = @IdIdentificationType),
					IdIdentificationType =	@IdIdentificationType,
				   IdentificationNumber = @IdentificationNumber, 
				   IdentificationDateOfExpiration = @IdentificationDateOfExpiration, 
				   DateOfBirth = @DateOfBirth, 
				   Ocupation = @Ocupation,
					SSNumber = @SSNumber,
					[CountryBirthId] = @CountryOfBirthId
		WHERE IdCheck = @IdCheck

			UPDATE Customer set 
					IdCustomerIdentificationType =	@IdIdentificationType,
				   IdentificationNumber = @IdentificationNumber, 
				   ExpirationIdentification = @IdentificationDateOfExpiration, 
				   BornDate = @DateOfBirth,
				   Occupation = @Ocupation
				   ,IdOccupation = @IdOccupation/*M00207*/
					,IdSubcategoryOccupation = @IdSubcategoryOccupation/*M00207*/
					,SubcategoryOccupationOther = @SubcategoryOccupationOther /*M00207*/
				    ,SSNumber = @SSNumber,
					[IdCountryOfBirth] = @CountryOfBirthId
		WHERE IdCustomer in (select IdCustomer from Checks WITH(NOLOCK) where IdCheck = @IdCheck )

		
END