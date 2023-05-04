
/********************************************************************
<Author>  </Author>
<app> Pontual </app>
<Description></Description>
<ChangeLog>
<log>date:22-05-2020, CR M00036, modificate by: jgomez </>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [dbo].[st_GetServiceAttributesPontual]
	
AS

SELECT AttributeKey, [Value] FROM dbo.ServiceAttributes WITH(NOLOCK) where  Code ='PONTUAL'

