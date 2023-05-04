CREATE PROCEDURE [Corp].[st_MoveBackTransfer]
(              
    @IdTransferClosed Int              
)              
As
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2023/04/26" Author="jdarellano">Se agrega campo "DateOfTransferUTC" para el movimiento de TransferClosed a Transfer</log>
<log Date="2023/04/27" Author="maprado"> Se agregan campos de proyectos recientes (dialing code, refund)</log>
</ChangeLog>
********************************************************************/
Begin Transaction                
Begin Try                

-------------------------------------- Move Transfer -------------------------------------------------------                

SET IDENTITY_INSERT dbo.Transfer ON

Insert into Transfer
    (
	   IdTransfer,
	   IdCustomer,
	   IdBeneficiary,
	   IdPaymentType,
	   IdBranch,
	   IdPayer,
	   IdGateway,
	   GatewayBranchCode,
	   IdAgentPaymentSchema,
	   IdAgent,
	   IdAgentSchema,
	   IdCountryCurrency,
	   IdStatus,
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
	   OriginAmountInMN,
	   DateStatusChange,
	   CustomerIdentificationIdCountry ,
	   CustomerIdentificationIdState,
	   IdReasonForCancel,
	   IdBeneficiaryIdentificationType,
	   BeneficiaryIdentificationNumber
	   , [AgentNotificationSent]
	   , [EmailByJobSent]
	   , [FromStandByToKYC]
	   , [AccountTypeId]
	   , [ReviewId] /*S17:Abr/2017*/
	   , FeeSecondary

	   ,CustomerOccupationDetail /*S44:REQ. MA.025*/
	   ,TransferIdCity
	   ,BeneficiaryIdCarrier
	   ,DateOfTransferUTC
	   ,IsValidCustomerPhoneNumber
	   ,IdDialingCodePhoneNumber
	   ,IdDialingCodeBeneficiaryPhoneNumber
	   ,IsRequiredCustomerPhoneNumber
	   ,IsRefunded
    )
    Select
	   IdTransferClosed as IdTransfer,
	   IdCustomer,
	   IdBeneficiary,
	   IdPaymentType,
	   IdBranch,
	   IdPayer,
	   IdGateway,
	   GatewayBranchCode,
	   IdAgentPaymentSchema,
	   IdAgent,
	   IdAgentSchema,
	   IdCountryCurrency,
	   IdStatus,
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
	   OriginAmountInMN,
	   DateStatusChange,
	   CustomerIdentificationIdCountry ,
	   CustomerIdentificationIdState ,
	   IdReasonForCancel ,
	   IdBeneficiaryIdentificationType,
	   BeneficiaryIdentificationNumber
	   , [AgentNotificationSent]
	   , [EmailByJobSent]
	   , [FromStandByToKYC]
	   , [AccountTypeId]
	   , [ReviewId] /*S17:Abr/2017*/
	   , FeeSecondary

	   ,CustomerOccupationDetail /*S44:REQ. MA.025*/
	   ,TransferIdCity
	   ,BeneficiaryIdCarrier
	   ,DateOfTransferUTC
	   ,IsValidCustomerPhoneNumber
	   ,IdDialingCodePhoneNumber
	   ,IdDialingCodeBeneficiaryPhoneNumber
	   ,IsRequiredCustomerPhoneNumber
	   ,IsRefunded
    From dbo.TransferClosed WITH (NOLOCK)
	   Where IdTransferClosed=@IdTransferClosed;

SET IDENTITY_INSERT dbo.Transfer OFF

  
--------------------------------- Transfer Close Detail ---------------------------------------                

SET IDENTITY_INSERT dbo.TransferDetail ON

    Insert into TransferDetail
    (
	   IdTransferDetail,
	   IdStatus,
	   IdTransfer,
	   DateOfMovement
    )
    Select
	   IdTransferClosedDetail,
	   IdStatus,
	   IdTransferClosed,
	   DateOfMovement
    From TransferClosedDetail 
	   Where IdTransferClosed =@IdTransferClosed;

SET IDENTITY_INSERT dbo.TransferDetail OFF

-------------------------------- Transfer Note ---------------------------------                

SET IDENTITY_INSERT dbo.TransferNote ON;

    Insert into TransferNote
    (
	   IdTransferNote,
	   IdTransferDetail,
	   IdTransferNoteType,
	   IdUser,
	   Note,
	   EnterDate
    )
    Select
	   IdTransferClosedNote,
	   A.IdTransferClosedDetail,
	   IdTransferNoteType,
	   IdUser,
	   Note,
	   EnterDate
    From TransferClosedNote A
	   Join TransferClosedDetail B on (A.IdTransferClosedDetail=B.IdTransferClosedDetail)
    Where B.IdTransferClosed = @IdTransferClosed;

SET IDENTITY_INSERT dbo.TransferNote OFF


-------------------------------- Transfer Note Notification---------------------------------                
                
SET IDENTITY_INSERT dbo.TransferNoteNotification ON                 
Insert into  TransferNoteNotification                
			(                
			IdTransferNoteNotification,
			IdTransferNote,
			IdMessage,
			IdGenericStatus
			)
		Select                 
			TCNN.IdTransferClosedNoteNotification,
			TCNN.IdTransferClosedNote,
			TCNN.IdMessage,
			TCNN.IdGenericStatus
		From TransferClosedNoteNotification TCNN
			Inner Join TransferClosedNote TCN on (TCNN.IdTransferClosedNote = TCN.IdTransferClosedNote)
			Inner Join TransferClosedDetail TCD on (TCN.IdTransferClosedDetail = TCD.IdTransferClosedDetail)
		Where TCD.IdTransferClosed = @IdTransferClosed               
SET IDENTITY_INSERT dbo.TransferNoteNotification OFF

------------------------------ TransferClosedHolds ---------------------------------

INSERT INTO [dbo].[TransferHolds]
           ([IdTransfer]
           ,[IdStatus]
           ,[IsReleased]
           ,[DateOfValidation]
           ,[DateOfLastChange]
           ,[EnterByIdUser])
select IdTransferClosed,IdStatus,IsReleased,DateOfValidation,DateOfLastChange,EnterByIdUser from TransferClosedHolds Where IdTransferClosed=@IdTransferClosed
                
------------------------------ Inicia Borrado de tablas ----------------------------                
                
                
Delete TransferClosedNoteNotification 
where IdTransferClosedNote in 
	(
		Select IdTransferClosedNote from TransferClosedNote TCN
			Inner Join TransferClosedDetail TCD on (TCN.IdTransferClosedDetail = TCD.IdTransferClosedDetail)
		Where TCD.IdTransferClosed = @IdTransferClosed
	)
 
                
Delete  TransferClosedNote Where IdTransferClosedNote in                 
(                
Select IdTransferClosedNote From  TransferClosedNote A Join TransferClosedDetail B on (A.IdTransferClosedDetail=B.IdTransferClosedDetail)                
Where B.IdTransferClosed =@IdTransferClosed              
)                
                
                
Delete TransferClosedDetail Where IdTransferClosed = @IdTransferClosed              

Delete TransferClosedHolds Where IdTransferClosed=@IdTransferClosed                        
                
Delete TransferClosed Where IdTransferClosed =@IdTransferClosed    
                
Commit               
                
End Try                
Begin Catch                
    Rollback                

    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_MoveBackTransfer',Getdate(),@ErrorMessage)

    print @ErrorMessage;                
    Print 'Error encontrado';
                   
End Catch
