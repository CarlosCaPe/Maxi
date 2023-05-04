
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 10/04/2020
-- Description: SP para insertar el nombre del beneficiario cuando la coincidencia sea menor de 85%
-- M00181 - ValidaciÃ³n de Nombre del Beneficiario de la Cuenta BI
-- =============================================

CREATE PROCEDURE [BIWS].[st_InsertValidatedNameBIMAXI]
(
	@IdAgent int,
	@DepositAccountNumber NVARCHAR(250),
	@NameBeneficiaryMAXI NVARCHAR(250),
	@NameBeneficiaryBI NVARCHAR(250),
	@MatchPercentage int
)

AS

INSERT INTO [BIWS].[validatedNameBI] 
           ([DateTime]
		    ,[IdAgent]
			,[DepositAccountNumber]
			,[NameBeneficiaryMAXI]
			,[NameBeneficiaryBI]
			,[MatchPercentage])
     VALUES
           (GETDATE()
		   ,@IdAgent
           ,@DepositAccountNumber
		   ,@NameBeneficiaryMAXI
		   ,@NameBeneficiaryBI
		   ,@MatchPercentage)
