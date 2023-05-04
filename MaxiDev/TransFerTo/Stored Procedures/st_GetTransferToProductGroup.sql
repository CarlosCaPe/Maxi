CREATE PROCEDURE [TransferTo].[st_GetTransferToProductGroup] 
(
	@IdCarrierTTo INT
)
/********************************************************************
<Author>snevarez</Author>
<app> Agent </app>
<Description>Obtiene los carriers que pertenecen al mismo grupo</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="16/08/2017" Author="snevarez">Obtiene los carriers que pertenecen al mismo grupo</log>
</ChangeLog>
*********************************************************************/
AS BEGIN

    DECLARE @HasError BIT = 0;
    DECLARE @Message VARCHAR(200) ='';

    BEGIN TRY

	   DECLARE @CodeGroup [nvarchar](50);

	   IF EXISTS( Select Top 1 1 From [TransFerTo].[ProductGroup] WITH(NOLOCK) Where IdCarrierTTo = @IdCarrierTTo)
	   BEGIN

		  SET @CodeGroup = (Select TOP 1 [CodeGroup] From [TransFerTo].[ProductGroup] Where IdCarrierTTo = @IdCarrierTTo);

		  Select 
			 --[IdProductGroup],
			 [IdCarrierTTo],
			 [CodeGroup],
			 [AliasProduct]
			 --,[DateOfLastChange],
			 --[EnterByIdUser]
		  From [TransFerTo].[ProductGroup]
			 Where CodeGroup = @CodeGroup;
	   END
	   ELSE
	   BEGIN
		  SET @HasError = 1;
		  SET @Message = 'Unknown Carrier';
	   END

    END TRY  
    BEGIN CATCH 
	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransferTo.st_GetTransferToProductGroup',Getdate(),@ErrorMessage);
	   set @HasError = 1;
	   set @Message = 'Error: '+ @ErrorMessage;
	    
    END CATCH

END 

