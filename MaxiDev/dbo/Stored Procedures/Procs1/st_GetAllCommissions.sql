/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="04/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
Create procedure [dbo].[st_GetAllCommissions]

AS  

Set nocount on;
Begin try
	Select IdCommission, CommissionName
	from Commission with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetCommissionsByid',Getdate(),@ErrorMessage);
End catch