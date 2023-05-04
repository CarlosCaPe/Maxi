CREATE PROCEDURE [MoneyAlert].[st_CustomerChatContacts]
(
@IdPerson int, 
@Language int,
@HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	DECLARE @Result Table 
	(
	Name NVARCHAR(MAX),
	ChatMessage NVARCHAR(MAX),
	EnteredDate NVARCHAR(MAX),
	IdChat INT,
	IdTransfer INT,
	Photo NVARCHAR(MAX),
	IsOnline INT,
	OrderBy INT,
	IdChatDetail INT,
	MessageNotRead INT
	)
	
	
SELECT TOP 40 Name,IdBeneficiary,IdTransfer into #temp1 FROM
(

SELECT BeneficiaryName+' '+BeneficiaryFirstLastName as Name, IdBeneficiary, IdTransfer 
FROM Transfer WITH(NOLOCK)  WHERE IdCustomer IN (SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile=@IdPerson)
AND IdBeneficiary NOT IN 
( SELECT ISNULL(B.IdBeneficiary,0) FROM MoneyAlert.Chat A
	LEFT JOIN MoneyAlert.Beneficiary B ON (A.IdBeneficiaryMobile=A.IdBeneficiaryMobile)
	LEFT JOIN MoneyAlert.Customer C ON (A.IdCustomerMobile=C.IdCustomerMobile)
  WHERE C.IdCustomerMobile=@IdPerson
)
  
 Union All


SELECT BeneficiaryName+' '+BeneficiaryFirstLastName as Name, IdBeneficiary,  IdTransferClosed as IdTransfer
FROM TransferClosed WITH(NOLOCK)  WHERE IdCustomer IN (SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile=@IdPerson)
AND IdBeneficiary NOT IN 
( SELECT ISNULL(B.IdBeneficiary,0) FROM MoneyAlert.Chat A
	LEFT JOIN MoneyAlert.Beneficiary B ON (A.IdBeneficiaryMobile=A.IdBeneficiaryMobile)
	LEFT JOIN MoneyAlert.Customer C ON (A.IdCustomerMobile=C.IdCustomerMobile)
  WHERE C.IdCustomerMobile=@IdPerson
)

) m ORDER BY IdTransfer DESC

Select distinct Name,IdBeneficiary into #temp2 FROM #temp1

    

		SELECT MAX(IdChatDetail) IdChatDetail, A.IdChat  into #temp3 FROM MoneyAlert.ChatDetail A
		JOIN MoneyAlert.Chat B ON (A.IdChat=B.IdChat)
		WHERE B.IdCustomerMobile=@IdPerson
		Group By A.IdChat


		SELECT Count(1) as MessageNotRead, A.IdChat  into #tempCount FROM MoneyAlert.ChatDetail A
		JOIN MoneyAlert.Chat B ON (A.IdChat=B.IdChat)
		WHERE B.IdCustomerMobile=@IdPerson AND A.ChatMessageStatusId=1 AND A.IdPersonRole=2
		Group By A.IdChat

		INSERT INTO @Result (Name,ChatMessage,EnteredDate,IdChat,IdTransfer,Photo,IsOnline,OrderBy,IdChatDetail,MessageNotRead)
		SELECT D.Name as Name,C.ChatMessage,
		CASE WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate(),101)
				 THEN RIGHT(CONVERT(VARCHAR(30), C.EnteredDate, 0), 8) 
				  
			WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate()-1,101) AND @Language=2
				 THEN  'Ayer'

			WHEN CONVERT(VARCHAR(11),C.EnteredDate,101)=CONVERT(VARCHAR(11),Getdate()-1,101) AND @Language=1
				 THEN  'Yesterday'

			ELSE CONVERT(VARCHAR(11),C.EnteredDate,106) 
			END AS EnteredDate,
		A.IdChat,0 as IdTransfer,ISNULL(D.Photo,'') as Photo,ISNULL(D.IsOnline,0) as IsOnline,
		CASE WHEN D.Name='MAXI' Then 0 ELSE 1 END as OrderBy,
		C.IdChatDetail,
		IsNULL(E.MessageNotRead,0) as MessageNotRead
		FROM MoneyAlert.Chat A WITH(NOLOCK)
		JOIN #temp3 B ON (A.IdChat=B.IdChat)
		JOIN MoneyAlert.ChatDetail C on (B.IdChatDetail=C.IdChatDetail)
		JOIN MoneyAlert.BeneficiaryMobile D ON (A.IdBeneficiaryMobile=D.IdBeneficiaryMobile)
		LEFT JOIN #tempCount E ON (A.IdChat=E.IdChat)
		UNION ALL
		SELECT Name,
		'' as ChatMessage,
		NULL as EnteredDate,
		0 as IdChat,
		(Select top 1 IdTransfer FROM #temp1 WHERE IdBeneficiary=A.IdBeneficiary  ) as IdTransfer, '' as Photo,0 as IsOnline,
		2 as OrderBy,
		 0 as IdChatDetail,
		 0 as MessageNotRead  FROM #temp2 A
		Order by Orderby,idChatDetail desc

		SELECT Name,ChatMessage,EnteredDate,IdChat,IdTransfer,Photo,IsOnline,MessageNotRead FROM @Result

       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH





