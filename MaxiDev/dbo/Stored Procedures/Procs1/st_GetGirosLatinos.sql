
CREATE procedure [dbo].[st_GetGirosLatinos]                              
As                              
                                  
--- Get Minutes to wait to be send to service ---                                  
Declare @MinutsToWait Int                                  
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                           
--Set @MinutsToWait=0                                 
                                  
---  Update transfer to Attempt -----------------                                  
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=9 and  IdStatus=20                                
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                      
--------- Tranfer log ---------------------------                              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                               
Select 21,IdTransfer,GETDATE() from #temp          
        
-------- Generación de serial para giros latinos ---------------        
Insert into GirosLatinosSerial (IdTransfer)        
Select IdTransfer from  #temp Where IdTransfer Not in (Select IdTransfer From GirosLatinosSerial)                 
         
                           
Select                               
1 as Request_Type,                              
'maxtrans' as [User],                              
'¡MxTR$F' as Password,                              
61 as AgentId,                              
DateOfTransfer as DateCreated,                              
convert(varchar(25),C.IdGirosLatinos) as Receipt_Number,                              
ClaimCode as  Receipt_Password,          
'' as Receipt_Reference,                              
'' as Receipt_Reference_2,                      
'USD' as ORIGIN_CURRENCY_CODE,                      
--'LEM' as Currency_Code,                              
case (ISNULL(cu.CurrencyCode,''))
when 'HNL' THEN 'LEM'
when '' THEN 'LEM'
ELSE CU.CurrencyCode
END
 as Currency_Code,                              

--AmountInDollars as Amount_Sent,                              
--ExRate as Exchange_Rate,                              
--AmountInMN as Amount_to_pay,      

case 
    when isnull(UseRefExrate,0) = 0 then A.AmountInDollars 
    else dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)
end
as Amount_Sent,                              
case 
    when isnull(UseRefExrate,0) = 0 then A.ExRate 
    else A.referenceexrate
end
as Exchange_Rate,                              
case 
    when isnull(UseRefExrate,0) = 0 then A.AmountInMN 
    else dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)*A.referenceexrate
end
as Amount_to_pay,      
                        
Case IdPaymentType When 1 Then '1'                              
       When 2 Then '2'  End as Payment_Type_Code,                              
'' as BankCode,                              
'' as Bank_Name,                              
DepositAccountNumber as Bank_Account_number,                      
'' as BANK_ACCOUNT_TYPE_CODE,                              
 --GatewayBranchCode as Payment_office_code,    
 CASE D.PayerCode when 'GL01' THEN D.PayerCode 
 ELSE
 CASE(D.PayerCode+ CASE GatewayBranchCode WHEN '0' THEN '' ELSE LTRIM(RTRIM(GatewayBranchCode)) END)        
   WHEN 'CON1' THEN 'CON01'        
   WHEN 'CON2' THEN 'CON02'        
   WHEN 'CON3' THEN 'CON03'        
   WHEN 'CON4' THEN 'CON04'        
   WHEN 'CON5' THEN 'CON05'        
   WHEN 'CON6' THEN 'CON06'        
   WHEN 'CON7' THEN 'CON07'        
   WHEN 'CON8' THEN 'CON08'        
   WHEN 'CON9' THEN 'CON09'        
   ELSE        
   (case(D.PayerCode) when 'FACACH' then '' else D.PayerCode end+ CASE GatewayBranchCode WHEN '0' THEN '' ELSE LTRIM(RTRIM(GatewayBranchCode)) End) End 
   END as Payment_office_code,    

    --(D.PayerCode+ CASE GatewayBranchCode WHEN '0' THEN '' ELSE LTRIM(RTRIM(GatewayBranchCode)) End) End as Payment_office_code,    

'' as Receiver_Identification,                              
'' as Receiver_Identification_Type,                              
BeneficiaryName  as Receiver_name,                              
BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as Receiver_LastName,                              
BeneficiaryAddress as Receiver_Address,                              
BeneficiaryPhoneNumber as Receiver_Telephone,                              
BeneficiaryCelularNumber as Receiber_Telephone_Mobile,                              
'' as Receiver_Email,                              
substring(BeneficiaryZipcode,1,10) as Receiver_Zip,                              
BeneficiaryCity as Receiver_City,                              
BeneficiaryCountry as Receiver_Country,                              
'' as Receiver_Message,                              
----------------------------------------------------------------    
case when CustomerIdentificationNumber ='' Then Null Else convert(varchar(13),CustomerIdentificationNumber) End as Sender_Identification,                            
--'123' as Sender_Identification,                              
-- isNull(B.Name,'') as Sender_Identification_Type,                              
'drivers licence' as Sender_Identification_Type,                              
CustomerName as Sender_Name,                              
CustomerFirstLastName+' '+CustomerSecondLastName as Sender_LastName,                              
CustomerAddress as Sender_Address,                              
CustomerPhoneNumber as Sender_Telephone,                              
'' as Sender_Email,                 
CustomerZipcode as Sender_zip,                              
CustomerCity as Sender_City,                              
--CustomerCountry as Sender_Country,                              
'' as Sender_Country,                              
'US' as Sender_Country_Code,                              
'' as SenderFile,                              
'' as Special_comments                              
From Transfer A                              
Left Join CustomerIdentificationType B on (A.CustomerIdCustomerIdentificationType=B.IdCustomerIdentificationType)              
Join GirosLatinosSerial C on (A.IdTransfer=C.IdTransfer)    
Join Payer D on (A.IdPayer=D.IdPayer)          
join CountryCurrency cc on cc.IdCountryCurrency=a.IdCountryCurrency        
join Currency cu on cu.IdCurrency=cc.IdCurrency  
left join CountryExrateConfig cex on cc.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway=9 and IdStatus=21        