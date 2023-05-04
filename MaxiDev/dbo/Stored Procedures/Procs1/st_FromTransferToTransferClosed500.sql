CREATE PROCEDURE [dbo].[st_FromTransferToTransferClosed500]
as    
Set nocount on     
      
Begin tran    
Begin Try    
              
Truncate Table TransferToBeClosed      

Insert into TransferToBeClosed (IdTransfer,IdOnWhoseBehalf)
Select TOP 500 IdTransfer,IdOnWhoseBehalf From Transfer where Idstatus in (30,31,22,28)



Declare @Contador Int
Select @Contador=COUNT(1) from TransferToBeClosed

               
-------------------------------------- Move Transfer -------------------------------------------------------
Insert into TransferClosed
(
IdTransferClosed,
IdCustomer,
IdBeneficiary,
IdPaymentType,
PaymentTypeName,
IdBranch,
BranchName,
IdPayer,
PayerName,
IdGateway,
GatewayName,
GatewayBranchCode,
IdAgentPaymentSchema,
AgentPaymentSchema,
IdAgent,
AgentName,
IdAgentSchema,
SchemaName,
IdCountryCurrency,
IdCountry,
CountryName,
IdCurrency,
CurrencyName,
IdStatus,
StatusName,
ClaimCode,
ConfirmationCode,
AmountInDollars,
Fee,
AgentCommission,
CorporateCommission,
DateOfTransfer,
ExRate,
ReferenceExRate,
AmountInMN,
Folio,
DepositAccountNumber,
DateOfLastChange,
EnterByIdUser,
TotalAmountToCorporate,
BeneficiaryName,
BeneficiaryFirstLastName,
BeneficiarySecondLastName,
BeneficiaryAddress,
BeneficiaryCity,
BeneficiaryState,
BeneficiaryCountry,
BeneficiaryZipcode,
BeneficiaryPhoneNumber,
BeneficiaryCelularNumber,
BeneficiarySSNumber,
BeneficiaryBornDate,
BeneficiaryOccupation,
BeneficiaryNote,
CustomerName,
CustomerIdAgentCreatedBy,
CustomerIdCustomerIdentificationType,
CustomerFirstLastName,
CustomerSecondLastName,
CustomerAddress,
CustomerCity,
CustomerState,
CustomerCountry,
CustomerZipcode,
CustomerPhoneNumber,
CustomerCelullarNumber,
CustomerSSNumber,
CustomerBornDate,
CustomerOccupation,
CustomerIdentificationNumber,
CustomerExpirationIdentification,
IdOnWhoseBehalf,
Purpose,
Relationship,
MoneySource,
AgentCommissionExtra,
AgentCommissionOriginal,
ModifierCommissionSlider,
ModifierExchangeRateSlider,
CustomerIdCarrier,
IdSeller,
ReviewDenyList,
ReviewOfac,
ReviewKyc,            
OriginExRate,            
OriginAmountInMn,        
DateStatusChange ,
CustomerIdentificationIdCountry ,
CustomerIdentificationIdState   ,
IdReasonForCancel ,
IdBeneficiaryIdentificationType,
BeneficiaryIdentificationNumber   ,
ReviewRejected
, [AgentNotificationSent]
, [EmailByJobSent]
, [FromStandByToKYC]
, [AccountTypeId]
, [ReviewId]	/*S17:Abr/2017*/
)
Select 
T.IdTransfer as  IdTransferClosed,
T.IdCustomer,
T.IdBeneficiary,
T.IdPaymentType,
A.PaymentName  as PaymentTypeName,
T.IdBranch,
B.BranchName,
T.IdPayer,
C.PayerName,
T.IdGateway,
D.GatewayName,
T.GatewayBranchCode,
T.IdAgentPaymentSchema,
E.PaymentName as AgentPaymentSchema,
T.IdAgent,
F.AgentName,
T.IdAgentSchema,
G.SchemaName,
T.IdCountryCurrency,
I.IdCountry,
I.CountryName,
J.IdCurrency,
J.CurrencyName,
T.IdStatus,
K.StatusName,
T.ClaimCode,
T.ConfirmationCode,
T.AmountInDollars,
T.Fee,
T.AgentCommission,
T.CorporateCommission,
T.DateOfTransfer,
T.ExRate,
T.ReferenceExRate,
T.AmountInMN,
T.Folio,
T.DepositAccountNumber,
T.DateOfLastChange,
T.EnterByIdUser,
T.TotalAmountToCorporate,
T.BeneficiaryName,
T.BeneficiaryFirstLastName,          
T.BeneficiarySecondLastName,
T.BeneficiaryAddress,
T.BeneficiaryCity,
T.BeneficiaryState,
T.BeneficiaryCountry,
T.BeneficiaryZipcode,
T.BeneficiaryPhoneNumber,
T.BeneficiaryCelularNumber,
T.BeneficiarySSNumber,
T.BeneficiaryBornDate,
T.BeneficiaryOccupation,
T.BeneficiaryNote,
T.CustomerName,
T.CustomerIdAgentCreatedBy,
T.CustomerIdCustomerIdentificationType,
T.CustomerFirstLastName,
T.CustomerSecondLastName,
T.CustomerAddress,
T.CustomerCity,
T.CustomerState,
T.CustomerCountry,
T.CustomerZipcode,
T.CustomerPhoneNumber,
T.CustomerCelullarNumber,
T.CustomerSSNumber,
T.CustomerBornDate,
T.CustomerOccupation,
T.CustomerIdentificationNumber,
T.CustomerExpirationIdentification,
T.IdOnWhoseBehalf,
T.Purpose,
T.Relationship,
T.MoneySource,
T.AgentCommissionExtra,
T.AgentCommissionOriginal,
T.ModifierCommissionSlider,
T.ModifierExchangeRateSlider,
T.CustomerIdCarrier,
T.IdSeller,
T.ReviewDenyList,
T.ReviewOfac,
T.ReviewKyc,            
T.OriginExRate,            
T.OriginAmountInMn,        
T.DateStatusChange ,
T.CustomerIdentificationIdCountry ,
T.CustomerIdentificationIdState  ,
IdReasonForCancel   ,
IdBeneficiaryIdentificationType,
BeneficiaryIdentificationNumber,
ReviewRejected
, T.[AgentNotificationSent]
, T.[EmailByJobSent]
, T.[FromStandByToKYC]
, T.[AccountTypeId]
, T.[ReviewId]	/*S17:Abr/2017*/
From Transfer T WITH (NOLOCK)           
inner Join PaymentType A WITH (NOLOCK) on (T.IdPaymentType=A.IdPaymentType)     
Left  Join Branch B WITH (NOLOCK) on (B.IdBranch=T.IdBranch) 
Inner Join Payer C WITH (NOLOCK) on (C.IdPayer=T.IdPayer)  
Left  Join Gateway D WITH (NOLOCK) on (T.IdGateway=D.IdGateway)
inner join AgentPaymentSchema E WITH (NOLOCK) on  (E.IdAgentPaymentSchema=T.IdAgentPaymentSchema)     
inner join Agent F WITH (NOLOCK) on (F.IdAgent=T.IdAgent)          
Left join AgentSchema G WITH (NOLOCK) on (T.IdAgentSchema=G.IdAgentSchema)
inner Join CountryCurrency H WITH (NOLOCK) on (H.IdCountryCurrency=T.IdCountryCurrency)
inner Join Country I WITH (NOLOCK) on (H.IdCountry=I.IdCountry)    
inner Join Currency J WITH (NOLOCK) on (H.IdCurrency=J.IdCurrency)  
Inner Join Status K WITH (NOLOCK) on (K.IdStatus=T.IdStatus)  
Where IdTransfer In (Select IdTransfer From TransferToBeClosed )

If @@rowcount <> @Contador
 select 5/0
    
Print ('  tabla transferClosed insertada '+convert(varchar,getdate()))    


--------------------------------- Transfer Close Detail ---------------------------------------
           

Insert into TransferClosedDetail
(
IdTransferClosedDetail,
IdStatus,
IdTransferClosed,
DateOfMovement             
)
Select 
IdTransferDetail,
IdStatus,
IdTransfer,
DateOfMovement
From TransferDetail WITH (NOLOCK) Where IdTransfer in (Select IdTransfer From TransferToBeClosed )

Print ('  tabla transferCloseddetail insertada '+convert(varchar,getdate()))    


-------------------------------- Transfer Note ---------------------------------          
          
Insert into  TransferClosedNote
(          
IdTransferClosedNote,          
IdTransferClosedDetail,          
IdTransferNoteType,          
IdUser,          
Note,          
EnterDate          
)
Select 
IdTransferNote,          
A.IdTransferDetail,          
IdTransferNoteType,          
IdUser,          
Note,          
EnterDate          
From TransferNote A WITH (NOLOCK)
Join TransferDetail B WITH (NOLOCK) on (A.IdTransferDetail=B.IdTransferDetail)
Where B.IdTransfer in (Select IdTransfer From TransferToBeClosed )


Print ('  tabla TransferClosedNote insertada '+convert(varchar,getdate()))    


-------------------------------- Transfer Note Notification---------------------------------          

Insert into TransferClosedNoteNotification
		(
		IdTransferClosedNoteNotification,
		IdTransferClosedNote,
		IdMessage,
		IdGenericStatus
		)
	Select 
		TNN.IdTransferNoteNotification,
		TNN.IdTransferNote,
		TNN.IdMessage,
		TNN.IdGenericStatus
	From TransferNoteNotification TNN WITH (NOLOCK)
		inner join TransferNote TN WITH (NOLOCK) on (TNN.IdTransferNote = TN.IdTransferNote)
		inner join TransferDetail TD WITH (NOLOCK) on (TN.IdTransferDetail = TD.IdTransferDetail)
	Where TD.IdTransfer in (Select IdTransfer from TransferToBeClosed WITH (NOLOCK))

        
Print ('  tabla TransferClosedNoteNotification insertada '+convert(varchar,getdate()))    

------------------------------ TransferClosedHolds ---------------------------------

INSERT INTO [dbo].[TransferClosedHolds]
           ([IdTransferClosed]
           ,[IdStatus]
           ,[IsReleased]
           ,[DateOfValidation]
           ,[DateOfLastChange]
           ,[EnterByIdUser])
select IdTransfer,IdStatus,IsReleased,DateOfValidation,DateOfLastChange,EnterByIdUser from TransferHolds WITH (NOLOCK) Where IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))

Print ('  tabla TransferClosedHolds insertada '+convert(varchar,getdate()))  

------------------------------ Inicia Borrado de tablas ----------------------------

Delete  TransferNoteNotification Where IdTransferNote in 
(
Select IdTransferNote From  TransferNote A WITH (NOLOCK) Join TransferDetail B on (A.IdTransferDetail=B.IdTransferDetail)
Where B.IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))
)

Delete  TransferNote Where IdTransferNote in 
(
Select IdTransferNote From  TransferNote A WITH (NOLOCK) Join TransferDetail B on (A.IdTransferDetail=B.IdTransferDetail)
Where B.IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))
)
             
 Print ('  Borrado transferNote  '+convert(varchar,getdate()))    
           

Delete TransferDetail Where IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))
Print ('  borrado transferDetail  '+convert(varchar,getdate()))    
    

Delete TransferHolds Where IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))
Print ('  borrado transferHolds  '+convert(varchar,getdate()))    

             
Delete Transfer Where IdTransfer in (Select IdTransfer From TransferToBeClosed WITH (NOLOCK))
Print ('  borrado transfer  '+convert(varchar,getdate()))    
    
             
Truncate Table TransferToBeClosed
Print ('  Truncate  TransferToBeClosed '+convert(varchar,getdate()))    

    
commit    
    
Print ('  Commit '+convert(varchar,getdate()))    
    
    
End try    
Begin catch    
    
  Select ERROR_MESSAGE()     
  Rollback    
      
  Print ('  Rollback '+convert(varchar,getdate()))    
  

	DECLARE @ProcID VARCHAR(200), @Mess VARCHAR(2000)
	SET @ProcID =OBJECT_NAME(@@PROCID)
	SELECT @Mess = ERROR_MESSAGE()
	
	EXEC sp_MailQueue 
	@Source   =  @ProcID,
	@To 	  =  'soportemaxi@boz.mx',      
	@Subject  =  'Error al pasar Transfer -> TransferClosed',
	@Body  	  =  @Mess
    
End catch



