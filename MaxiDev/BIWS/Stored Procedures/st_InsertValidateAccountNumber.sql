
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 23/10/2019
-- Description: SP para insertar las cuentas validadas no existentes en Banco Industrial
-- M00103 - CR Banco Industrial, Notificación Pago
-- =============================================

CREATE PROCEDURE [BIWS].[st_InsertValidateAccountNumber]
(
	@BeneficiaryName	  VARCHAR(50),
	@IdUser int,
	@DepositAccountNumber NVARCHAR(250),
	@TipoCuenta		int
)

AS

INSERT INTO [MAXILOG].[dbo].[ValidateAccountNumberBILogs]
           ([BeneficiaryName]
		    ,[IdUser]
			,[DepositAccountNumber]
			,[TipoCuenta]
			,[DateValidated])
     VALUES
           (@BeneficiaryName
		   ,@IdUser
           ,@DepositAccountNumber
		   ,@TipoCuenta
           ,GETDATE())