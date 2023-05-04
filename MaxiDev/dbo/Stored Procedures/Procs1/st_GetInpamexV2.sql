CREATE Procedure [dbo].[st_GetInpamexV2]    
(
    @IsDeposit bit = 0
)                  
AS                
Set nocount on  

declare @PaymentTypeTable table
(
    IdPaymentType int
)

if (@IsDeposit=1)
begin
 insert into @PaymentTypeTable
 select IdPaymentType from PaymentType where IdPaymentType=2
end
else
begin
insert into @PaymentTypeTable
 select IdPaymentType from PaymentType where IdPaymentType!=2
end                                 
                  
--- Get Minutes to wait to be send to service ---                  
Declare @MinutsToWait Int                  
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                  
               
---  Update transfer to Attempt -----------------                  
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=26 and  IdStatus=20 and IdPaymentType in (select IdPaymentType from @PaymentTypeTable)
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                      
--------- Tranfer log ---------------------------              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)               
Select 21,IdTransfer,GETDATE() from #temp     


if (isnull(@IsDeposit,0)=0)
begin
insert into InpamexSerial
(idtransfer)
Select IdTransfer from transfer where IdGateway=26 and  IdStatus=21 and IdPaymentType in (select IdPaymentType from @PaymentTypeTable) and idtransfer not in  (select IdTransfer from InpamexSerial)
end
else
begin
insert into InpamexSerial2
(idtransfer)
Select IdTransfer from transfer where IdGateway=26 and  IdStatus=21 and IdPaymentType in (select IdPaymentType from @PaymentTypeTable) and idtransfer not in  (select IdTransfer from InpamexSerial2)
end     
                    
SELECT --top 20            
-------------------- Remitance --------------------------                      
    A.ClaimCode AS noRemittance,                      
    A.AmountInDollars AS sendAmount,                      
    a.fee AS charges,
    'USD' AS sendCurrency,                      
    A.EXRate AS exchangeRate,                      
    A.AmountinMN AS paidAmount,                      
    D.CurrencyCode AS paidCurrency,     
    '' AS [message],
	A.IdPaymentType,
    CASE IdPaymentType                       
		WHEN 1 THEN 'CASH'                      
		WHEN 2 THEN 'DEPOSIT'
		WHEN 4 THEN 'CASH'
		WHEN 5 THEN 'WALLET'
    END  AS sendType,    
    CASE IdPaymentType                                               
		WHEN 2 THEN 'SAVINGS'                         
    ELSE '' END AS  accountType,                         
    CASE IdPaymentType 
		WHEN 2 THEN A.DepositAccountNumber 
		WHEN 5 THEN A.DepositAccountNumber 
		ELSE '' 
	END AS accountNumber,  
    isnull(s.IdInpamexSerial,isnull(s2.IdInpamexSerial,0)) noSequence,
    isnull(p.PayerName,'') AS banco,
	CASE A.IdPaymentType
		WHEN 5 THEN 'PGFW001'
		ELSE A.GatewayBranchCode
	END AS idSucursalViam, 
	CASE A.IdPaymentType
		WHEN 5 THEN 'PAGOFON WALLET MATRIZ'
		ELSE isnull(f.BranchName,'')
	END AS nombreSucursalViam,

    --------------------------  Sender --------------------    
    a.IdCustomer AS id,                  
    A.CustomerName AS firstName,                      
    A.CustomerFirstLastName AS lastName,                      
    A.CustomerSecondLastName AS secondLastName,                      
    A.CustomerPhoneNumber AS homePhone,                      
    A.CustomerCelullarNumber AS workPhone,                      
    A.CustomerAddress  AS address,        
    '' AS gender,              
    '' AS birthday,
    --convert(varchar,(convert(date,a.CustomerBornDate)))+'T00:00:00' AS birthday,
    A.CustomerCity AS city,
    Isnull(A.CustomerState,'') AS state,  
                    
    CASE	
        WHEN a.CustomerIdCustomerIdentificationType=1 THEN 1
        WHEN a.CustomerIdCustomerIdentificationType=2 THEN 2
        WHEN a.CustomerIdCustomerIdentificationType=3 THEN 4
        WHEN a.CustomerIdCustomerIdentificationType=4 THEN 5
        WHEN a.CustomerIdCustomerIdentificationType=5 THEN 3
        WHEN a.CustomerIdCustomerIdentificationType=6 THEN 1
        WHEN a.CustomerIdCustomerIdentificationType=7 THEN 1
        WHEN a.CustomerIdCustomerIdentificationType=8 THEN 1
        WHEN a.CustomerIdCustomerIdentificationType=9 THEN 4	
        ELSE 0
    END idType,
    CASE	
        WHEN isnull(a.CustomerIdCustomerIdentificationType,0)=0 THEN ''
        ELSE CustomerIdentificationNumber
    END idNumber,
    'USA' AS pais,
    '' AS email,
    A.CustomerZipcode AS ZIP,                      

    -----------  Beneficiary  --------------     
    a.IdBeneficiary bid,                  
    A.BeneficiaryName AS bfirstName,                      
    A.BeneficiaryFirstLastName AS blastName,                      
    A.BeneficiarySecondLastName AS bsecondLastName,                      
    A.BeneficiaryPhoneNumber AS bhomePhone,                      
    A.BeneficiaryCelularNumber AS bworkPhone,                      
    A.BeneficiaryAddress  AS baddress,
    '' AS bgender,                 
    '' AS bbirthday,
    --convert(varchar,(convert(date,a.BeneficiaryBornDate)))+'T00:00:00'  AS bbirthday,
    --A.BeneficiaryCity AS bcity, 
    CASE WHEN isnull(rtrim(ltrim(A.BeneficiaryCity)),'')='' THEN isnull(ci.CityName,'') ELSE A.BeneficiaryCity END AS bcity, 
    Isnull(A.BeneficiaryState,'') AS bdepartment,   
    '' AS btipoDoc,
    '' AS bnoDoc,
    '' AS bnacionalidad
FROM Transfer A                      
    JOIN CountryCurrency B ON (A.IdCountryCurrency=B.IdCountryCurrency)                      
    JOIN Country C ON (C.IdCountry=B.IdCountry)                    
    JOIN Currency D ON (D.IdCurrency=B.IdCurrency)          
    JOIN payer p ON p.IdPayer=a.IdPayer
    LEFT JOIN InpamexSerial s ON a.IdTransfer=s.IdTransfer
    LEFT JOIN InpamexSerial2 s2 ON a.IdTransfer=s2.IdTransfer
    LEFT JOIN CibancoSpei E ON (E.BranchCode=A.GatewayBranchCode)    
    LEFT JOIN branch f ON a.IdBranch=f.IdBranch
    LEFT JOIN city ci ON f.IdCity=ci.IdCity
                      
WHERE A.IdGateway=26 and IdStatus=21 and IdPaymentType in (select IdPaymentType from @PaymentTypeTable)
