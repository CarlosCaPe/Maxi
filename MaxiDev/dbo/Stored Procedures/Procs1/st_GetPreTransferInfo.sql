-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-04-08
-- Description:	Returns pretransfer data // This stored is used in FrontOffice - Search pretransfer
-- =============================================											
CREATE PROCEDURE [dbo].[st_GetPreTransferInfo] --27549299
(
    @IdPreTransfer INT    
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2016-04-08" Author="Francisco Lara">Returns pretransfer data // This stored is used in FrontOffice - Search pretransfer</log>
<log Date="2017/10/30" Author="snevarez"> S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="07/12/2017" Author="Snevarez"> Fix:0000737: Borrar datos de información de envío </log>
<log Date="13/12/2017" Author="snevarez"> Fix 0000478: Carga errónea de ciudad en la realización de envíos de dinero(Deposito)</log>
<log Date="13/11/2019" Author="adominguez"> M00056: Se agrega campo IdTransfer</log>
<log Date="12/14/2021" Author="jcsierra">SD-1217: Add Discount, OperationFee</log>
</ChangeLog>
********************************************************************/
begin try
	DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

/*Fix:0000737 - Begin*/
declare @IdPaymentTypeDeposit int  
set @IdPaymentTypeDeposit = 2;

declare @IdPaymentTypeMobileWallet int  
set @IdPaymentTypeMobileWallet = 5;

declare @IdPaymentTypeAtm int  
set @IdPaymentTypeAtm = 6;
/*Fix:0000737 - End*/

if exists (Select 1 from PreTransfer with(nolock) where IdPreTransfer = @IdPreTransfer)
Begin
	SELECT distinct
		T.IdPreTransfer
		, T.IdCustomer
		, T.IdBeneficiary
		, T.IdPaymentType
		, T.IdBranch
		, T.IdPayer
		, T.IdGateway
		, T.GatewayBranchCode
		, T.IdAgentPaymentSchema
		, T.IdAgent
		, T.IdAgentSchema
		, T.IdCountryCurrency
		, T.AmountInDollars
		, T.Fee
		, T.AgentCommission
		, T.CorporateCommission
		, T.DateOfPreTransfer
		, T.ExRate
		, T.ReferenceExRate
		, T.AmountInMN
		, T.Folio
		, T.DepositAccountNumber
		, T.DateOfLastChange
		, T.EnterByIdUser
		, T.TotalAmountToCorporate
		, T.BeneficiaryName
		, T.BeneficiaryFirstLastName
		, T.BeneficiarySecondLastName
		, T.BeneficiaryAddress
		, T.BeneficiaryCity
		, T.BeneficiaryState
		, T.BeneficiaryCountry
		, T.BeneficiaryZipcode
		, T.BeneficiaryPhoneNumber
		, T.BeneficiaryCelularNumber
		, T.BeneficiarySSNumber
		, T.BeneficiaryBornDate
		, T.BeneficiaryOccupation
		, T.BeneficiaryNote
		, T.CustomerName
		, T.CustomerIdAgentCreatedBy
		, CU.IdCustomerIdentificationType AS CustomerIdCustomerIdentificationType
		, T.CustomerFirstLastName
		, T.CustomerSecondLastName
		, T.CustomerAddress
		, T.CustomerCity
		, T.CustomerState
		, T.CustomerCountry
		, T.CustomerZipcode
		, T.CustomerPhoneNumber
		, T.CustomerCelullarNumber
		, CU.SSNumber as CustomerSSNumber
		, T.CustomerBornDate
		, CU.IdSubcategoryOccupation--
		, CU.Occupation
		, CU.OccupationDetail --
		, CU.SubcategoryOccupationOther--
		, CU.HasAnswerTaxId --
		, CU.IdTypeTax--
		, CU.IdOccupation --
		, CU.IdentificationNumber as CustomerIdentificationNumber
		, T.CustomerExpirationIdentification
		, T.IdOnWhoseBehalf
		, T.Purpose
		, T.Relationship
		, T.MoneySource
		, T.AgentCommissionExtra
		, T.AgentCommissionOriginal
		, T.ModifierCommissionSlider
		, T.ModifierExchangeRateSlider
		, T.CustomerIdCarrier
		, T.IdSeller
		, T.OriginExRate
		, T.OriginAmountInMN
		, T.NoteAdditional
		, CU.IdentificationIdCountry as CustomerIdentificationIdCountry 
		, T.CustomerIdentificationIdState
		, CV.CardNumber

		,case 
			when T.IdPaymentType = @IdPaymentTypeAtm or T.IdPaymentType = @IdPaymentTypeMobileWallet then t.TransferIdCity
			Else
		(SELECT C.IdCity FROM Payer AS P WITH(NOLOCK) 
							left Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
							Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
							Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
						WHERE P.IdPayer = T.IdPayer
						and b.IdBranch = T.IdBranch) 
						end IdCity
		/*Fix:0000737 / 0000478: se excluye los depositos de la validacion (@IdPaymentTypeDeposit) - Begin*/		
		--,case   	   
		--   when T.IdPaymentType in (@IdPaymentTypeMobileWallet) then
		--   ISNULL((
		--		SELECT TOP 1 IdCity FROM Payer AS P WITH(NOLOCK) INNER JOIN Branch B ON B.IdPayer = P.IdPayer 
		--		WHERE P.IdPayer = T.IdPayer
		--   ),T.IdCity)
		--   else T.IdCity  
		--   end  AS IdCity
		/*Fix:0000737 - End*/

		, T.StateTax
		, T.OWBRuleType
		, T.TransferAmount
		, OWB.Name OWBName
		, OWB.FirstLastName OWBFirstLastName
		, OWB.SecondLastName OWBSecondLastName
		, OWB.Address OWBAddress
		, OWB.City OWBCITY
		, OWB.State OWBState
		, OWB.Zipcode OWBZipcode
		, OWB.PhoneNumber OWBPhoneNumber
		, OWB.CelullarNumber OWBCelullarNumber
		, OWB.SSNumber OWBSSNumber
		, OWB.BornDate OWBBornDate
		, OWB.Occupation OWBOccupation
		, OWB.IdentificationNumber OWBIdentificationNumber
		, OWB.IdCustomerIdentificationType OWBIdCustomerIdentificationType
		, OWB.ExpirationIdentification OWBExpirationIdentification
		, OWB.Purpose OWBPurpose
		, OWB.Relationship OWBRelationship
		, OWB.MoneySource OWBMoneySource   
		, (SELECT  S.IdState FROM Payer AS P WITH(NOLOCK) 
							left Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
							Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
							Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
						WHERE P.IdPayer = T.IdPayer
						and b.IdBranch = T.IdBranch) IdState
		
		--, C.IdState
		/*Fix:0000737 / 0000478: se excluye los depositos de la validacion (@IdPaymentTypeDeposit)- Begin*/		
		--,case   	   
		--	when T.IdPaymentType in (@IdPaymentTypeMobileWallet) then
		--		ISNULL((
		--				SELECT TOP 1 S.IdState FROM Payer AS P WITH(NOLOCK) 
		--					Inner Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
		--					Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
		--					Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
		--				WHERE P.IdPayer = T.IdPayer
		--	),C.IdState)
		--else C.IdState  
		--end  AS IdState
		/*Fix:0000737 - End*/

		, T.IdTransferResend
		, T.IdBeneficiaryIdentificationType
		, T.BeneficiaryIdentificationNumber
		, T.BeneficiaryIdCountryOfBirth
		, T.CustomerIdCountryOfBirth
		, ISNULL([CN].[AllowSentMessages],0) [ReceiveSms]
		, T.[AccountTypeId]

		/*S44:REQ. MA.025 - Begin*/
		, T.CustomerOccupationDetail AS OccupationDetail  
		, T.TransferIdCity    
          , T.BeneficiaryIdCarrier
		/*S44:REQ. MA.025 - End*/

		,T.IdTransfer --//M00056
		, 
		T.OperationFee,
		T.Discount,
		T.IdPaymentMethod
	FROM [dbo].[PreTransfer] T WITH (NOLOCK)
		inner join Agent A on A.IdAgent=T.IdAgent
	    JOIN [dbo].[Customer] CU WITH (NOLOCK) ON T.[IdCustomer] = CU.[IdCustomer]
	    LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
	    LEFT JOIN [dbo].[OnWhoseBehalf] OWB WITH (NOLOCK) ON T.[IdOnWhoseBehalf]=OWB.[IdOnWhoseBehalf]
	    LEFT JOIN [dbo].[City] C WITH (NOLOCK) ON T.[IdCity]=C.[IdCity]
		LEFT JOIN [dbo].[CardVIP] CV WITH (NOLOCK) on CV.[IdCustomer] = CU.[IdCustomer]
		left join StateFee SF on SF.IdTransfer=T.IdTransfer
	WHERE T.[IdPreTransfer]=@IdPreTransfer;
End
Else
Begin
	SELECT distinct
		T.IdTransfer IdPreTransfer
		, T.IdCustomer
		, T.IdBeneficiary
		, T.IdPaymentType
		, T.IdBranch
		, T.IdPayer
		, T.IdGateway
		, T.GatewayBranchCode
		, T.IdAgentPaymentSchema
		, T.IdAgent
		, T.IdAgentSchema
		, T.IdCountryCurrency
		, T.AmountInDollars
		, T.Fee
		, T.AgentCommission
		, T.CorporateCommission
		, T.DateOfTransfer
		, T.ExRate
		, T.ReferenceExRate
		, T.AmountInMN
		, T.Folio
		, T.DepositAccountNumber
		, T.DateOfLastChange
		, T.EnterByIdUser
		, T.TotalAmountToCorporate
		, T.BeneficiaryName
		, T.BeneficiaryFirstLastName
		, T.BeneficiarySecondLastName
		, T.BeneficiaryAddress
		, T.BeneficiaryCity
		, T.BeneficiaryState
		, T.BeneficiaryCountry
		, T.BeneficiaryZipcode
		, T.BeneficiaryPhoneNumber
		, T.BeneficiaryCelularNumber
		, T.BeneficiarySSNumber
		, T.BeneficiaryBornDate
		, T.BeneficiaryOccupation
		, T.BeneficiaryNote
		, T.CustomerName
		, T.CustomerIdAgentCreatedBy
		, CU.IdCustomerIdentificationType AS CustomerIdCustomerIdentificationType
		, T.CustomerFirstLastName
		, T.CustomerSecondLastName
		, T.CustomerAddress
		, T.CustomerCity
		, T.CustomerState
		, T.CustomerCountry
		, T.CustomerZipcode
		, T.CustomerPhoneNumber
		, T.CustomerCelullarNumber
		, CU.SSNumber as CustomerSSNumber
		, T.CustomerBornDate
		, CU.IdSubcategoryOccupation--
		, CU.Occupation
		, CU.OccupationDetail --
		, CU.SubcategoryOccupationOther--
		, CU.HasAnswerTaxId --
		, CU.IdTypeTax--
		, CU.IdOccupation --
		, CU.IdentificationNumber as CustomerIdentificationNumber
		, T.CustomerExpirationIdentification
		, T.IdOnWhoseBehalf
		, T.Purpose
		, T.Relationship
		, T.MoneySource
		, T.AgentCommissionExtra
		, T.AgentCommissionOriginal
		, T.ModifierCommissionSlider
		, T.ModifierExchangeRateSlider
		, T.CustomerIdCarrier
		, T.IdSeller
		, T.OriginExRate
		, T.OriginAmountInMN
		, T.NoteAdditional
		, CU.IdentificationIdCountry as CustomerIdentificationIdCountry 
		, T.CustomerIdentificationIdState
		, CV.CardNumber
		,case 
			when T.IdPaymentType = @IdPaymentTypeAtm or T.IdPaymentType = @IdPaymentTypeMobileWallet then t.TransferIdCity
			Else
		(SELECT C.IdCity FROM Payer AS P WITH(NOLOCK) 
							left Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
							Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
							Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
						WHERE P.IdPayer = T.IdPayer
						and b.IdBranch = T.IdBranch) 
						end IdCity
		--,(SELECT TOP 1 IdCity FROM Payer AS P WITH(NOLOCK) INNER JOIN Branch B ON B.IdPayer = P.IdPayer WHERE P.IdPayer = T.IdPayer) AS IdCity
		, Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdPreTransfer) ) as StateTax
		, '' OWBRuleType
		, T.AmountInDollars TransferAmount
		, OWB.Name OWBName
		, OWB.FirstLastName OWBFirstLastName
		, OWB.SecondLastName OWBSecondLastName
		, OWB.Address OWBAddress
		, OWB.City OWBCITY
		, OWB.State OWBState
		, OWB.Zipcode OWBZipcode
		, OWB.PhoneNumber OWBPhoneNumber
		, OWB.CelullarNumber OWBCelullarNumber
		, OWB.SSNumber OWBSSNumber
		, OWB.BornDate OWBBornDate
		, OWB.Occupation OWBOccupation
		, OWB.IdentificationNumber OWBIdentificationNumber
		, OWB.IdCustomerIdentificationType OWBIdCustomerIdentificationType
		, OWB.ExpirationIdentification OWBExpirationIdentification
		, OWB.Purpose OWBPurpose
		, OWB.Relationship OWBRelationship
		, OWB.MoneySource OWBMoneySource 
		,(SELECT S.IdState FROM Payer AS P WITH(NOLOCK) 
							left Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
							Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
							Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
						WHERE P.IdPayer = T.IdPayer
						and b.IdBranch = T.IdBranch) IdState
		--,case   	   
		--	when T.IdPaymentType in (@IdPaymentTypeMobileWallet) then
		--		ISNULL((
		--				SELECT TOP 1 S.IdState FROM Payer AS P WITH(NOLOCK) 
		--					Inner Join Branch AS B WITH(NOLOCK)  ON P.IdPayer = B.IdPayer
		--					Inner Join City As C WITH(NOLOCK)  ON B.IdCity = C.IdCity
		--					Inner Join State AS S WITH(NOLOCK)  On C.IdState = S.IdState
		--				WHERE P.IdPayer = T.IdPayer
		--	),C.IdState)
		--else C.IdState  
		--end  AS IdState
		, T.IdTransfer IdTransferResend
		, T.IdBeneficiaryIdentificationType
		, T.BeneficiaryIdentificationNumber
		, T.BeneficiaryIdCountryOfBirth
		, T.CustomerIdCountryOfBirth
		, ISNULL([CN].[AllowSentMessages],0) [ReceiveSms]
		, T.[AccountTypeId]
		, T.CustomerOccupationDetail AS OccupationDetail  
		, T.TransferIdCity    
          , T.BeneficiaryIdCarrier,
		  T.OperationFee,
		T.Discount,
		T.IdPaymentMethod
	FROM [dbo].[Transfer] T WITH (NOLOCK)
		inner join Agent A on A.IdAgent=T.IdAgent
	    JOIN [dbo].[Customer] CU WITH (NOLOCK) ON T.[IdCustomer] = CU.[IdCustomer]
	    LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 --AND [CN].[InterCode] = @InterCode
	    LEFT JOIN [dbo].[OnWhoseBehalf] OWB WITH (NOLOCK) ON T.[IdOnWhoseBehalf]=OWB.[IdOnWhoseBehalf]
	    LEFT JOIN [dbo].[City] C WITH (NOLOCK) ON T.[TransferIdCity]=C.[IdCity]
		LEFT JOIN [dbo].[CardVIP] CV WITH (NOLOCK) on CV.[IdCustomer] = CU.[IdCustomer]
		left join StateFee SF on SF.IdTransfer=T.IdTransfer
	WHERE T.[IdTransfer]=@IdPreTransfer;
End
End Try
Begin Catch

	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage=ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetPreTransferInfo',Getdate(),@ErrorMessage);

End Catch
