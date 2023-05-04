CREATE procedure [dbo].[st_GetServiCentro]
(            
    @IdFile INT output            
)
as
Set  @IdFile=0 
--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'
--Set @MinutsToWait=0

---  Update transfer to Attempt -----------------
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=19 and  IdStatus=20
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)

--------- Tranfer log ---------------------------                              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp

-------- Generación de serial para Servicentro ---------------        
Insert into ServiCentroSerial (IdTransfer)
Select IdTransfer from  #temp Where IdTransfer Not in (Select IdTransfer From MacroFinancieraSerial)

----------------  New consecutive number -------------------        
        
If Exists (      
Select   top 1 1            
From Transfer A                          
Where IdGateway=19 and IdStatus=21              
)        
Begin        
 if not exists (select top 1 1 from ServiCentroGeneradorIdFiles where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate()))
 begin
    insert into [ServiCentroGeneradorIdFiles]
    values
    (0,[dbo].[RemoveTimeFromDatetime](getdate()))
 end
    Update ServiCentroGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1 where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate())
 --Select @IdFile=IdFile from MacroFinancieraGeneradorIdFiles        
End   

------------------LogFileTXT---------------------------------------       
      
delete [MAXILOG].[dbo].ServiCentroLogFileTXT where IdTransfer in (Select A.IdTransfer from Transfer A Where IdGateway=19 and IdStatus=21)

Insert into [MAXILOG].[dbo].ServiCentroLogFileTXT             
(            
    IdTransfer,
    IdFileName,
    DateOfFileCreation,
    TypeOfTransfer
)            
Select IdTransfer,@IdFile,GETDATE(),'Transfer' from transfer Where IdGateway=19 and IdStatus=21

-----------------------------------------------------------------------

select
    IdServiCentro ConsecutivoCorresponsal,
    GatewayBranchCode CodigoGrupoPagador,
    ClaimCode ReferenciaAuxiliarCorresponsal,
    AmountInDollars ValordelGiroenDolares,
    CONVERT(VARCHAR(10), DateOfTransfer, 101) Fecha,
    case 
    when len(CustomerName)>30 then substring(CustomerName,1,30)
    else CustomerName
    end
    NombresRemitente,
    case
    when len(CustomerFirstLastName+' '+CustomerSecondLastName )>30 then substring(CustomerFirstLastName+' '+CustomerSecondLastName ,1,30)
    else CustomerFirstLastName+' '+CustomerSecondLastName 
    end    
    ApellidosRemitente,
    case 
    when len(CustomerPhoneNumber)>15 then substring(CustomerPhoneNumber,1,15)
    else CustomerPhoneNumber
    end     
    TelefonoRemitente,
    case 
    when len(BeneficiaryName )>30 then substring(BeneficiaryName ,1,30)
    else BeneficiaryName 
    end
    NombresBeneficiario,
    case 
    when len(BeneficiaryFirstLastName+' '+BeneficiarySecondLastName  )>30 then substring(BeneficiaryFirstLastName+' '+BeneficiarySecondLastName  ,1,30)
    else BeneficiaryFirstLastName+' '+BeneficiarySecondLastName  
    end    
    ApellidosBeneficiario,
    case 
    when len(BeneficiaryPhoneNumber  )>15 then substring(BeneficiaryPhoneNumber  ,1,15)
    else BeneficiaryPhoneNumber  
    end    
    TelefonoBeneficiario,
    case 
    when len(BeneficiaryAddress   )>100 then substring(BeneficiaryAddress   ,1,100)
    else BeneficiaryAddress   
    end        
    DireccionBeneficiario,
    case 
    when len(BeneficiaryCity  )>30 then substring(BeneficiaryCity  ,1,30)
    else BeneficiaryCity  
    end    
    CiudadBeneficiario,
    '' MensajeBeneficiario,
    case (IdPaymentType)
        when 2 then 
            case 
                when len(replace(p.PayerName,' (SERVICENTRO)',''))>30 then substring(replace(p.PayerName,' (SERVICENTRO)','') ,1,30)
                else replace(p.PayerName,' (SERVICENTRO)','')   
            end      
        else ''
    end
    NombreBanco,
    DepositAccountNumber NoCuentaBancaria,
    '' Email,
    case (IdPaymentType)
        when 1 then 'O'
        when 2 then 'B'
        when 3 then 'D'
        when 4 then 'O'
    end
    TipodePago
from 
    transfer t
join payer p on t.idpayer=p.idpayer
join ServiCentroSerial s on t.idtransfer=s.idtransfer
where idgateway=19 and idstatus=21