CREATE PROCEDURE [MaxiMobile].[st_GetIdCustomerByIdTransfer]
(
	@IdTransfer int,
	@IdCustomer int out
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener el id del customer apartir del id de la transferencia </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	select @IdCustomer = IdCustomer from transfer (nolock) where IdTransfer = @IdTransfer
	
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetIdCustomerByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH
