/********************************************************************
<Author>omurillo</Author>
<app>Corporate Angular</app>
<Description></Description>

<ChangeLog>
<log Date="2020/10/08" Author="omurillo"> obtener las configuraciones de parametros de redondeo </log>
<log Date="2020/10/14" Author="esalazar">se añade IsEnabled y with nolock </log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [Corp].[st_GetConfigParametersByIdPayer] 
(
	@IdPayer int
)
as

	SET NOCOUNT ON;
	
Begin try

    SELECT 
	pr.IdPayerRounding, 
	pr.IdPayer, 
	p.PayerName, 
	pr.IdPaymentType, 
	pt.PaymentName, 
	pr.IdScaleRounding, 
	s.ScaleRName, 
	pr.IsEnabled
	FROM [dbo].[PayerRounding] pr with(nolock)
	JOIN [dbo].[ScaleRounding] s with(nolock) on s.IdScaleRounding = pr.IdScaleRounding
	JOIN [dbo].[Payer] p with(nolock) on p.IdPayer = pr.IdPayer
	JOIN [dbo].[PaymentType] pt with(nolock) on pt.IdPaymentType = pr.IdPaymentType
	WHERE p.IdPayer = @IdPayer

End try
begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetConfigParametersByIdPayer]',Getdate(),@ErrorMessage)
end catch
