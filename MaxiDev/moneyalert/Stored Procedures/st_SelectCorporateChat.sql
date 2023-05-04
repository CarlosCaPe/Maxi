

CREATE PROCEDURE [MoneyAlert].[st_SelectCorporateChat]
(
@IdUser INT,
@Language INT,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	DECLARE @IdPerson INT 
	SET @IdPerson=1
	
		SELECT MAX(IdChatDetail) IdChatDetail, A.IdChat  into #temp2 FROM MoneyAlert.ChatDetail A
		JOIN MoneyAlert.Chat B ON (A.IdChat=B.IdChat)
		WHERE B.IdBeneficiaryMobile=@IdPerson
		Group By A.IdChat


		SELECT Count(1) as MessageNotRead, A.IdChat  into #tempCount FROM MoneyAlert.ChatDetail A
		JOIN MoneyAlert.Chat B ON (A.IdChat=B.IdChat)
		WHERE B.IdBeneficiaryMobile=@IdPerson AND A.ChatMessageStatusId=1  AND A.IdPersonRole=1
		Group By A.IdChat


		SELECT D.Name  as Name,C.ChatMessage,
		CASE WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate(),101)
				 THEN RIGHT(CONVERT(VARCHAR(30), C.EnteredDate, 0), 8) 
				  
			WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate()-1,101) AND @Language=2
				 THEN  'Ayer'

			WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate()-1,101) AND @Language=1
				 THEN  'Yesterday'

			ELSE CONVERT(VARCHAR(11),C.EnteredDate,106) 
			END AS EnteredDate,
		A.IdChat,
		D.Photo as Photo,
		D.IsOnline,
		IsNULL(E.MessageNotRead,0) as MessageNotRead
		FROM MoneyAlert.Chat A
		JOIN #temp2 B ON (A.IdChat=B.IdChat)
		JOIN MoneyAlert.ChatDetail C on (B.IdChatDetail=C.IdChatDetail)
		JOIN MoneyAlert.CustomerMobile D ON (A.IdCustomerMobile=D.IdCustomerMobile)
		LEFT JOIN #tempCount E ON (A.IdChat=E.IdChat)
		Where  A.IdChat  IN (SELECT IdChat FROM MoneyAlert.CorporateChat Where IdUser=@IdUser)
		Order by C.EnteredDate desc
	   
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH



