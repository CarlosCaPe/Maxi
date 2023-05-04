CREATE PROCEDURE [Corp].[st_BulkRejetedChekfromXml_Checks]
	-- Add the parameters for the stored procedure here
	--declare  
	@DocXml XML --= '<XmlDetails>  <Details>    <Id_Check>15076</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (Closed Account) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15079</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (NSF-Insuf Funds) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15075</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (NSF-Insuf Funds) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15078</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (Closed Account) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15073</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (NSF-Insuf Funds) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15072</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (Closed Account) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15071</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (NSF-Insuf Funds) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details>  <Details>    <Id_Check>15070</Id_Check>    <Id_Status>30</Id_Status>    <Note>Returned Check (NSF-Insuf Funds) </Note>    <Id_User>9168</Id_User>    <ReturnDate>2019-06-03T15:46:56</ReturnDate>    <FileName>BulkCheckRejectedTEST8.csv</FileName>  </Details></XmlDetails>'
AS
BEGIN TRY
	
	DECLARE @DocHandle int,
			@IdCheck int,  
		    @IdStatus int,
		    @Note nvarchar(max),       
		    @IdUser int, --,
			@FileName nvarchar(max),
			@ReturnDate datetime, 
			@IdStatusRejected INT=31

	CREATE TABLE #CurrentXmlDetails (
	id_check_ int, 
	id_status_ int, 
	note_ nvarchar(max), 
	id_user_ int,
	return_date_ datetime,
	file_Name_ nvarchar(max)
	)

	EXEC sp_xml_preparedocument @DocHandle output, @DocXml

	INSERT #CurrentXmlDetails
	SELECT Id_Check, Id_Status, Note, Id_User, ReturnDate, [FileName]
	FROM OPENXML (@DocHandle, '/XmlDetails/Details', 2)
	WITH (
	Id_Check int,
	Id_Status int,
	Note nvarchar(max),
	Id_User int,
	ReturnDate DateTime,
	[FileName] nvarchar(max)
	)

	DECLARE @count int = (SELECT COUNT(*) FROM #CurrentXmlDetails)
	
	WHILE (@count > 0)
	BEGIN
			SET @IdCheck = NULL
		    SET @IdStatus = NULL
		    SET @Note = NULL       
		    SET @IdUser = NULL 
			SET @FileName = NULL 
			SET @ReturnDate = NULL 
	
		SELECT TOP 1 @IdCheck = id_check_, @IdStatus=id_status_, @Note= note_, @IdUser= id_user_, @FileName = file_Name_, @ReturnDate = return_date_ 
		FROM #CurrentXmlDetails
		--, @ReturnDate = return_date_ 
		
		IF exists (SELECT 1 FROM dbo.Checks with (nolock) WHERE IdCheck=@IdCheck AND IdStatus <> 31) -- ticket 2250 se agrega que sea diferentes de 31 para que no se dupliquen los cheques
			BEGIN
				
				UPDATE dbo.Checks SET IdStatus=@IdStatusRejected,DateStatusChange=GETDATE() Where IdCheck = @IdCheck

				EXECUTE [Corp].[st_CheckCancelToAgentBalance_Checks]
				  @IdCheck 					= @IdCheck,
					@EnterByIdUser 	= @IdUser,
					@IsReject  			= 1 
	
				EXECUTE [Corp].[st_SaveChangesToCheckLog_Checks]  
					@Idcheck 			= @IdCheck          
					, @IdStatus  		= @IdStatusRejected         
					, @Note    			= @Note     
					, @IdUser  			= @IdUser 
					, @DateOfMovement	= @ReturnDate

				EXECUTE [Corp].[st_RejectCheckNotificationFromBulkCheck]
					@IdCheck   = @IdCheck,
					@EnterByIdUser = @IdUser,
				    @Note = @Note 

				IF @Note LIKE '%Closed Account%'
					Begin
						EXECUTE [Corp].[st_InsertDenyListIssuerChecks_Checks] @IdUser, @IdCheck, @ReturnDate, @FileName, 1
					End

				EXEC [Corp].[InsCheckRejectHistory] @IdCheck, @IdUser, @Note, @ReturnDate
			END
		
		DELETE #CurrentXmlDetails WHERE @IdCheck = id_check_
		SET @count = (SELECT COUNT(1) FROM #CurrentXmlDetails)
		
	END
	SELECT IdStatus, IdAgent, Amount  FROM dbo.Checks WITH (nolock) WHERE IdCheck = @IdCheck
	DROP TABLE #CurrentXmlDetails
 END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Corp].[st_BulkRejetedChekfromXml_Checks]', GETDATE(), @ErrorMessage)
END CATCH



