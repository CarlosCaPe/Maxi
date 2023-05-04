-- =============================================
-- Author:		Miguel Angel Hinojo 
-- Create date: 11/08/2016
-- Description:	Update Issuer Name of a check and IssuerChecks
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateIssuerCheck]
(
	@IdCheck INT, 
	@IssuerName NVARCHAR(MAX), 
	@IdIssuer INT,
	@EnteredByIdUser INT
)
AS
BEGIN
	BEGIN TRY
		UPDATE Checks SET IssuerName = @IssuerName WHERE IdCheck = @IdCheck
		UPDATE IssuerChecks set Name = @IssuerName, DateOfLastChange = GETDATE(), EnteredByIdUser = @EnteredByIdUser WHERE IdIssuer = @IdIssuer
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max)                                                                                             
		SELECT @ErrorMessage=ERROR_MESSAGE()                                             
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) 
		VALUES ('', GETDATE(),@ErrorMessage)                                                                                            
	END CATCH
END
