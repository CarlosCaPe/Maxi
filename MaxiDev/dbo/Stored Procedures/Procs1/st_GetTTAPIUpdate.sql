CREATE Procedure [dbo].[st_GetTTAPIUpdate]                                
AS
/********************************************************************
<Author></Author>
<app>PaymentServices : PaymentService.TransferToV2 - TTAPI </app>
<Description>Get Monty operations in payment ready </Description>

<ChangeLog>
<log Date="03/05/2018" Author="snevarez">Get operations in payment ready</log>
</ChangeLog>
*********************************************************************/

Set nocount on  

Begin try

    --23	Payment Ready
    --35	Cancel Accepted
    select 

	   --ClaimCode+'_'+CONVERT(nvarchar(max),s.serial) as external_id
	   --, ClaimCode 

	   /*2018-May-03*/
	   CASE WHEN s.serial IS NULL 
		  THEN ClaimCode 
		  ELSE ClaimCode + '_' + CONVERT(nvarchar(max),s.serial) 
	   END as external_id

    from transfer AS t WITH(NOLOCK)
	   left join [dbo].[TTApiSerial] AS s WITH(NOLOCK) on t.IdTransfer=s.IdTransfer
	   where IdStatus=23 and IdGateway=35;

End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessage nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(50), ERROR_LINE()), 
	   @ErrorMessage = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetTTAPIUpdate',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

End Catch