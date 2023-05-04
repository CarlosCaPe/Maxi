CREATE procedure [dbo].[st_GetMacroFinanciera]
(            
    @IdFile INT output            
)
As
Set  @IdFile=0 
--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'
--Set @MinutsToWait=0

---  Update transfer to Attempt -----------------
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=15 and  IdStatus=20
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)
--------- Tranfer log ---------------------------                              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp

-------- Generación de serial para MacroFinanciera ---------------        
Insert into MacroFinancieraSerial (IdTransfer)
Select IdTransfer from  #temp Where IdTransfer Not in (Select IdTransfer From MacroFinancieraSerial)

----------------  New consecutive number -------------------        
        
If Exists (      
Select   top 1 1            
From Transfer A                          
Where IdGateway=15 and IdStatus=21              
)        
Begin        
 Update MacroFinancieraGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1
 --Select @IdFile=IdFile from MacroFinancieraGeneradorIdFiles        
End   

------------------LogFileTXT---------------------------------------       
      
delete [MAXILOG].[dbo].MacroFinancieraLogFileTXT where IdTransfer in       
(Select A.IdTransfer from Transfer A            
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)              
Join Currency C on (C.IdCurrency=B.IdCurrency)              
Join Agent D on (D.IdAgent=A.IdAgent)          
Join MacroFinancieraSerial E on (E.IdTransfer=A.IdTransfer)              
Where IdGateway=15 and IdStatus=21)

Insert into [MAXILOG].[dbo].MacroFinancieraLogFileTXT             
(            
    IdTransfer,
    IdFileName,
    DateOfFileCreation,
    TypeOfTransfer
)            
Select IdTransfer,@IdFile,GETDATE(),'Transfer' from transfer Where IdGateway=15 and IdStatus=21

--Select IdTransfer,@IdFile,GETDATE(),'Transfer' from #temp

-----------------------------------------------------------------------

Select                               
C.IdMacroFinanciera                     SECUENCIADELGIRO,
claimcode                               NUMERODEORDEN,
CustomerName                            PRIMERNOMBREREMITENTE,
''                                      SEGUNDONOMBREREMITENTE,
CustomerFirstLastName                   PRIMERAPELLIDOREMITENTE,
CustomerSecondLastName                  SEGUNDOAPELLIDOREMITENTE,
CustomerAddress                         DIRECCIONREMITENTE,
'US'                                    PAISREMITENTE,
upper(ag.agentcity)                     CIUDADREMITENTE,
ag.agentcode                            CODIGOONOMBREOFICINAENVIAGIRO,
BeneficiaryName                         PRIMERNOMBREBENEFICIARIO,
''                                      SEGUNDONOMBREBENEFICIARIO,
BeneficiaryFirstLastName                PRIMERAPELLIDOBENEFICIARIO,
BeneficiarySecondLastName               SEGUNDOAPELLIDOBENEFICIARIO,
null                                    TIPOIDENTIFICACIONBENEFICIARIO,
''                                      NUMEROIDENTIFICACIONBENEFICIARIO,
BeneficiaryAddress                      DIRECCIONDELBENEFICIARIO,
case when ltrim(rtrim(isnull(BeneficiaryPhoneNumber,'')))!=''
     then replace(BeneficiaryPhoneNumber,'-','')
     else '000000000000'
     end
TELEFONO1BENEFICIARIO,
replace(ltrim(rtrim(isnull(BeneficiaryCelularNumber,''))),'-','') TELEFONO2BENEFICIARIOCELULAR,
case 
    when gatewaybranchcode='0043' then 'VIRTUAL'
    else
        isnull(ci.cityname,'VIRTUAL')
    end                                 CIUDADDESTINODELGIRO,
gatewaybranchcode                       OFICINADEPAGO,
case (a.IDpaymenttype)
when 1 then '01'
when 2 then '02'
end
                                        FORMADEPAGO,
AmountInDollars                         VALORENDOLARES,
ExRate                                  TASADECAMBIO,
AmountInMN                              VALORENPESOS,
''                                      MENSAJEDELGIRO,
case
    when payercode='MF01' then 'NOR'
    when payercode='MF02' then 'NOR'
    when payercode='MF03' then 'NOR'
    when payercode='MF04' then 'NOR'
    when payercode='MF05' then 'NOR'
    when payercode='MF06' then 'NOR'
    when payercode='MF07' then 'NOR'
    when payercode='MF08' then 'NOR'
    when payercode='MF09' then 'NOR'
    when payercode='MF10' then 'NOR'
    when payercode='MF11' then 'NOR'
    when payercode='MF12' then 'NOR'
    when payercode='MF13' then 'NOR'
    when payercode='MF14' then 'NOR'
    when payercode='MF15' then 'NOR'
    when payercode='MF16' then 'NOR'
    when payercode='MF17' then 'NOR'
    when payercode='MF18' then 'NOR'
    when payercode='MF19' then 'NOR'
    when payercode='MF22' then 'NOR'
    when payercode='MF20' then 'NOR'
    when payercode='MF21' then 'NOR'
    
    when payercode='MF23' then 'ESP'
    when payercode='MF26' then 'ESP'
    when payercode='MF28' then 'ESP'
    when payercode='MF30' then 'ESP'
    when payercode='MF32' then 'ESP'
    when payercode='MF34' then 'ESP'
    when payercode='MF36' then 'ESP'
    when payercode='MF38' then 'ESP'
    when payercode='MF40' then 'ESP'
    when payercode='MF42' then 'ESP'
    when payercode='MF44' then 'ESP'
    when payercode='MF46' then 'ESP'
    when payercode='MF48' then 'ESP'
    when payercode='MF50' then 'ESP'
    when payercode='MF52' then 'ESP'
    when payercode='MF54' then 'ESP'
    when payercode='MF56' then 'ESP'
    when payercode='MF58' then 'ESP'
    when payercode='MF60' then 'ESP'
    when payercode='MF62' then 'ESP'
    when payercode='MF64' then 'ESP'
    when payercode='MF66' then 'ESP'

    when payercode='MF24' then 'MAC'
    when payercode='MF27' then 'MAC'
    when payercode='MF29' then 'MAC'
    when payercode='MF31' then 'MAC'
    when payercode='MF33' then 'MAC'
    when payercode='MF35' then 'MAC'
    when payercode='MF37' then 'MAC'
    when payercode='MF39' then 'MAC'
    when payercode='MF41' then 'MAC'
    when payercode='MF43' then 'MAC'
    when payercode='MF45' then 'MAC'
    when payercode='MF47' then 'MAC'
    when payercode='MF49' then 'MAC'
    when payercode='MF51' then 'MAC'
    when payercode='MF53' then 'MAC'
    when payercode='MF55' then 'MAC'
    when payercode='MF57' then 'MAC'
    when payercode='MF59' then 'MAC'
    when payercode='MF61' then 'MAC'
    when payercode='MF63' then 'MAC'
    when payercode='MF65' then 'MAC'
    when payercode='MF67' then 'MAC'
    
    ELSE ''
END                                     TIPODETASADELGIRO,
case
    when idpaymenttype=2 then 
        CASE
            --select * from payer where payercode like 'MF%'
            WHEN PAYERCODE='MF01' THEN '0001'
            WHEN PAYERCODE='MF26' THEN '0001'
            WHEN PAYERCODE='MF27' THEN '0001'
            
            WHEN PAYERCODE='MF02' THEN '0004'
            WHEN PAYERCODE='MF28' THEN '0004'
            WHEN PAYERCODE='MF29' THEN '0004'

            WHEN PAYERCODE='MF03' THEN '0008'
            WHEN PAYERCODE='MF30' THEN '0008'
            WHEN PAYERCODE='MF31' THEN '0008'

            WHEN PAYERCODE='MF04' THEN '0009'
            WHEN PAYERCODE='MF32' THEN '0009'
            WHEN PAYERCODE='MF33' THEN '0009'

            WHEN PAYERCODE='MF05' THEN '0013'
            WHEN PAYERCODE='MF34' THEN '0013'
            WHEN PAYERCODE='MF35' THEN '0013'

            WHEN PAYERCODE='MF06' THEN '0016'
            WHEN PAYERCODE='MF36' THEN '0016'
            WHEN PAYERCODE='MF37' THEN '0016'

            WHEN PAYERCODE='MF07' THEN '0017'
            WHEN PAYERCODE='MF38' THEN '0017'
            WHEN PAYERCODE='MF39' THEN '0017'

            WHEN PAYERCODE='MF08' THEN '0018'
            WHEN PAYERCODE='MF40' THEN '0018'
            WHEN PAYERCODE='MF41' THEN '0018'

            WHEN PAYERCODE='MF09' THEN '0019'
            WHEN PAYERCODE='MF42' THEN '0019'
            WHEN PAYERCODE='MF43' THEN '0019'

            WHEN PAYERCODE='MF10' THEN '0020'
            WHEN PAYERCODE='MF44' THEN '0020'
            WHEN PAYERCODE='MF45' THEN '0020'

            WHEN PAYERCODE='MF11' THEN '0021'
            WHEN PAYERCODE='MF46' THEN '0021'
            WHEN PAYERCODE='MF47' THEN '0021'

            WHEN PAYERCODE='MF12' THEN '0022'
            WHEN PAYERCODE='MF48' THEN '0022'
            WHEN PAYERCODE='MF49' THEN '0022'

            WHEN PAYERCODE='MF13' THEN '0023'
            WHEN PAYERCODE='MF50' THEN '0023'
            WHEN PAYERCODE='MF51' THEN '0023'

            WHEN PAYERCODE='MF14' THEN '0026'
            WHEN PAYERCODE='MF52' THEN '0026'
            WHEN PAYERCODE='MF53' THEN '0026'

            WHEN PAYERCODE='MF15' THEN '0027'
            WHEN PAYERCODE='MF54' THEN '0027'
            WHEN PAYERCODE='MF55' THEN '0027'

            WHEN PAYERCODE='MF16' THEN '0039'
            WHEN PAYERCODE='MF56' THEN '0039'
            WHEN PAYERCODE='MF57' THEN '0039'

            WHEN PAYERCODE='MF17' THEN '0051'
            WHEN PAYERCODE='MF58' THEN '0051'
            WHEN PAYERCODE='MF59' THEN '0051'

            WHEN PAYERCODE='MF18' THEN '0062'
            WHEN PAYERCODE='MF60' THEN '0062'
            WHEN PAYERCODE='MF61' THEN '0062'

            WHEN PAYERCODE='MF19' THEN '0097'
            WHEN PAYERCODE='MF62' THEN '0097'
            WHEN PAYERCODE='MF63' THEN '0097'

            WHEN PAYERCODE='MF20' THEN '0137'
            WHEN PAYERCODE='MF64' THEN '0137'
            WHEN PAYERCODE='MF65' THEN '0137'

            WHEN PAYERCODE='MF21' THEN '0108'
            WHEN PAYERCODE='MF66' THEN '0108'
            WHEN PAYERCODE='MF67' THEN '0108'

            WHEN PAYERCODE='MF22' THEN '0120'
            WHEN PAYERCODE='MF23' THEN '0120'
            WHEN PAYERCODE='MF24' THEN '0120'
            WHEN PAYERCODE='MF25' THEN '0120'            
            else ''
        END
    else ''
end                                     CODIGODELBANCOPARADEPOSITOACUENTA,
ISNULL(DepositAccountNumber,'')         NUMERODECUENTADELBENEFICIARIO,
''                                      TIPODECUENTADELBENFICIARIO,
''                                      PRIMERNOMBREAPODERADOBENEFICIARIO,
''                                      SEGUNDONOMBREAPODERADOBENEFICIARIO,
''                                      PRIMERAPELLIDOAPODERADOBENEFICIARIO,
''                                      SEGUNDOAPELLIDOAPODERADOBENEFICIARIO,
NULL                                    TIPOIDENTIFICACIONAPODERADOBENEFICIARIO,
''                                      NUMEROIDENTIFICACIONAPODERADOBENEFICIARIO,
--OWB
isnull(owb.name,'')                     PRIMERNOMBREAPODERADOREMITENTE,
''                                      SEGUNDONOMBREAPODERADOREMITENTE,
isnull(owb.FirstLastName,'')            PRIMERAPELLIDOAPODERADOREMITENTE,
isnull(owb.SecondLastName,'')           SEGUNDOAPELLIDOAPODERADOREMITENTE,
null                                    TIPOIDENTIFICACIONAPODERADOREMITENTE,
''                                      NUMEROIDENTIFICACIONAPODERADOREMITENTE,
''                                      OBSERVACIONES,
A.DATEOFLASTCHANGE                      FECHAYHORADEMODIFICACION,
A.DATEOFTRANSFER                        FECHAYHORADECAPTURA
From Transfer A                              
join agent AG on a.idagent=ag.idagent
Join Payer D on (A.IdPayer=D.IdPayer)
left Join MacroFinancieraSerial C on (A.IdTransfer=C.IdTransfer)    
LEFT JOIN [OnWhoseBehalf] OWB ON (a.IdOnWhoseBehalf=owb.IdOnWhoseBehalf)
left join branch b on b.idbranch = a.idbranch
left join city ci on b.idcity=ci.idcity
--Left Join CustomerIdentificationType B on (A.CustomerIdCustomerIdentificationType=B.IdCustomerIdentificationType)              
Where IdGateway=15 and IdStatus=21