-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-04
-- Description:	Create or update a customer from check's screen
---<log Date="2020/10/04" Author="esalazar" Name="">-- CR M00207	</log>
-- =============================================
CREATE PROCEDURE [Checks].[st_SaveCustomerFromCheckScreen]
	-- Add the parameters for the stored procedure here
	@IdCustomer INT OUTPUT,
	@IdAgentCreatedBy INT,
	@IdCustomerIdentificationType INT = NULL,
	@Name NVARCHAR(MAX),
	@FirstLastName NVARCHAR(MAX) = NULL,
	@SecondLastName NVARCHAR(MAX) = NULL,
	@Address NVARCHAR(MAX),
	@City NVARCHAR(MAX),
	@State NVARCHAR(MAX),
	@CountryId NVARCHAR(MAX),
	@Zipcode NVARCHAR(MAX),
	@PhoneNumber NVARCHAR(MAX) = NULL,
	@CelullarNumber NVARCHAR(MAX) = NULL,
	@SSNumber NVARCHAR(MAX) = NULL,
	@BornDate NVARCHAR(MAX) = NULL,
	@Occupation NVARCHAR(MAX) = NULL,
	@IdOccupation int = 0, /*M00207*/
	@IdSubcategoryOccupation int = 0,/*M00207*/
	@SubcategoryOccupationOther nvarchar(max) =null,/*M00207*/  
	@IdentificationNumber NVARCHAR(MAX) = NULL,
	@EnterByIdUser INT,
	@ExpirationIdentification DATETIME = NULL,
	@IdCarrier INT = NULL,
	@IdentificationIdCountry INT = NULL,
	@IdentificationIdState INT = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if @SubcategoryOccupationOther IS NULL Set @SubcategoryOccupationOther='' 
	DECLARE @IdGenericStatus INT = 1
			, @PhysicalIdCopy BIT = 0
			, @AmountInDorllars MONEY = 0
			, @DateOfLastChange DATETIME = GETDATE()
			, @CustomerReceiveSms BIT = 0


	IF @IdCustomer > 0
	BEGIN
		SELECT @IdGenericStatus = [IdGenericStatus]
				, @PhysicalIdCopy = [PhysicalIdCopy]
				, @AmountInDorllars =  [SentAverage]
				, @CustomerReceiveSms = [ReceiveSms]
		FROM Customer WITH (NOLOCK)
		WHERE [IdCustomer] = @IdCustomer
	END
			                                             
	EXEC [dbo].[st_InsertCustomerByTransfer]                                                                                             
		@IdCustomer,                                                                                            
		@IdAgentCreatedBy,                                                       
		@IdCustomerIdentificationType,                                                                                            
		@IdGenericStatus,                                                                                        
		@Name,                                                                                              
		@FirstLastName,                                       
		@SecondLastName,                                                                                      
		@Address,                                                                                      
		@City,                                                                                              
		@State,                                                                   
		'USA',                                                                                              
		@Zipcode,                                                                                              
		@PhoneNumber,                                                                                              
		@CelullarNumber,                                                                                              
		@SSNumber,                                                                      
		@BornDate,                                                                                            
		@Occupation,
		@IdOccupation, /*M00207*/
		@IdSubcategoryOccupation ,/*M00207*/
		@SubcategoryOccupationOther ,/*M00207*/                                                                                         
		@IdentificationNumber,                   
		@PhysicalIdCopy,                                                                                              
		@DateOfLastChange,
		@EnterByIdUser,                                                                                            
		@ExpirationIdentification,                                                                          
		@IdCarrier,     
		@IdentificationIdCountry ,  
		@IdentificationIdState , 
		@AmountInDorllars, 
		@CountryId,
		@CustomerReceiveSms,
		0,
		NULL,
		@IdCustomer OUTPUT

END
