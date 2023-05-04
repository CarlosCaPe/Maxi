/********************************************************************
<Author>azavala</Author>
<app>WinService,Agent</app>
<Description></Description>

<ChangeLog>
<log Date="30/07/2018" Author="azavala">Update data after ElasticSearch response (Insert-Update)</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [elastic].[st_UpdateIdElasticCustomer] 
	@IdCustomer int,
	@IdElasticCustomer varchar(MAX),
	@UpdateCompleted bit,
	@IsUpdateProcess bit,
	@RequestUpdate bit,
	@HasError bit = '' output
AS
BEGIN try
	IF(@IsUpdateProcess=0)
		BEGIN
			update T1 set T1.idElasticCustomer = @IdElasticCustomer from Customer T1 with (nolock) where T1.IdCustomer = @IdCustomer
		END
	ELSE
		BEGIN
			update T1 set UpdateCompleted=@UpdateCompleted, RequestUpdate=@RequestUpdate from Customer T1 with (nolock) where T1.IdCustomer = @IdCustomer
		END
	
	set @HasError =0
	SELECT @HasError
END try
BEGIN catch
	Declare @ErrorMessage nvarchar(max)
	      
	Select @ErrorMessage=ERROR_MESSAGE()        
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_UpdateIdElasticCustomer]',Getdate(),@ErrorMessage) 
	set @HasError =1
	--set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,11)
    SELECT @HasError
END catch
