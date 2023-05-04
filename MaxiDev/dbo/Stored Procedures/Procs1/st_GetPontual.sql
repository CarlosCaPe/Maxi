
/********************************************************************
<Author>  </Author>
<app> Pontual </app>
<Description></Description>
<ChangeLog>
<log>date:19-05-2020, CR M00036, modificate by: jgomez </>
<log>date:04-08-2020, CR M00036, modificate by: jgomez  CR - M00244</>
</ChangeLog>
*********************************************************************/

CREATE Procedure [dbo].[st_GetPontual]                                
AS                                
Set nocount on                                 
                            
--- Get Minutes to wait to be send to service ---                            
Declare @MinutsToWait Int                            
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'   
--set @MinutsToWait=5                         
                            
---  Update transfer to Attempt -----------------                            
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=28 and  IdStatus=20                          
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                
--------- Tranfer log ---------------------------                        
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                         
Select 21,IdTransfer,GETDATE() from #temp                            
                            
                                
Select
A.ClaimCode as  AgentOrderReference,   
A.DateOfTransfer as OrderCreationTime,
A.IdCustomer as SenderUID,
A.CustomerFirstLastName  as SenderLastName,   
A.CustomerName as SenderFirstName, 
'' as SenderCompanyName,
A.CustomerAddress as SenderAddress,                                
A.CustomerCity as SenderCity, 
A.CustomerState as SenderState,  
A.CustomerZipCode as SenderZip,   
'US' as SenderCountry,
[dbo].[fn_RemoveNoNumbers](A.CustomerPhoneNumber) as SenderPhone1,                                
[dbo].[fn_RemoveNoNumbers](A.CustomerCelullarNumber) as SenderPhone2,
'' SenderEmail,
A.CustomerBornDate as SenderDateOfBirth,
ISNULL(E.Name,'') as SenderDocument1Type,
'' as SenderDocument1Issue,
ISNULL(A.CustomerIdentificationNumber,'') as SenderDocument1Number,
CS.ExpirationIdentification as SenderDocument1ExpirationDate, -- M00036
'' as SenderDocument2Type,
'' as SenderDocument2Issue,
'' as SenderDocument2Number,
'' as SenderDocument2ExpirationDate, --M00036
'' as SenderGender, --M00036
'US' as SenderNationality, --M00036
A.IdBeneficiary as RecipientUID,
A.BeneficiaryFirstLastName as RecipientLastName,
A.BeneficiaryName as RecipientFirstName,
'' as RecipientCompany,
A.BeneficiaryAddress as RecipientAddress1,
A.BeneficiaryCity as RecipientCity,
A.BeneficiaryState as RecipientState,
A.BeneficiaryZipcode as RecipientZip,
'BR' as RecipientCountry,
[dbo].[fn_RemoveNoNumbers](A.BeneficiaryPhoneNumber) as RecipientPhone1,
[dbo].[fn_RemoveNoNumbers](A.BeneficiaryCelularNumber) as RecipientPhone2,
'' as RecipientEmail,
A.BeneficiaryBornDate as RecipientDateOfBirth, --M00036
case
	when LEN(A.BeneficiaryIdentificationNumber) = 11 then 'CPF'
	when LEN(A.BeneficiaryIdentificationNumber) = 14 then 'CNPJ'end RecipientDocument1Type,
'' as RecipientDocument1Issuer,
ISNULL(A.BeneficiaryIdentificationNumber,'') as RecipientDocument1Number,
'' as RecipientDocument1ExpirationDate, --M00036
'' as RecipientDocument2Type,
'' as RecipientDocument2Issuer,
'' as RecipientDocument2Number,
'' as RecipientDocument2ExpirationDate, --M00036
case
	when A.IdPaymentType=2 then D.PayerName
	else ''
end as RecipientBankName,
CASE 
	WHEN PC.IdGateway = 28 AND PC.IdPaymentType = 2 AND CONVERT(varchar(10), PA.BankID) IS NULL then  '000'
	WHEN PC.IdGateway = 28 AND PC.IdPaymentType = 2 then CONVERT(varchar(10), PA.BankID)  else '000' end RecipientBankRouting,
--case 
--	when A.IdPayer = 2513 then '1'
--	when A.IdPayer = 2512 then '3'
--	when A.IdPayer = 2517 then '4'
--	when A.IdPayer = 2521 then '21'
--	when A.IdPayer = 2505 then '24'
--	when D.PayerName like '%Banco Alfa%' then '25'
--	when A.IdPayer = 2506 then '31'
--	when A.IdPayer = 2520 then '36'
--	when A.IdPayer = 2515 then '37'
--	when A.IdPayer = 2516 then '41'
--	when A.IdPayer = 2514 then '47'
--	when A.IdPayer = 2523 then '70'
--	when A.IdPayer = 2522 then '73'
--	when D.PayerName like '%Banco Intermedium%' then '77'
--	when D.PayerName like '%UNIPRIME - Cooperativa De Credito Do Norte Do Parana%' then '84'
--	when A.IdPayer = 2501 then '85'
--	when D.PayerName like '%UNIPRIME Central%' then '99'
--	when D.PayerName like '%XP Investimentos Corretora de Cambio%' then '102'
--	when A.IdPayer = 2524 then '104'
--	when D.PayerName like '%Banco Agiplan%' then '121'
--	when D.PayerName like '%BANCO CRESOL%' then '133'
--	when D.PayerName like '%CONFEDERACAO NACIONAL DAS COOPERATIVAS CENTRAIS UNICRED%' then '136'
--	when D.PayerName like '%Banco Btg Pactual%' then '208'
--	when D.PayerName like '%Banco Original%' then '212'
--	when D.PayerName like '%Banco Bonsucesso%' then '218'
--	when A.IdPayer = 2508 then '237'
--	when D.PayerName like '%Banco Maxima%' then '243'
--	when A.IdPayer = 2502 then '246'
--	when D.PayerName like '%Banco Schahin%' then '250'
--	when D.PayerName like '%PARANA BANCO%'then '254'
--	when D.PayerName like '%NUBANK - NU PAGAMENTOS%'then '260'
--	when D.PayerName like '%Pagseguro Internet%' then '290'
--	when A.IdPayer = 2507 then '318'
--	when D.PayerName like '%Banco CCB Brasil%' then '320'
--	when D.PayerName like '%Banco C6%' then '336'
--	when A.IdPayer = 2526 then '341'
--	when A.IdPayer = 2519 then '356'
--	when A.IdPayer = 2518 then '389'
--	when A.IdPayer = 2525 then '399'
--	when D.PayerName like '%BANCO SAFRA%' then '422'
--	when D.PayerName like '%BANCO RENDIMENTO%' then '633'
--	when A.IdPayer = 2504 then '653'
--	when D.PayerName like '%Banco A.J. Renner%' then '654'
--	when D.PayerName like '%BANCO VOTORANTIM%' then '655'
--	when D.PayerName like '%BANCO NEON%' then '753'
--	when A.IdPayer = 2509 then '745'
--	when A.IdPayer = 2511 then '749'
--	when A.IdPayer = 2510 then '756'
--	when A.IdPayer = 2503 then '9999'
--	when A.IdPayer = 2528 then '3'
--	else ''
--end as RecipientBankRouting,
case
	when A.IdPaymentType=2 then A.BranchCodePontual
	else ''
end as RecipientBranchID,
case
	when A.IdPaymentType=2 then A.DepositAccountNumber
	else ''
end as RecipientBankAccountNo,
0 as RecipientBankAccountID,
'' as RecipientBankAddress, -- M00036
A.BeneficiaryIdentificationNumber as RecipientTIN,
case
    when A.AccountTypeId=1 then 'Checking' --CR - M00244
	when A.AccountTypeId=2 then 'Savings' --CR - M00244
	else ''
end as RecipientBankAccoutType,
'' as NetAmountSent,
A.Fee as TotalFeeSender,
A.AmountInDollars+A.Fee as TotalCollectedFromSender,
A.ExRate as ExchangeRateSender,
'USD' as CurrencySent,
A.ExRate as ExchangeRateAgent,
(SELECT TOP 1 CommissionNew 
FROM PayerConfigCommission 
where IdPayerConfig = pc.IdPayerConfig and Active = 1 
order by DateOfLastChange desc) as TotalFeeAgent,
0 as TotalDueFromAgent,
A.AmountInMN as AmountReceived,
0 as TotalRecipiententFee,
0 as TotalPaidToRecipient,
J.CurrencyCode CurrencyOfPayment,
0 as CurrencyOfPaymentID,
'' as ChallengeQuestion,
'' as ChallengeAnswer,
0 as PayLocationID, 
'' as PaymentLocation,
'' as MessageToRecipient,
'' as PaymentInstructions,
case
	when A.IdPaymentType=1 then 'Cash'
	when A.IdPaymentType=2 then 'Bank Deposit'
	else ''
end as TypeOfPaymentText,
case
	when A.IdPaymentType=1 then 3
	when A.IdPaymentType=2 then 31
	else 0
end as TypeOfPaymentID,
'' as OrderClaimCode,
'' as Custom1,
'' as Custom2,
'' as Custom3,
'' as Custom4,
ISNULL(A.CustomerOccupation,'') SenderOccupation,
ISNULL(A.Relationship,'') RelationshipToSender,
ISNULL(A.Purpose,'') PurposeOfOrder,
ISNULL(A.MoneySource,'') OrderFundSource,
0 as OrderCardSurcharge, -- M00036
0 as AdditionalChargesDiscounts, -- M00036
'' as ChargesDiscountsDescription -- M00036
From Transfer A   
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)                                
Join Agent C On (A.IdAgent=C.IdAgent)                                
Join Payer D on (D.IdPayer=A.IdPayer)                                
Left Join CustomerIdentificationType E on (E.IdCustomerIdentificationType=A.CustomerIdCustomerIdentificationType)                                
Join Country F on (F.IdCountry=B.IdCountry)                      
left Join Branch G on (A.IdBranch=G.IdBranch)                          
Join Currency J on (J.IdCurrency=B.IdCurrency)                                  
left join [BeneficiaryIdentificationType] benid on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
left join CountryExrateConfig cex on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
inner join Customer CS on (CS.IdCustomer = A.IdCustomer)
join PayerConfig PC on (PC.IdPayerConfig = (select top 1 IdPayerConfig from PayerConfig where IdPayer = A.IdPayer order by DateOfLastChange desc))
left Join [dbo].[PontualAvailableBanks] PA on (PA.BankName = D.PayerName)
where a.IdGateway=28 and IdStatus=21 
--order by A.IdTransfer desc