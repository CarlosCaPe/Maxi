
CREATE procedure [BillPayment].[st_GetMaskForBillers] 
 @idBiller int
as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Mask For Biller </Description>

<ChangeLog>

<log Date="13/08/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/
select distinct
  
 [Length]
from 
 BillPayment.MaskForBillers WITH(NOLOCK)
where 
 idbiller = @idBiller
 
