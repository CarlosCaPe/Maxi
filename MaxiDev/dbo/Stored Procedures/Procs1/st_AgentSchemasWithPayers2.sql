create Procedure [dbo].[st_AgentSchemasWithPayers2]  
(  
    @IdAgent int,
    @IdLenguage int = null   
)   
as
declare @groups table
(
	IDGROUP int identity (1,1),
	name nvarchar(max)
)

DECLARE @GROUPSDETAIL TABLE
(
	IDGROUP INT,
	IDPAYERCONFIG INT
)

insert into @Groups
values
('SIGUE'),
('SUCURSALES INPAMEX'),
('SIGUE'),
('INTERMEX PUEBLA'),
('ORDER EXPRESS'),
('BANORTE'),
('BANCOPPEL'),
('ELEKTRA MEXICO'),
('BANORTE'),
('BANCOPPEL')

INSERT INTO @GROUPSDETAIL
VALUES
(1,783),
(1,785),
(1,784),
(1,786),
(1,774),
(2,717),
(2,718),
(2,771),
(2,716),
(2,719),
(2,720),
(3,773),
(3,782),
(3,777),
(3,778),
(3,779),
(3,781),
(3,776),
(3,780),
(4,491),
(4,496),
(4,495),
(4,492),
(5,724),
(5,725),
(5,727),
(5,726),
(5,712),
(6,517),
(6,601),
(7,728),
(7,737),
(8,760),
(8,761),
(8,759),
(9,518),
(9,602),
(10,738),
(10,742)


if @IdLenguage is null 
    set @IdLenguage=1

--DECLARE @IniDate DATETIME
--SET @IniDate=GETDATE()             
              
Declare @IdPaymentTypeDirectCash int              
set @IdPaymentTypeDirectCash = 4              
              
Declare @IdPaymentTypeCash int              
set @IdPaymentTypeCash =1              
              
--Declare @PaymentTypeCash  varchar(max)              
--set @PaymentTypeCash= (select top 1 PaymentName from PaymentType where IdPaymentType= @IdPaymentTypeCash)              


Select DISTINCT 
B.IdAgentSchema,  
B.SchemaName,  
D.IdCurrency,  
D.CurrencyCode,  
[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,D.CurrencyCode) CurrencyName,  
case              
  when F.IdPaymentType=@IdPaymentTypeDirectCash then @IdPaymentTypeCash              
  else F.IdPaymentType              
 end IdPaymentType,  
[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PAYMENTTYPE'+convert(varchar,F.IdPaymentType))
 PaymentName,  
G.IdPayer,  
G.PayerCode,  
G.PayerName,  
case          
 when E.EndDateTempSpread>GETDATE() then E.TempSpread           
 else 0          
 end SchemaTempSpreadValue,   
F.SpreadValue as PayerSpreadValue,  
E.SpreadValue as SchemaSpreadValue,  
E.IdSpread as SchemaIdSpread,  
ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate,   
F.IdPayerConfig,  
C.IdCountry,
E.IdFee
INTO #refexrate  
--from RelationAgentSchema A with (nolock) 
--Join AgentSchema B with (nolock) on (A.IdAgentSchema=B.IdAgentSchema)  
from AgentSchema B  with (nolock)
Join CountryCurrency C with (nolock) on (C.IdCountryCurrency=B.IdCountryCurrency)   
Join Currency D with (nolock) on (D.IdCurrency=C.IdCurrency)  
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
Join PaymentType H with (nolock) on (H.IdPaymentType=F.IdPaymentType)
LEFT JOIN RefExRate R1 (nolock) ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and F.IdGateway=R1.IdGateway and F.IdPayer=R1.IdPayer  
LEFT JOIN RefExRate R2 (nolock) ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and F.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
LEFT JOIN RefExRate R3 (nolock) ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
where IdAgent=@IdAgent and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1   
--Order by B.SchemaName asc , PaymentName asc, (F.SpreadValue+ E.SpreadValue + ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) ) DESC

delete from #refexrate where CurrencyCode='USD' and RefExRate=1

SELECT 
    IdAgentSchema,SchemaName,IdCurrency,CurrencyCode,CurrencyName,IdPaymentType,PaymentName,IdPayer,PayerCode,
	CASE WHEN G.IDGROUP IS NULL THEN PayerName ELSE G.name END PayerName,
	SchemaTempSpreadValue,PayerSpreadValue,SchemaSpreadValue,SchemaIdSpread,RefExRate,R.IdPayerConfig,IdCountry, IdFee, ROW_NUMBER() OVER (PARTITION BY IDCURRENCY,IDPAYMENTTYPE,PAYERCODE,CASE WHEN G.IDGROUP IS NULL THEN PayerName ELSE G.name END ORDER BY IDCURRENCY,IDPAYMENTTYPE,PAYERCODE,CASE WHEN G.IDGROUP IS NULL THEN PayerName ELSE G.name END) rowid
	into #refexrate2
FROM #refexrate R 
LEFT JOIN @GROUPSDETAIL GD ON GD.IDPAYERCONFIG=R.IdPayerConfig
LEFT JOIN @groups G ON G.IDGROUP=GD.IDGROUP


select IdAgentSchema,SchemaName,IdCurrency,CurrencyCode,CurrencyName,IdPaymentType,PaymentName,IdPayer,PayerCode,PayerName,SchemaTempSpreadValue,PayerSpreadValue,SchemaSpreadValue,SchemaIdSpread,RefExRate,IdPayerConfig,IdCountry,IdFee
from #refexrate2
where rowid=1
Order by 
    SchemaName asc , PaymentName ASC, PayerSpreadValue+SchemaSpreadValue+RefExRate DESC, PayerName asc



DROP TABLE #refexrate
DROP TABLE #refexrate2

-- PARA MAPEO
/*
SELECT
7973 IdAgentSchema,
'DD' SchemaName,
1 IdCurrency,
'DF' CurrencyCode,
'SDF' CurrencyName,
2 IdPaymentType,
'SDF' PaymentName,
57 IdPayer,
'SDF' PayerCode,
'SDF' PayerName,
0.00 SchemaTempSpreadValue,
0.00 PayerSpreadValue,
0.00 SchemaSpreadValue,
1 SchemaIdSpread,
1939.00 RefExRate,
281 IdPayerConfig,
2 IdCountry,
26 IdFee
*/

