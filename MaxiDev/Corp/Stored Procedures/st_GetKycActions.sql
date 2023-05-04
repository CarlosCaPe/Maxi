CREATE PROCEDURE [Corp].[st_GetKycActions]
AS  

Set nocount on;
Begin try
	Select IdKYCAction, [Action] from KycAction with(nolock)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetKycActions',Getdate(),@ErrorMessage);
End catch
