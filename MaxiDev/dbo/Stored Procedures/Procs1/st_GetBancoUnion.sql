create procedure [dbo].[st_GetBancoUnion]
(            
    @FileName Varchar(50) output            
)
As
Set  @FileName='' 
--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'--ddg
--Set @MinutsToWait=0

---  Update transfer to Attempt -----------------
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=30 and  IdStatus=20
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)
--------- Tranfer log ---------------------------                              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp



-------- Generación de serial para Banco Union ---------------        

INSERT INTO BancoUnionOrderNum (IdTransfer) SELECT IdTransfer FROM #temp Where IdTransfer NOT IN (SELECT IdTransfer FROM BancoUnionOrderNum)

----------------  New consecutive number -------------------        
        
If Exists (      
Select   top 1 1            
From Transfer A                          
Where IdGateway=30 and IdStatus=21              
)        
Begin        
  DECLARE @OrderName VARCHAR(5)
 SET @OrderName = (SELECT COUNT(IdFile) from [BancoUnionGeneradorFileName] WHERE DateOfFileGenerator = [dbo].[RemoveTimeFromDatetime](getdate()))  + 1
 SET @FileName =  '00030_' + CONVERT(VARCHAR(8), getdate(), 12)  + '_' + RIGHT('000' + @OrderName, 3)
 
    insert into [BancoUnionGeneradorFileName] (FileName, DateOfFileGenerator)
    values
    (@FileName,[dbo].[RemoveTimeFromDatetime](getdate()))
      
End   

------------------LogFileTXT---------------------------------------       
      
delete BancoUnionLogFileTXT where IdTransfer in       
(Select A.IdTransfer from Transfer A            

Where IdGateway=30 and IdStatus=21)

Insert into BancoUnionLogFileTXT             
(            
    IdTransfer,
    FileName,
    DateOfFileCreation,
    TypeOfTransfer
)            
Select IdTransfer,@FileName,GETDATE(),'Transfer' from transfer Where IdGateway=30 and IdStatus=21

-------------------------------------------------------------------------

Select                               

'30' AS CodigoBancoUnion,  -- Código asignado por EL REMESADOR a Banco  Union
(select IdOrder from BancoUnionOrderNum as BUO where BUO.IdTransfer =  a.IdTransfer) AS NumeroOrden, -- Numero secuencial de la Orden  o consecutivo entre  Banco Union y EL REMESADOR
a.ClaimCode  AS ReferenciaOrden,      -- Referencia de la orden o clave       (Origen de la Remesa)
CONVERT(VARCHAR(10), dateoftransfer, 101) AS FechaEnvioRemesaTransaccion, -- Fecha de origen de la transacción (mm/dd/yyyy)
CONVERT(VARCHAR(8), dateoftransfer, 108)  AS HoraEnvioRemesa, -- Hora de origen de la transacción (hh:mm:ss)
amountindollars AS  MontoEnDolares, -- Monto en dólares USA$
exrate AS TipoCambio, -- Tasa de cambio US$-RD$
case c.IdCurrency                                                          
    when 1 then '02'
    else  '01'
	end  FormaDePago, -- Forma de pago 
amountinMN AS MontoEnPesosDominicanos, -- Monto en pesos Dominicanos RD$ 
0 AS CodigoDelRemitente,    --PENDIENTE. -- Código del  Remitente
a.customername AS  NombreRemitente, --Nombres del remitente
a.customerfirstlastname + ' ' +  a.customersecondlastname AS ApellidosRemitente, --Apellidos del remitente
a.CustomerAddress AS DireccionRemitente, -- Dirección del remitente
a.customercity AS CiudadRemitente, -- Ciudad del remitente
a.customerstate AS EstadoRemitente, -- Estado o provincia del remitente
a.customerzipcode AS  CodigoPostalRemitente, -- Código Zip del remitente
'USA' AS PaisRemitente, --País del remitente
a.customerphonenumber AS TelefonoRemitente, -- Teléfono 1 del remitente
'' AS TelefonoRemitenteDos,  --Teléfono 2 del remitente
ISNULL(ci.Name, '') AS  TipoIdentificacionRemitente,--Tipo de la identificación del Remitente
ISNULL(a.CustomerIdentificationNumber, '') AS  NumeroIdentificacionRemitente,-- Numero de identificación del Remitente
a.BeneficiaryNote AS MensajeBeneficiario,-- Mensaje para el Beneficiario
0 CodigoBeneficiario,--Código del Beneficiario
a.BeneficiaryName AS NombreBeneficiario,--Nombres del Beneficiario
a.BeneficiaryFirstLastName + ' ' + a.BeneficiarySecondLastName AS ApellidosBeneficiario,--Apellidos del Beneficiario
a.BeneficiaryAddress AS DireccionBeneficiario,--Dirección del Beneficiario
a.BeneficiaryCity AS CiudadBeneficiario,--Ciudad del Beneficiario
a.BeneficiaryState AS EstadoBeneficiario,-- Estado o provincia del Beneficiario
a.BeneficiaryZipcode AS  ZipBeneficiario, -- Código Zip del Beneficiario
a.BeneficiaryCountry AS PaisBeneficiario,-- Pais del Beneficiario
a.BeneficiaryPhoneNumber AS TelefonoBeneficiario,-- Teléfono 1 del Beneficiario
'' AS TelefonoBeneficiarioDos,-- Teléfono 2 del Beneficiario
case a.idpaymenttype                                                          
    when 1 then '01'
    when 2 then '02'
	when 3 then '01'
end AS TipoTransaccion,-- Tipo de transacción
case a.idpaymenttype  
when 2 then D.PayerName else ' ' end AS NombreDelBanco,-- Nombre del Banco
case a.idpaymenttype  
when 2 then a.DepositAccountNumber else ' ' end AS CuentaBancaria,-- Cuenta bancaria 
0 AS TipoTransaccionBancaria, ---Tipo transacción bancaria
case a.idpaymenttype                                                          
    when 1 then '02'
    when 3 then '01'
	when 2 then '01'
end  AS FormaEntrega, -- Forma de entrega
b.code AS CodigoPuntoPagoBancoUnion -- Código del Punto de Pago de Banco Union. 

From Transfer a
Join Payer D on (a.IdPayer=D.IdPayer)
left join branch b on a.idbranch=b.idbranch
left join countrycurrency cc on cc.idcountrycurrency=a.idcountrycurrency
left join currency c on c.idcurrency=cc.idcurrency 
left join CustomerIdentificationType ci on ci.IdCustomerIdentificationType = a.CustomerIdCustomerIdentificationType
Where IdGateway=30 and IdStatus=21
Order by NumeroOrden