CREATE procedure [dbo].[st_UpdateChek]
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

	,@HasError bit = 0 out
	,@Message varchar(max) = '' out
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2018/01/18" Author="azavala">Optimizacion Agente</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
<log Date="2020/10/14" Author="esalazar" Name="Occupations">--Try Catch hasError	</log>
<log Date="2020/10/14" Author="esalazar" Name="Occupations">--BREAK in WHILE LOOP, IdCustomer instead of @IdCustomer	</log>
</ChangeLog>
********************************************************************/

BEGIN TRY
 set @HasError=0
 if( @IsUpdateBen = 0)
 BEGIN
	UPDATE Checks set 
		RoutingNumber = @RoutingNumber,
		Account = @Account,
		CheckNumber = @CheckNumber
	WHERE IdCheck = @IdCheck;
END
 ELSE
 BEGIN

	UPDATE Checks set 
		IdentificationType = (SELECT TOP 1 Name FROM CustomerIdentificationType WHERE IdCustomerIdentificationType = @IdIdentificationType),
		IdIdentificationType =	@IdIdentificationType,
		IdentificationNumber = @IdentificationNumber, 
		IdentificationDateOfExpiration = @IdentificationDateOfExpiration, 
		DateOfBirth = @DateOfBirth, 
		Ocupation = @Ocupation,
		SSNumber = @SSNumber,
		[CountryBirthId] = @CountryOfBirthId
	WHERE IdCheck = @IdCheck;

	/*----------------*/
	DECLARE @CUST TABLE
	(
		Id int Identity(1,1),
		IdCustomer int
	);

	WITH CTE_CUSTUMER AS 
	(
		SELECT DISTINCT IdCustomer 
			FROM Checks WHERE IdCheck = @IdCheck
	)INSERT INTO @CUST
		SELECT  IdCustomer FROM CTE_CUSTUMER;
	WHILE EXISTS(SELECT TOP 1 1 FROM @CUST)   
	BEGIN  

		DECLARE @IdCustomer INT = 0;
		SET @IdCustomer = ISNULL((SELECT TOP 1 IdCustomer FROM @CUST),0);
		IF(@IdCustomer = 0)
		BEGIN 
			BREAK
		END

		exec st_SaveCustomerMirror @IdCustomer 

		IF(
			Len(isnull(@IdIdentificationType,''))=0
			OR
			Len(isnull(@IdentificationNumber,''))=0
			OR
			Len(isnull(@DateOfBirth,''))=0
		)
		BEGIN
			UPDATE Customer set 
				/*IdCustomerIdentificationType*/
				/*IdentificationNumber*/ 
				/*ExpirationIdentification*/
				/*BornDate*/
				 Occupation = @Ocupation
				,IdOccupation = @IdOccupation/*M00207*/
				,IdSubcategoryOccupation = @IdSubcategoryOccupation/*M00207*/
				,SubcategoryOccupationOther = @SubcategoryOccupationOther /*M00207*/
				,SSNumber = @SSNumber
				/*IdCountryOfBirth*/
			WHERE IdCustomer = @IdCustomer;
		END
		ELSE
		BEGIN
		
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
			WHERE IdCustomer = @IdCustomer;
		END
		
		DELETE FROM @CUST WHERE IdCustomer = @IdCustomer;
	
	END
	END
	End try
begin catch
    set @HasError=1
	SET @Message ='Error trying to update Check'
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[[st_UpdateChek]]',Getdate(),@ErrorMessage)
end catch

