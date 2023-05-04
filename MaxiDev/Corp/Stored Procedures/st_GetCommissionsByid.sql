CREATE PROCEDURE [Corp].[st_GetCommissionsByid]
(
	@idCommission int
)
AS  

Set nocount on;
Begin try
	Select c.IdCommission, CommissionName, IdCommissionDetail, AgentCommissionInPercentage, CorporateCommissionInPercentage, FromAmount, ToAmount, ExtraAmount
	from CommissionDetail cd with(nolock) join Commission c with(nolock) on cd.IdCommission = c.IdCommission where cd.IdCommission = @idCommission

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetCommissionsByid',Getdate(),@ErrorMessage);
End catch
