create PROCEDURE [dbo].[st_UpdateCustomerPhysicalIdCopy]
(
	@IdCustomer INT = 0,   
    @EnterByIdUser INT,
	@PhysicalIdCopy int,
    @HasError BIT = 0 OUT	  
)
AS
BEGIN TRY

if not exists(select top 1 1 from customer where idcustomer=@IdCustomer and PhysicalIdCopy = @PhysicalIdCopy)                                                                                          
begin
	EXEC st_SaveCustomerMirror @IdCustomer
    
	UPDATE dbo.Customer 
	SET 
    DateOfLastChange = getdate(),
	EnterByIdUser = @EnterByIdUser,	
    PhysicalIdCopy = @PhysicalIdCopy
    WHERE idCustomer = @IdCustomer   
end		
SET @HasError = 0

END TRY
BEGIN CATCH
	SET @HasError=1	
	DECLARE @ErrorMessage nvarchar(max)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateCustomerPhysicalIdCopy',Getdate(),@ErrorMessage)
END CATCH


return;