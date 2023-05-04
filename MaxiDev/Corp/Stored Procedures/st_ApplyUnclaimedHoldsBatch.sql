CREATE PROCEDURE [Corp].[st_ApplyUnclaimedHoldsBatch]
(
	@note varchar(max)
	, @EnterByIdUser INT
	, @data xml
	, @HasError BIT = 0 OUT
	, @Message VARCHAR(200) ='' OUT
)
/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Cambio de estado de transacciones en estado Unclaimed Hold a Unclaimed Completed en base a su ClaimCode(PropertyID)</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="29/06/2017" Author="snevarez">Cambio de estado de transacciones en estado Unclaimed Hold a Unclaimed Completed en base a su ClaimCode(PropertyID)</log>
</ChangeLog>
*********************************************************************/

AS BEGIN

	DECLARE @LastProcess VARCHAR(200) = '';

	BEGIN TRY
	
	   SELECT @HasError=0
			, @Message='';

	   SET @note = ISNULL(@note,'Unclaimed Completed by System');

	   
	   SET @LastProcess='reading data from file in database';
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
								IdTransfer Int, 
								IdStatus Int, 
								Status VARCHAR(100) );
		
	   IF (@data IS NOT NULL) 
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
		
		SET @LastProcess ='updating existent transfer'		
		UPDATE X	
			SET 
				X.IdTransfer = T.IdTransfer
				,X.IdStatus = S.IdStatus
				,X.Status = S.StatusName				
		FROM @XMLTable AS X
			left Join dbo.Transfer AS T WITH(NOLOCK) ON X.PropertyID = T.ClaimCode
				Inner Join Status AS S  WITH(NOLOCK) ON T.IdStatus = S.IdStatus;

		SET @LastProcess ='exists transfers'	
		IF EXISTS (SELECT Top 1 1 FROM  @XMLTable) 
		BEGIN 
		  
		  DECLARE @id INT = 0;
		  DECLARE @IdTrasnfer INT = 0;
		  DECLARE @TransferDetail XML;
		  DECLARE @ClaimCode VARCHAR(50);
		  
		  SET @LastProcess ='change status transfer';
		  --27	Unclaimed Hold
		  WHILE EXISTS(SELECT Top 1 1 FROM  @XMLTable WHERE IdStatus = 27)
		  BEGIN 
			 SELECT Top 1
				 @id = idXml
				,@IdTrasnfer = IdTransfer
				,@ClaimCode = PropertyID
			 FROM  @XMLTable WHERE IdStatus = 27;

				--28	Unclaimed Completed
				 update transfer 
					set 
						idstatus=28
						, DateStatusChange=getdate()
					where idtransfer = @IdTrasnfer;

				insert into TransferDetail values (28,@IdTrasnfer,GETDATE());
				
				exec [Corp].[st_AddNoteToTransfer] @IdTrasnfer, @EnterByIdUser, @note,1,@TransferDetail OUTPUT,@HasError OUTPUT,@Message OUTPUT;			
			  
			 DELETE FROM @XMLTable WHERE idXml = @id;
		  END

		  SET @LastProcess ='log transfer - status change not applied';
		  DECLARE @IdStatus INT = 0;
		   --27	Unclaimed Hold
		  WHILE EXISTS(SELECT Top 1 1 FROM  @XMLTable WHERE IdStatus != 27)
		  BEGIN 
			 SELECT Top 1
				 @id = idXml
				,@IdTrasnfer = IdTransfer
				,@ClaimCode = PropertyID
				,@IdStatus = IdStatus
			 FROM  @XMLTable WHERE IdStatus != 27;

				INSERT INTO [dbo].[LogForUnclaimedHoldsBatch]
					(
						[IdUser],
						[IdStatus],
						[ClaimCode],
						[Description],
						[LogDate])
				VALUES
				 (
					@EnterByIdUser,
					@IdStatus,
					@ClaimCode,
					('Status change not applied - IdTrasnfer:' + CONVERT(VARCHAR(25), @IdTrasnfer) ),
					GETDATE()
				 );
			  
			 DELETE FROM @XMLTable WHERE idXml = @id;
		  END 	  
		 
		END 	   
	
	END TRY  
	BEGIN CATCH 
	  
		Declare @ErrorMessage nvarchar(max);
		Select @ErrorMessage=ERROR_MESSAGE();
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_ApplyUnclaimedHoldsBatch',Getdate(),@ErrorMessage);
		set @HasError = 1;
		set @Message = 'Error while '+ @LastProcess;
	    
	END CATCH

END 
