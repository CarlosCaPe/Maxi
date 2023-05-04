-- =============================================
-- Author:		Jorge Gomez
-- Create date: 2020-02-14
-- Description:	This stored is used for Banco Industrial service for to apply payments
-- =============================================
CREATE PROCEDURE [BIWS].[st_SavePayInfoBancoIndustrialWS]

	@IdGateway  INT,
    @Claimcode  NVARCHAR(MAX)   
AS
BEGIN TRY

	SET NOCOUNT ON;

	DECLARE @IdTransfer INT
	SELECT @IdTransfer = IdTransfer FROM Transfer WITH(NOLOCK) WHERE ClaimCode = @Claimcode

	IF EXISTS(SELECT 1 FROM Transfer WITH(NOLOCK) WHERE ClaimCode = @Claimcode AND IdPaymentType = 2)
	BEGIN
    INSERT INTO [dbo].[TransferPayInfo] (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    VALUES (@IdTransfer,@ClaimCode,@IdGateway,GETDATE(),'','','',NULL)
	END 

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage nvarchar(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[BIWS].[st_SavePayInfoBancoIndustrialWS]', GETDATE(), @ErrorMessage)
END CATCH

