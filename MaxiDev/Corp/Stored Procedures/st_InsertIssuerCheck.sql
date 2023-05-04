CREATE PROCEDURE Corp.st_InsertIssuerCheck
	@IssuerName		VARCHAR(100),
	@RoutingNumber	VARCHAR(100),
	@AccountNumber	VARCHAR(100),
	@IdUser			INT,
	@IdIssuer		INT OUT
AS
BEGIN

	INSERT INTO IssuerChecks (Name, RoutingNumber, AccountNumber, DateOfCreation, DateOfLastChange, EnteredByIdUser, PhoneNumber)
	VALUES (@IssuerName, @RoutingNumber, @AccountNumber, getdate(), getdate(), @IdUser, '')

	SET @IdIssuer = @@IDENTITY
	

END