CREATE PROCEDURE [Corp].[st_SaveCommissionV2]
(
    @IdCommissionByOtherProducts INT,
    @IdOtherProducts INT,
    @CommissionName  NVARCHAR(MAX),
    @EnterByIdUser	INT,
    @IdOtherProductCommissionType INT = 0,
    @IdCommissionByOtherProductsOut INT OUT,
    @HasError INT OUT,
    @Message NVARCHAR(MAX)OUT
)
AS 
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description> Gra la informaciÃ³n de una comisión</Description>

<ChangeLog>
</ChangeLog>
*********************************************************************/
SET NOCOUNT ON;
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''
	IF(@IdCommissionByOtherProducts=0)
		BEGIN
			INSERT INTO CommissionByOtherProducts (IdOtherProducts, CommissionName, DateOfLastChange, EnterByIdUser,IsEnable, IdOtherProductCommissionTypE) 
			VALUES (@IdOtherProducts, @CommissionName, GETDATE(), @EnterByIdUser,0,  @IdOtherProductCommissionType)
			SET @IdCommissionByOtherProductsOut = SCOPE_IDENTITY()
		END
	ELSE
		BEGIN
			UPDATE CommissionByOtherProducts 
			SET IdOtherProducts	= @IdOtherProducts,
				CommissionName	= @CommissionName,
				DateOfLastChange	= GETDATE(),
				EnterByIdUser	= @EnterByIdUser,
				IdOtherProductCommissionType= @IdOtherProductCommissionType
			WHERE IdCommissionByOtherProducts=@IdCommissionByOtherProducts

			SET @IdCommissionByOtherProductsOut=@IdCommissionByOtherProducts
		END
END TRY
BEGIN CATCH 
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveCommissionV2',Getdate(),CONCAT(@Message,' Line: ',ERROR_LINE()))        
END CATCH
