
create procedure [TransFerTo].[st_GetTransactionByPhoneNumber]
(
	@BeginDate datetime,
	@EndDate datetime,
	@ByCustomer bit, --false means by beneficiary
	@PhoneNumber nvarchar(max)
)
as

set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate)+1

begin try
	SET NOCOUNT ON
	if (@ByCustomer=1)
	begin
		SELECT IdTransferTTo, IdAgent, Destination_Msisdn, Product, Operator, OriginCurrency, DestinationCurrency, WholeSalePrice, RetailPrice, IdTransactionTTo, Country, 
			   OperatorReference, LocalInfoAmount, LocalInfoCurrency, LocalInfoValue, ReturnTimeStamp, DateOfCreation, Destination_Msisdn AS PhoneNumber
		FROM TransFerTo.TransferTTo
		WHERE 
			   (ReturnTimeStamp BETWEEN @beginDate AND @endDate) AND (replace(replace(replace(replace(Msisdn,'(',''),')',''),'-',''),' ','') like '%'+@PhoneNumber+'%') 

	end
	else
	begin
		SELECT IdTransferTTo, IdAgent, Destination_Msisdn, Product, Operator, OriginCurrency, DestinationCurrency, WholeSalePrice, RetailPrice, IdTransactionTTo, Country, 
			   OperatorReference, LocalInfoAmount, LocalInfoCurrency, LocalInfoValue, ReturnTimeStamp, DateOfCreation, Msisdn As PhoneNumber
		FROM TransFerTo.TransferTTo
		WHERE 
			   (ReturnTimeStamp BETWEEN @beginDate AND @endDate) AND (Destination_Msisdn like '%'+@PhoneNumber+'%')

	end
End Try                                                                                            
Begin Catch                                                                                        
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_GetTransactionByPhoneNumber',Getdate(),@ErrorMessage)                                                                                            
End Catch  
