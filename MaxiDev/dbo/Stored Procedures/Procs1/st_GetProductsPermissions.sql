CREATE PROCEDURE [dbo].[st_GetProductsPermissions]
    @IdUser INT    
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>Sp obtains the permissions on specific modules according to the requirement Req_M2An055</Description>

<ChangeLog>
<log Date="18/05/2018" Author="snevarez">Creation of the sp </log>
</ChangeLog>
*********************************************************************/
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    SET NOCOUNT ON;

    Begin try
	   
	   SELECT
		  Id
		  ,OtherProducts
		  ,IsPermissions
	   FROM [dbo].[fnProductsPermissions](@IdUser);

    End Try
    begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetProductsPermissions',Getdate(),'User:' + Convert(VARCHAR(250),@IdUser) + ',' + @ErrorMessage);
    End Catch

END
