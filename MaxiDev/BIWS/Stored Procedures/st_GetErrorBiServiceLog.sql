
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 17/04/2020
-- Description: SP para validar el tiempo de cada vez que falle el servicio de BI y mandar correo
-- M00176 - Manejo de error en la validación de la cuenta de BI por conectividad
-- =============================================

create procedure [BIWS].[st_GetErrorBiServiceLog]

as

select isEnable
FROM [MAXILOG].[BIWS].ErrorBiServiceLog WITH(NOLOCK) 
WHERE ISEnable = 1
order by 1 desc


