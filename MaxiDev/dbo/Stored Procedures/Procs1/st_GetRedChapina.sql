
CREATE procedure [dbo].[st_GetRedChapina]
as 

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
/***QA***/
<log Date="01/04/2019" Author="jdarellano" Name="#1">Se agrega IdPayer=6297 en QA para Banco de Antigua.</log>
<log Date="18/04/2019" Author="jdarellano" Name="#2">Se agrega IdPayer=6295 en QA para PAQ.</log>
<log Date="18/04/2019" Author="jdarellano" Name="#3">Se agrega IdPayer=6302 en QA para Bancredit.</log>
<log Date="29/08/2019" Author="jdarellano" Name="#4">Se agrega IdPayer=6316 en QA para Micoope.</log>
<log Date="10/02/2020" Author="jdarellano" Name="#5">Se agrega IdPayer=6329 en QA para Banpais.</log>
<log Date="10/02/2020" Author="jdarellano" Name="#6">Se agrega IdPayer=6330 en QA para Tigo.</log>
<log Date="10/02/2020" Author="jdarellano" Name="#7">Se agrega MEDIO_PAGO='BILL' para PaymentType=5 (MOBILE WALLET).</log>
/***Prod***/
<log Date="18/06/2019" Author="jdarellano" Name="#1">Se agrega IdPayer=5305 para Banco de Antigua.</log>
<log Date="18/06/2019" Author="jdarellano" Name="#2">Se agrega IdPayer=5306 para PAQ.</log>
<log Date="18/06/2019" Author="jdarellano" Name="#3">Se agrega IdPayer=5307 para Bancredit.</log>
<log Date="10/09/2019" Author="jdarellano" Name="#4">Se agrega IdPayer=5313 para Micoope Depósitos.</log>
<log Date="13/03/2020" Author="jdarellano" Name="#5">Se agrega IdPayer=5335 para Banpais.</log>
<log Date="13/03/2020" Author="jdarellano" Name="#6">Se agrega IdPayer=5336 para Tigo.</log>
<log Date="13/03/2020" Author="jdarellano" Name="#7">Se agrega MEDIO_PAGO='BILL' para PaymentType=5 (MOBILE WALLET).</log>

<log Date="11/05/2020" Author="adominguez" Name="#8">Se agrega funcionalidad para agregar tipo de cambio correcto a Honduras.</log>
</ChangeLog>
*********************************************************************/

Set nocount on                                 
                                          
--- Get Minutes to wait to be send to service ---                                          
Declare @MinutsToWait Int                                          
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                   
--Set @MinutsToWait=0                                         
                                          
---  Update transfer to Attempt -----------------                                          
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=18 and  IdStatus=20                                        
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                              
--------- Tranfer log ---------------------------                                      
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                       
Select 21,IdTransfer,GETDATE() from #temp    

select
 t.claimcode ID_OPERACION,
 '' CORRELATIVO_ID,
 'USA' PAIS_ORIGEN,
 t.customername REM_PRIMER_NOMBRE,
 '' REM_SEGUNDO_NOMBRE,
 t.customerfirstlastname REM_PRIMER_APELLIDO,
 t.customersecondlastname REM_SEGUNDO_APELLIDO,
 'USA' REM_PAIS,
 t.customerstate REM_ESTADO,
 t.customercity REM_CIUDAD,
 t.customeraddress REM_DIRECCION,
 t.customerphonenumber REM_TELEFONO,
 t.CustomerCelullarNumber REM_TELEFONO_SMS,
 t.customerzipcode REM_CODIGO_POSTAL,
 t.beneficiaryname BEN_PRIMER_NOMBRE,
 '' BEN_SEGUNDO_NOMBRE,
 t.beneficiaryfirstlastname BEN_PRIMER_APELLIDO,
 t.beneficiarysecondlastname BEN_SEGUNDO_APELLIDO,
 t.beneficiaryaddress BEN_DIRECCION,
 t.beneficiaryphonenumber BEN_TELEFONO,
 t.BeneficiaryCelularNumber BEN_TELEFONO_SMS,
 '' BEN_ENVIO_SMS,
 '' BEN_MENSAJE,
 'USD' MONEDA_ORIGEN,
 C1.CURRENCYcode MONEDA_PAGO,
 case
	   when isnull(UseRefExrate,0) = 0 then T.ExRate
	   else T.referenceexrate
    end as TASA_CAMBIO,
 case
	   when isnull(UseRefExrate,0) = 0 then T.AmountInDollars
	   else dbo.funGetConvertAmount(T.AmountInMN ,T.referenceexrate)
    end as VALOR_ENVIADO,
 case 
    when isnull(UseRefExrate,0) = 0 then T.AmountInMN 
    else round(dbo.funGetConvertAmount(T.AmountInMN ,T.referenceexrate)*T.referenceexrate,4)--#8
end VALOR_PAGAR,
UseRefExrate,
 case t.idpaymenttype
    when 1 then 'Ventanilla'
    when 2 then 'Deposito'
	when 6 then 'ATM'
	when 5 then 'BILL'--#7
    else ''
 end
  MEDIO_PAGO,
 '' TIPO_SERVICIO,
 '' CODIGO_BANCO,
  case t.idpaymenttype    
    when 2 then T.DepositAccountNumber
    else ''
 end ID_SERVICIO,
 '' SECUENCIA_ORIGEN,
 '' LLAVE_SECUENCIA,
 convert(varchar,t.idcustomer) CODIGO_REMITENTE,
 convert(varchar, t.idbeneficiary) CODIGO_BENIFICIARIO,
 '' CARGOS_ADICIONALES,
 CONVERT(VARCHAR(10), t.dateoftransfer, 120) FECHA_VENTA,
 CONVERT(VARCHAR(5), t.dateoftransfer, 108) HORA_VENTA,
 t.idagent LOCAL_VENTA,
 '1' CAJA_VENTA,
 u.username CAJERO_VENTA,
 '' RESERVA1,
 '' RESERVA2,
 '' RESERVA3,
 '' RESERVA4,
 '' RESERVA5,
 countrycode PAIS_PAGO,
 /***QA***/
CASE	WHEN T.IDPAYER=1006 THEN 'EASYPAY' 
        WHEN T.IDPAYER=4014 THEN 'FCV' 
		WHEN T.IdPayer=2554 AND T.IdPaymentType=2 THEN 'BISV'
		WHEN T.IdPayer=5247 THEN 'PRON' 
		WHEN T.IdPayer=5248 THEN 'FUN'
		when T.IdPayer=6297 THEN 'BANT'--#1
		when T.IdPayer=6295 THEN 'PAQ'--#2
		when T.IdPayer=6302 THEN 'BC'--#3
		when T.IdPayer=6316 THEN 'MCOOP'--#4
		when T.IdPayer=5379 THEN 'BANPAIS.BANPAIS'--#5
		--when T.IdPayer=6329 THEN 'BANPAIS'--#5
		when T.IdPayer=5380 THEN 'TMY'--#6
ELSE
/*
/***Prod***/
CASE	WHEN T.IDPAYER=1006 THEN 'EASYPAY' 
        WHEN T.IDPAYER=4014 THEN 'FCV' 
		WHEN T.IdPayer=2554 AND T.IdPaymentType=2 THEN 'BISV'
		WHEN T.IdPayer=5247 THEN 'PRON' 
		WHEN T.IdPayer=5248 THEN 'FUN'
		when T.IdPayer=5318 THEN 'BANT'--#1
		when T.IdPayer=5319 THEN 'PAQ'--#2
		when T.IdPayer=5320 THEN 'BC'--#3
		when T.IdPayer=5313 THEN 'MCOOP'--#4
		when T.IdPayer=5335 THEN 'BANPAIS.BANPAIS'--#5
		when T.IdPayer=5336 THEN 'TMY'--#6
ELSE*/
		payercode END EMPRESA_PAGO
 from 
    transfer T
join countrycurrency cc1 on t.idcountrycurrency=cc1.idcountrycurrency
join currency c1 on cc1.idcurrency=c1.idcurrency
join country c2 on cc1.idcountry=c2.idcountry
join users u on t.enterbyiduser=u.iduser
join payer p on t.idpayer=p.idpayer
left join CountryExrateConfig cex on cc1.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=T.idgateway
 WHERE 
 T.IdGateway=18 and IdStatus=21

 --select
 --'1228778' ID_OPERACION,
 --'' CORRELATIVO_ID,
 --'USA' PAIS_ORIGEN,
 --'Juan' REM_PRIMER_NOMBRE,
 --'Pepito' REM_SEGUNDO_NOMBRE,
 --'Remesa' REM_PRIMER_APELLIDO,
 --'Archila' REM_SEGUNDO_APELLIDO,
 --'USA' REM_PAIS,
 --'NY' REM_ESTADO,
 --'BRONX' REM_CIUDAD,
 --'154-45' REM_DIRECCION,
 --'5487' REM_TELEFONO,
 --'' REM_TELEFONO_SMS,
 --'502' REM_CODIGO_POSTAL,
 --'Maria' BEN_PRIMER_NOMBRE,
 --'Mariel' BEN_SEGUNDO_NOMBRE,
 --'Jata' BEN_PRIMER_APELLIDO,
 --'Mata' BEN_SEGUNDO_APELLIDO,
 --'15' BEN_DIRECCION,
 --'554' BEN_TELEFONO,
 --'' BEN_TELEFONO_SMS,
 --'' BEN_ENVIO_SMS,
 --'detalle' BEN_MENSAJE,
 --'GTQ' MONEDA_ORIGEN,
 --'USD' MONEDA_PAGO,
 --7.8 TASA_CAMBIO,
 --100 VALOR_ENVIADO,
 --800 VALOR_PAGAR,
 --'Deposito' MEDIO_PAGO,
 --'' TIPO_SERVICIO,
 --'' CODIGO_BANCO,
 --'' ID_SERVICIO,
 --'' SECUENCIA_ORIGEN,
 --'' LLAVE_SECUENCIA,
 --'1' CODIGO_REMITENTE,
 --'2' CODIGO_BENIFICIARIO,
 --'' CARGOS_ADICIONALES,
 --'2014-04-01' FECHA_VENTA,
 --'11:55' HORA_VENTA,
 --'' LOCAL_VENTA,
 --'' CAJA_VENTA,
 --'' CAJERO_VENTA,
 --'' RESERVA1,
 --'' RESERVA2,
 --'' RESERVA3,
 --'' RESERVA4,
 --'' RESERVA5,
 --'' PAIS_PAGO,
 --'' EMPRESA_PAGO


 drop table #temp