CREATE PROCEDURE [Corp].[st_GetPaymentTypes]
AS  

Set nocount on;
Begin try
	Select IdPaymentType, PaymentName from PaymentType with(nolock)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetPaymentTypes',Getdate(),@ErrorMessage);
End catch
