CREATE PROCEDURE [dbo].[st_ReportSAR]
   @bCustomer 		BINARY,
   @CustomerIds 	NVARCHAR(MAX),
   @begindate 		DATETIME,
   @enddate 		DATETIME,
   @nResultSet 		INT,
   @idProductType	INT
AS

BEGIN 
------------------------------
------------------------------
		SET ARITHABORT ON
		
		IF @bCustomer = 1 -- Is Customer
		BEGIN
			EXEC st_ReportCustomerSAR @CustomerIds, @begindate, @enddate, @nResultSet, @idProductType
		END
		ELSE
		BEGIN -- Is Beneficiary
			EXEC st_ReportBeneficiarySAR @CustomerIds, @begindate, @enddate, @nResultSet
		END
------------------------------
------------------------------
END
