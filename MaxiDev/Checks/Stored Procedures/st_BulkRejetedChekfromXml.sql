-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Checks].[st_BulkRejetedChekfromXml]
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
			@ReturnDate datetime
			--@IdChecks varchar(max) = ''

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
	
		SELECT TOP 1 @IdCheck = id_check_, @IdStatus=id_status_, @Note= note_, @IdUser= id_user_, @ReturnDate = return_date_ , @FileName = file_Name_
		FROM #CurrentXmlDetails
	
		IF exists (SELECT 1 FROM dbo.Checks with (nolock) WHERE IdCheck=@IdCheck)
			BEGIN
				Update dbo.Checks Set IdStatus=31,DateStatusChange=GETDATE() Where IdCheck = @IdCheck

				execute [Checks].[st_CheckCancelToAgentBalance]
				  @IdCheck 					= @IdCheck,
					@EnterByIdUser 	= @IdUser,
					@IsReject  			= 1 
	
				execute[Checks].[st_SaveChangesToCheckLog]  
					@Idcheck 			= @IdCheck          
					, @IdStatus  	= @IdStatus         
					, @Note    		= @Note     
					, @IdUser  		= @IdUser 

				execute [dbo].[st_RejectCheckNotificationFromBulkCheck]
					@IdCheck   = @IdCheck,
					@EnterByIdUser = @IdUser,
				    @Note = @Note 

				IF @Note LIKE '%Closed Account%'
					Begin
						EXECUTE [Checks].[st_InsertDenyListIssuerChecks] @IdUser, @IdCheck, @ReturnDate, @FileName, 1
					End

					declare @RoutingNumber varchar(max) , @AccountNumber varchar(max),@IdReturnedReason int

					Select @IdReturnedReason = ReturnReason_ID from CheckConfig.ReasonBanksRejetedChecks with(nolock) where MaxiReason = @Note
					Select @RoutingNumber = RoutingNumber, @AccountNumber = Account from Checks with(nolock) where IdCheck = @IdCheck

					INSERT INTO [dbo].[CheckRejectHistory]
									(IdCheck
									,RoutingNumber
									,AccountNumber
									,IdReturnedReason
									,DateOfReject
									,EnterByIdUser
									,CreationDate
									,DateofLastChange)
								VALUES
									(@IdCheck
									,@RoutingNumber
									,@AccountNumber
									,@IdReturnedReason
									,@ReturnDate
									,@IdUser
									,GETDATE()
									,GETDATE())
			END
		
		DELETE #CurrentXmlDetails WHERE @IdCheck = id_check_
		SET @count = (SELECT COUNT(1) FROM #CurrentXmlDetails)
		
	END
	select IdStatus, IdAgent, Amount  from dbo.Checks with (nolock) where IdCheck = @IdCheck
	drop table #CurrentXmlDetails
 END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Checks].[st_BulkRejetedChekfromXml]', GETDATE(), @ErrorMessage)
END CATCH

