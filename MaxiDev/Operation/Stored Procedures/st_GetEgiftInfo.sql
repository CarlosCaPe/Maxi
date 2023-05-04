create PROCEDURE operation.[st_GetEgiftInfo](
		 @IdLanguaje INT = 1
		,@IdAgent INT = NULL
		,@DateFrom DATETIME --= '20140101'
		,@DateTo DATETIME --= '20140101'
		,@Folio INT= NULL
		,@IdStatus XML = NULL        
        ,@BenPhone nvarchar(max)
		----------------------
		,@HasError BIT OUT
		,@Message VARCHAR(MAX) OUT
)
AS
BEGIN TRY
	--Configs
	SET NOCOUNT ON;

	DECLARE @TSTATUS TABLE(ID INT) 
	Declare @DocHandle int       
	

	--VarSettings
	SET @HasError = 0
	SET @Message = 'Success'

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @IdStatus
	Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
    Select @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

	INSERT INTO @TSTATUS(ID)     
	SELECT id    
	FROM OPENXML (@DocHandle, '/statuses/status',1)     
	WITH (id INT) 

select pt.IdProductTransfer,pt.DateOfCreation,dbo.[fnFormatPhoneNumber](Phone) Phone,dbo.[fnFormatPhoneNumber](topupphone) topupphone,pt.amount,pt.transactionproviderid,ln.skuname ProductName
from operation.producttransfer pt
join lunex.transferln ln on pt.IdProductTransfer=ln.IdProductTransfer
WHERE PT.IdProvider = 3/*lunex*/
		and PT.IdOtherProduct = 11
		and PT.IdAgent = ISNULL(@IdAgent,PT.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus  IN (SELECT ID FROM @TSTATUS)--ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo        
        and ln.TopupPhone like '%'+isnull(@BenPhone,ln.TopupPhone)+'%'
	ORDER BY DateOfCreation

End Try                                                                                            
Begin Catch
	SET @HasError = 1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLanguaje,'MESSAGE07')
	Declare @ErrorMessage NVARCHAR(MAX)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetEgiftInfo',Getdate(),@ErrorMessage)                                                                                            
End Catch  




