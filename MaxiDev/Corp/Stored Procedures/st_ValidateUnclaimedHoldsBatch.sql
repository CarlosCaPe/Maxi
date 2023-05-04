CREATE PROCEDURE [Corp].[st_ValidateUnclaimedHoldsBatch]
(
	@data xml
)
/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Valida una transaccion en estado Unclaimed Hold que sera colocada en Unclaimed Completed en base a su ClaimCode(PropertyID)</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="29/06/2017" Author="snevarez">Valida una transaccion en estado Unclaimed Hold que sera colocada en Unclaimed Completed en base a su ClaimCode(PropertyID)</log>
<log Date="02/08/2017" Author="snevarez">S33:Valida monto de la transaccion que sera colocada en Unclaimed Completed en base a su ClaimCode(PropertyID)</log>
</ChangeLog>

*********************************************************************/
AS BEGIN

   DECLARE @XMLTable TABLE (idXml INT IDENTITY,
		OwnerName VARCHAR(150),
		OwnerState VARCHAR(150), 
		PropertyID VARCHAR(50),
		PropertyCode VARCHAR(20),
		LastActivityDate DATETIME, 
		InitialAmount MONEY , 		
		AdditionalAmount MONEY, 
		DeductionAmount MONEY,
		Amount MONEY,
		Shares MONEY,
		Status VARCHAR(100)
		,IsCheckAmount BIT DEFAULT((0))/*S33*/
		,TransferAmount MONEY /*S35*/
		);

   IF (@data IS NOT NULL ) 
   BEGIN 
   
	   	DECLARE @DocHandle INT 
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;
	
		INSERT INTO @XMLTable (OwnerName, OwnerState, PropertyID, PropertyCode, LastActivityDate, InitialAmount, AdditionalAmount, DeductionAmount, Amount, Shares)
		SELECT 
			OwnerName
			, OwnerState
			, PropertyID
			, PropertyCode
			, LastActivityDate
			, InitialAmount
			, AdditionalAmount
			, DeductionAmount
			, Amount
			, Shares
		FROM OPENXML (@DocHandle, 'ArrayOfUnclaimedHoldDataBatchDto/UnclaimedHoldDataBatchDto',2)    
		WITH (    
				OwnerName VARCHAR(150),
				OwnerState VARCHAR(150), 
				PropertyID VARCHAR(50),
				PropertyCode VARCHAR(20),
				LastActivityDate DATETIME, 
				InitialAmount MONEY , 		
				AdditionalAmount MONEY, 
				DeductionAmount MONEY,
				Amount MONEY,
				Shares MONEY
				);
	END

	
	UPDATE X	
			SET X.Status = S.StatusName
			,IsCheckAmount = (CASE WHEN (ISNULL(T.AmountInDollars,0) - X.Amount) = 0 THEN 1 ELSE 0 END) /*S33*/
			,TransferAmount = ISNULL(T.AmountInDollars,0)
	FROM @XMLTable AS X
		left Join dbo.Transfer AS T WITH(NOLOCK) ON X.PropertyID = T.ClaimCode
			Inner Join Status AS S  WITH(NOLOCK) ON T.IdStatus = S.IdStatus;




	UPDATE  @XMLTable SET Status = '' WHERE Status IS NULL 
	-- UPDATE @XMLTable SET transferAmount = 0 WHERE transferamount IS NULL 
	-- UPDATE @XMLTable SET Status = 'Unclaimed Hold' WHERE Status IS NULL 
	--UPDATE X	
	--		SET X.Status = S.StatusName
	--FROM @XMLTable AS X
	--	left Join dbo.TransferClosed AS T WITH(NOLOCK) ON X.PropertyID = T.ClaimCode
	--		Inner Join Status AS S  WITH(NOLOCK) ON T.IdStatus = S.IdStatus
	--WHERE X.Status = NULL	
	
	

	SELECT 	
			OwnerName
			, OwnerState
			, PropertyID
			, PropertyCode
			, LastActivityDate
			, InitialAmount
			, AdditionalAmount
			, DeductionAmount
			, Amount
			, Shares
			, Status
			, IsCheckAmount
			, ISNULL(TransferAmount,0) TransferAmount
	FROM @XMLTable;

END 





