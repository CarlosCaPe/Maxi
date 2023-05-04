CREATE PROCEDURE [Corp].[st_GetPendingPaymentToReview]
	@PendingPayment INT OUT
AS

/********************************************************************
<Author>Cesar Garcia</Author>
<app>MaxiCorp</app>
<Description>BM-667, BM-1065 Se obtiene el numero de envíos que tienen mas de 10 minutos en Status Pending Payment</Description>
<Description>BM-667, BM-1065 Fix en el datepart del datediff</Description>

<ChangeLog>
</ChangeLog>

********************************************************************/ 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT @PendingPayment = count(1)
FROM [Transfer] T WITH(NOLOCK)
WHERE T.IdStatus = 1 
	AND T.IdPaymentMethod = 2 
	AND datediff(mi, T.DateOfTransfer, getdate()) > 10
