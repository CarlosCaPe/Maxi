CREATE procedure [dbo].[st_GetWellsFargo]
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
Select ch.IdCheck into #temp from Checks as ch  Where DATEDIFF(MINUTE,ch.DateOfMovement,GETDATE())>@MinutsToWait and  IdStatus=41 --standBy
Update Checks Set IdStatus=21,DateStatusChange=GETDATE() Where IdCheck in (Select IdCheck from #temp)
--------- Tranfer log ---------------------------                              
Insert into CheckDetails(IdStatus,IdCheck,DateOfMovement,Note,EnterByIdUser)
Select 21,IdCheck,GETDATE(),'',37 from #temp

----------------  New consecutive number -------------------        
If Exists (      
Select   top 1 1            
From Checks                           
Where IdStatus=21              
)        
Begin        
 if not exists (select top 1 1 from WellsFargoGeneradorIdFiles where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate()))
 begin
    insert into [WellsFargoGeneradorIdFiles]
    values
    (0,[dbo].[RemoveTimeFromDatetime](getdate()))
 end
 Update WellsFargoGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1 where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate())
 --Select @IdFile=IdFile from MacroFinancieraGeneradorIdFiles        
End   


------------------LogFileTXT---------------------------------------       
DELETE [maxilog].[dbo].WellsFargoLogFile where IdTransfer in       
(Select IdCheck from Checks           

Where IdStatus=21)

Insert into [maxilog].[dbo].WellsFargoLogFile             
(            
    IdTransfer,
    IdFileName,
    DateOfFileCreation,
    TypeOfTransfer
)            
Select ch.IdCheck,@IdFile,GETDATE(),'Transfer' from Checks as ch Where ch.IdStatus=21
-----------------------------------------------------------------------

--**********************INFORMACION PARA ARCHIVO X9.37********************************
----------------------Campos de Nodo tipo 01 (File header)---------------------------

--campos comentados se sacaran del lado de la llamada al SP
--StandarsLevel,
--TestFileIndicator
select 
--right('0000000000'+convert(varchar(10),'01'),10) as RecordType,
'01' as RecordType,
'03' as StandardLevel,
'T' as TestFileIndicator,
'121000248' as InmediateDestinationRoutingNumber,
right('000000000'+convert(varchar(9),1234567),9) as InmediateOriginRoutingNumber,--1,
GETDATE() as FileCreationDate,  --YYYYMMDD 2,
GETDATE() as FileCreationTime, --hhmm 2,
'N' as ResendIndicator, -- Archivo que ya se habia tratado de enviar antes? 4
'Wells Fargo Bank  ' as InmediateDestinationName,--??
left('company name'+space(18),18) as InmediateOriginName,--??
'1' as FileIdModifier,--se usa para identificar archivos. usese si campos 1-4 son iguales en otro archivo dentro de la misma fecha
'US' as CountryCode, --blank field,
'    ' as UserField,--blank
' ' as Reserved--blank
--------------------------------------------------------------------------------------

---------------------Campos de nodo 10 (Cash Letter)----------------------------------
Select
'10' as RecordType,
'01' as CollectionTypeIndicator, --valor 12 o 90. Indica si es un deposito.....este renglon debe ser identico con DestinationROutingNumber de row tipo 20 (Bundle)
'121000248' as DestinationRoutingNumber, --valid routing number
right('000000000'+convert(varchar(9),1234567),9) as ECERoutingNumber,--ABCASHLEA's routing number
GETDATE() as CashLetterBusinessDate,--YYYYMMDD
GETDATE() as CashletterCreationDate,--YYYYMMDD
GETDATE() as CashLetterCreationTime, --hhmm
'I' as CashletterRecordType,-- ver valores en archivo de ejemplo I,N,E,F,C,G,K,L,Z
'G' as CashLetterDocumentationType,
'20510001' as CashletterID,--valor unico dentro de una fecha especifica
left('123456789'+space(14),14) as OriginatorContactName,--nombre de compañia asignado a la cuenta del beneficiario
right('0000000000'+convert(varchar(10),123456),10) as OriginatorContactPhoneNumber,--# telefonico del contactoen la compañia que crea la carta de efectivo
'C' as FedWorkType,--blank
'  ' as UserField,--blank
' ' as Reserved--blank

------------------------Campos de nodo 61 (Credit Record)-----------------------------SOLO APARECE UNA VEZ EN TODO EL ARCHIVO POR ESO ESTA EN DESORDEN
--colocar variable y hacer select solo cuando variable es igual a 0
select
'61' as RecordType,
right('000000000000'+convert(varchar(12),12345),12) as AmountOfCredit,
right(space(17)+convert(varchar(17),123456789),17) as CreditAccountNumber,
'  6586' as ProcessControl,
'584507414' as RoutingNumber,
left('MICR number'+space(15),15) as SerialNumber,
left('pedir a wells '+space(15),15) as ItemSequenceNumber,
' ' as ExternalProcessingCode,
' ' as TypeOfAccountCode,
'3' as SourceOfWorkCode,
' ' as Reserved--blank field

------------------------Campos  de nodo 20 (Bundle Header)-----------------------------(generar una y otra vez desde C#)
--select
--'' as RecordType,
--'col indicator' as CollectionType,--between 12 and 90. Same value as CashLetter Node
--'Destination routing #' as DestinationRoutingNumber,--must be same value as CashLetter Node
--'Ece inst number' as EceInstitutionRefNumber,--same value of Cashletter node
--getdate() as BundleBusinessDate,
--getdate() as BundleCreationDate,
--'Bundle id' as BundleId,--valor unico con una fecha valida de cash letter
--'Bundle sequence number' as BundleSequenceNumber,--combinacion entre bundle id y bundle secuence number y debe ser unico
--'Cycle Number' as CycleNumber,--numero asignado por el creador. Puede denotarse el dia de la semana o otra referencia internacional
--'ReturnLocationRoutingNumber' as ReturnLocationRoutingNumber,---este campo no debe ser usado
--'User Field' as UserField,--blank
--'Reserved' as Reserved--blank


--coleccion de checkdetails????
-----------------------Campos de CheckDetail(nodo 25)--------------------------------(GENERAR DESDE c# DINAMICAMENTE)
--cada nodo tipo 25 (Bundle) puede contener 299 nodos de tipo 25
select
'25' as RecordType,
right(space(15)+convert(varchar(15),'preguntar'),15) as AuxiliaryOnUs,--obligatorio si es que se tienen On-Us symbols en MICR no deben incluirse./ deben retenerse
' ' as ExternalProcessingCode,--cheques originales no lo tienen. cheques substitutos generalmente tienen un 4
right(space(8)+convert(varchar(8),12345),8) as PayorBankRoutingNumber,--primeros 8 digitos de routng number
'Ninth digit of MICR' as PayorBankRoutingNumberCheckDigit,-- ???
right(space(20)+convert(varchar(20),1234567890),20) as OnUs,--obligatorio si es que se tiene en MICR.. entre posiciones 14 y 32
right('0000000000'+convert(varchar(10),123456789),10) as ItemAmount,--valor total de todos los bundles?,
left('pedir a wells '+space(15),15) as ItemSequenceNumber,
'G' as DocumentationType,
' ' as ReturnAcceptanceIndicator,
' ' as MICRValidIndicator,--preguntar si MAXI es cliente Smart Decision
'U' as BOFDIndicator,
'00' as CheckDetailRecordAddendumCount,
' ' as CorrectionIndicator,
'B' as ArchiveTypeIndicator


--coleccion de cheques??
-----------------------Campos de imágen de cheque(nodos 50 y 52)----------------------(GENERAR DESDE c# DINAMICAMENTE)
--front image**********************************
,
'50' as RecordTypeImageFront,
'1' as ImageIndicatorFront, --0: Image view not present.
										--1: imágen es un cheque o sustituto de cheque
right('000000000'+convert(varchar(9),123456),9) as ImageCreatorRoutingNumberFront,--ABA's valid transit number
GETDATE() as ImageCreatorDateFront,--YYYYMMDD
'00' as ImageViewFormatIndicatorFront,--Imagenes principales edben tener valor 00. Solo debe estar presente
														--cuando  ImageIndicator sea diferente de 0		
'00' as ImageCompressionAlgorithmFront,--  misma regla que campo anterior
'ImageViewDataSize' as ImageViewDataSizeFront,--Field Is Ignored
'0' as ViewSideFront,--valid values: 0: Front Image View
										--1: Rear Image View
'00' as ViewDescriptorFront,
'0' as DigitalSignatureIndicatorFront,--Must be 0, indicating digital signature is not present
'  ' as DigitalSignatureMethodFront,--blank
'     ' as SecurityKeySizeFront,--blank
'       ' as StartOfProtectedDataFront,--blank
'       ' as LengthOfProtectedDataFront,--blank
' ' as ImageRecreateIndicatorFront,--blank
'        ' as UserFieldStartFront,--BLANK
'               ' as ReservedImageFront--blank
,---------------------------------------------CHECK DATA
'52' as RecordTypeImageDataFront,
right('000000000'+convert(varchar(9),12345),9) as ECEInstitutionNumberFront,--mismo valor que en nodo 20
getdate() as BundleBusinessDateFront,
'01' as CycleNumberFront,--assigned by the creator. day of the week or other international reference number
'               ' as ItemSequenceNumberFront,--marches ISN
'                ' as SecurityOriginationNameFront,--blank
'                ' as SecurityAuthenticatorNameFront,--blank
'                ' as SecurityKeyNameFront,--blank
'0' as ClippingOriginFront,--0 indicates full view. Front and rear views only shoud have 0.
'    ' as ClippingCoordinateh1Front,--blank
'    ' as ClippingCoordinateh2Front,--blank
'    ' as v1Front,--blank
'    ' as v2Front,--blank
'    ' as LengthOfImageReferenceKeyFront,--0 indicates field is not present
'' as ImageReferenceKeyFront,
'00000' as LengthOfDigitalSignatureFront,--must be 0. Indicating digital signature is not present
'' as DigitalSignatureFront,
'' as LengthofImageDataFront,-- total number of bytes in the image data in this image view
'' as ImageDataFront,
--front image**********************************


--BACK IMAGE***********************************
'50' as RecordTypeImageBack,
'1' as ImageIndicatorBack, --0: Image view not present.
										--1: imágen es un cheque o sustituto de cheque
right('000000000'+convert(varchar(9),123456),9) as ImageCreatorRoutingNumberBack,--ABA's valid transit number
GETDATE() as ImageCreatorDateBack,--YYYYMMDD
'00' as ImageViewFormatIndicatorBack,--Imagenes principales edben tener valor 00. Solo debe estar presente
														--cuando  ImageIndicator sea diferente de 0		
'00' as ImageCompressionAlgorithmBack,--  misma regla que campo anterior
'ImageViewDataSize' as ImageViewDataSizeBack,--Field Is Ignored
'1' as ViewSideBack,--valid values: 0: Front Image View
										--1: Rear Image View
'00' as ViewDescriptorBack,
'0' as DigitalSignatureIndicatorBack,--Must be 0, indicating digital signature is not present
'  ' as DigitalSignatureMethodBack,--blank
'     ' as SecurityKeySizeBack,--blank
'       ' as StartOfProtectedDataBack,--blank
'       ' as LengthOfProtectedDataBack,--blank
' ' as ImageRecreateIndicatorBack,--blank
'        ' as UserFieldStartBack,--BLANK
'               ' as ReservedImageBack--blank
,---------------------------------------------CHECK DATA
'52' as RecordTypeImageDataBack,
right('000000000'+convert(varchar(9),12345),9) as ECEInstitutionNumberBack,--mismo valor que en nodo 20
getdate() as BundleBusinessDateBack,
'01' as CycleNumberBack,--assigned by the creator. day of the week or other international reference number
'               ' as ItemSequenceNumberBack,--marches ISN
'                ' as SecurityOriginationNameBack,--blank
'                ' as SecurityAuthenticatorNameBack,--blank
'                ' as SecurityKeyNameBack,--blank
'0' as ClippingOriginBack,--0 indicates full view. Front and rear views only shoud have 0.
'    ' as ClippingCoordinateh1Back,--blank
'    ' as ClippingCoordinateh2Back,--blank
'    ' as v1Back,--blank
'    ' as v2Back,--blank
'    ' as LengthOfImageReferenceKeyBack,--0 indicates field is not present
'' as ImageReferenceKeyBack,
'00000' as LengthOfDigitalSignatureBack,--must be 0. Indicating digital signature is not present
'' as DigitalSignatureBack,
'' as LengthofImageDataBack,-- total number of bytes in the image data in this image view
'' as ImageDataBack