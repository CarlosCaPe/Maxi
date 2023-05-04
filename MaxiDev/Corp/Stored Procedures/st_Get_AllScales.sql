/********************************************************************
<Author>omurillo</Author>
<app>Corporate Angular</app>
<Description></Description>

<ChangeLog>
<log Date="2020/10/14" Author="esalazar">obtener las escalas de redondeo </log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [Corp].[st_Get_AllScales] 
as

	SET NOCOUNT ON;
	
Begin try

    SELECT 
	IdScaleRounding, 
	ScaleRName
	FROM [dbo].[ScaleRounding] with(nolock)

End try
begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_Get_AllScales]',Getdate(),@ErrorMessage)
end catch
