CREATE procedure [dbo].[st_GetMacroFinancieraCancels]          
(        
    @IdFile Int Output    
)
as  
Set @IdFile=0 

If Exists (
Select top 1 1 from transfer a
Where IdGateway=15 and IdStatus=25  
)    
Begin    
 Update MacroFinancieraGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1    
--    Select  from PagosIntGeneradorIdFiles    
End    
  
Delete [MAXILOG].[dbo].MacroFinancieraLogFileTXT where IdTransfer in (Select IdTransfer from Transfer Where IdGateway=15 and IdStatus=25  )       
Insert into [MAXILOG].[dbo].MacroFinancieraLogFileTXT         
(        
IdTransfer,        
IdFileName,        
DateOfFileCreation,        
TypeOfTransfer         
)        
Select IdTransfer,@IdFile,GETDATE(),'Cancel' from Transfer Where IdGateway=15 and IdStatus=25   


        
Set Nocount on         
Select                               
C.IdMacroFinanciera                             SECUENCIADELGIRO,
claimcode                                       NUMERODEORDEN,
CustomerName                                    PRIMERNOMBREREMITENTE,
''                                              SEGUNDONOMBREREMITENTE,
CustomerFirstLastName                           PRIMERAPELLIDOREMITENTE,
CustomerSecondLastName                          SEGUNDOAPELLIDOREMITENTE,
CustomerAddress                                 DIRECCIONREMITENTE,
'US'                                            PAISREMITENTE,
upper(ag.agentcity)                             CIUDADREMITENTE,
ag.agentcode                                    CODIGOONOMBREOFICINAENVIAGIRO,
BeneficiaryName                                 PRIMERNOMBREBENEFICIARIO,
''                                              SEGUNDONOMBREBENEFICIARIO,
BeneficiaryFirstLastName                        PRIMERAPELLIDOBENEFICIARIO,
BeneficiarySecondLastName                       SEGUNDOAPELLIDOBENEFICIARIO,
null                                            TIPOIDENTIFICACIONBENEFICIARIO,
''                                              NUMEROIDENTIFICACIONBENEFICIARIO,
BeneficiaryAddress                              DIRECCIONDELBENEFICIARIO,
'0' /*BeneficiaryPhoneNumber*/                  TELEFONO1BENEFICIARIO,
replace(ltrim(rtrim(isnull(BeneficiaryCelularNumber,''))),'-','') TELEFONO2BENEFICIARIOCELULAR,
case 
    when gatewaybranchcode='0043' then 'VIRTUAL'
    else
        isnull(ci.cityname,'VIRTUAL')
    end                                 CIUDADDESTINODELGIRO,
gatewaybranchcode                              OFICINADEPAGO,
case (a.IDpaymenttype)
when 1 then '01'
when 2 then '02'
end
                                                FORMADEPAGO,
0 /*AmountInDollars*/                           VALORENDOLARES,
0 /*ExRate*/                                    TASADECAMBIO,
0 /*AmountInMN*/                                VALORENPESOS,
'ANULAR'                                        MENSAJEDELGIRO,
case
    when payercode='MF22' then 'NOR'
    when payercode='MF23' then 'ESP'
    when payercode='MF24' then 'MAC'
    ELSE ''
END                                     TIPODETASADELGIRO,
case
    when idpaymenttype=2 then 
        CASE
            --select * from payer where payercode like 'MF%'
            WHEN PAYERCODE='MF01' THEN '0001'
            WHEN PAYERCODE='MF02' THEN '0004'
            WHEN PAYERCODE='MF03' THEN '0008'
            WHEN PAYERCODE='MF04' THEN '0009'
            WHEN PAYERCODE='MF05' THEN '0013'
            WHEN PAYERCODE='MF06' THEN '0016'
            WHEN PAYERCODE='MF07' THEN '0017'
            WHEN PAYERCODE='MF08' THEN '0018'
            WHEN PAYERCODE='MF09' THEN '0019'
            WHEN PAYERCODE='MF10' THEN '0020'
            WHEN PAYERCODE='MF11' THEN '0021'
            WHEN PAYERCODE='MF12' THEN '0022'
            WHEN PAYERCODE='MF13' THEN '0023'
            WHEN PAYERCODE='MF14' THEN '0026'
            WHEN PAYERCODE='MF15' THEN '0027'
            WHEN PAYERCODE='MF16' THEN '0039'
            WHEN PAYERCODE='MF17' THEN '0051'
            WHEN PAYERCODE='MF18' THEN '0062'
            WHEN PAYERCODE='MF19' THEN '0097'
            WHEN PAYERCODE='MF20' THEN '0137'
            WHEN PAYERCODE='MF21' THEN '0108'
            WHEN PAYERCODE='MF22' THEN '0120'
            WHEN PAYERCODE='MF23' THEN '0120'
            WHEN PAYERCODE='MF24' THEN '0120'
            WHEN PAYERCODE='MF25' THEN '0120'            
            else ''
        END
    else ''
end                                     CODIGODELBANCOPARADEPOSITOACUENTA,
ISNULL(DepositAccountNumber,'')                 NUMERODECUENTADELBENEFICIARIO,
''                                              TIPODECUENTADELBENFICIARIO,
''                                              PRIMERNOMBREAPODERADOBENEFICIARIO,
''                                              SEGUNDONOMBREAPODERADOBENEFICIARIO,
''                                              PRIMERAPELLIDOAPODERADOBENEFICIARIO,
''                                              SEGUNDOAPELLIDOAPODERADOBENEFICIARIO,
NULL                                            TIPOIDENTIFICACIONAPODERADOBENEFICIARIO,
''                                              NUMEROIDENTIFICACIONAPODERADOBENEFICIARIO,
--OWB
isnull(owb.name,'')                             PRIMERNOMBREAPODERADOREMITENTE,
''                                              SEGUNDONOMBREAPODERADOREMITENTE,
isnull(owb.FirstLastName,'')                    PRIMERAPELLIDOAPODERADOREMITENTE,
isnull(owb.SecondLastName,'')                   SEGUNDOAPELLIDOAPODERADOREMITENTE,
null                                            TIPOIDENTIFICACIONAPODERADOREMITENTE,
''                                              NUMEROIDENTIFICACIONAPODERADOREMITENTE,
'CANCELACION'                                   OBSERVACIONES,
A.DATEOFLASTCHANGE                              FECHAYHORADEMODIFICACION,
A.DATEOFTRANSFER                                FECHAYHORADECAPTURA
From Transfer A                              
join agent AG on a.idagent=ag.idagent
Join Payer D on (A.IdPayer=D.IdPayer)          
left Join MacroFinancieraSerial C on (A.IdTransfer=C.IdTransfer)    
LEFT JOIN [OnWhoseBehalf] OWB ON (a.IdOnWhoseBehalf=owb.IdOnWhoseBehalf)
left join branch b on b.idbranch = a.idbranch
left join city ci on b.idcity=ci.idcity
Where IdGateway=15 and IdStatus=25  