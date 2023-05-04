
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 23/10/2019
-- Description: Valida que el tipo de cuenta sea el correcto
-- M00103 - CR Banco Industrial, Notificación Pago
-- =============================================

CREATE procedure [dbo].[st_AuthenticateUserBI]
as
select Code, AttributeKey, Value from [dbo].[ServiceAttributes] with(nolock)
	WHERE Code = 'BI' 
	and AttributeKey = 'PassWS' 
union all
(Select Code, AttributeKey, Value
from [dbo].[ServiceAttributes] with(nolock) 
	WHERE Code = 'BI' 
	AND AttributeKey = 'UserWS')