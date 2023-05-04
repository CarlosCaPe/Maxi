CREATE procedure [dbo].[st_GetBTS]
as
/********************************************************************
<Author></Author>
<app>PaymentServices : PaymentServices.Bts</app>
<Description>Get BTS operations in state</Description>

<ChangeLog>
<log Date="26/03/2018" Author="Snevarez"> MA_008: Se añade el campos para el tipo de pago ATM(6) </log>
<log Date="23/07/2019" Author="jdarellano" Name="#1">Se agrega IdPayer 5309 (DAVIVIENDA HONDURAS) con código NOT.</log>
<log Date="23/07/2019" Author="jdarellano" Name="#2">Se agrega IdPayer 584 (BANRESERVAS) con código NOT.</log>
<log Date="23/07/2019" Author="jdarellano" Name="#3">Se agrega IdPayer 605 (BANCO ATLANTIDA) con código NOT.</log>
<log Date="03/03/2020" Author="jdarellano" Name="#4">Se agrega IdPayer 491 (Elektra Guatemala) con código NOT.</log>
<log Date="09/04/2020" Author="jdarellano" Name="#5">Se agrega IdPayer 492 (Elektra Honduras) con código NOT.</log>
<log Date="23/04/2020" Author="jdarellano" Name="#6">Se agrega IdPayer 5311 (LAFISE) con código NOT.</log>
<log Date="15/06/2022" Author="adominguez" Name="#7">Se agrega validacion de tipo de cuenta seleccionada en el Agente cheques o ahorros</log>
<log Date="01/08/2022" Author="jdarellano" Name="#8">Se modifican campos IDENTIF_TYPE_CD_Recipient y IDENTIF_NM_Recipient ya que indica gateway que deben enviarse vacíos.</log>
<log Date="03/08/2022" Author="jdarellano" Name="#9">Se modifican campos IDENTIF_TYPE_CD_Recipient y IDENTIF_NM_Recipient para excluír información de Banco Guayaquil y Banco Del Austro.</log>
<log Date="10/08/2022" Author="adominguez" Name="#10">Se agrega 'NOT' para el pagador Banpro tipo Deposito</log>
<log Date="15/03/2023" Author="adominguez" Name="#11">Se agrega 'NOT' para el pagador FEDECREDITO,FEDECACES,CREDOMATIC</log>

</ChangeLog>

*********************************************************************/
--Set nocount on

Begin try

--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int;
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes with(nolock) where Name='TimeFromReadyToAttemp';
--Set @MinutsToWait=0

--- Update transfer to Attempt -----------------
Select top 1000 IdTransfer into #temp from dbo.[Transfer] WITH (NOLOCK) Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=4 and IdStatus=20;
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp);
--------- Tranfer log ---------------------------
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp


Select top 1000
    A.Claimcode as CONFIRMATION_NM,
    'O' as ORDER_STATUS,
    'MTR' as SERVICE_CD,

    Case A.IdPaymentType When 1 Then 'CSH'
	   When 2 Then 'ACC'
	   When 3 Then 'HMD'
	   When 4 Then 'CSA'
	   When 6 Then 'ATM'
    Else '' End as PAYMENT_TYPE_CD,

    'USA' as ORIG_COUNTRY_CD,
    'USD' as ORIG_CURRENCY_CD,
    C.CountryCode as DEST_COUNTRY_CD,

    case 
	   when D.CurrencyCode='MXN' then 'MXP' 
	   else D.CurrencyCode 
    end as DEST_CURRENCY_CD,

    case when A.IdPaymentType=2 and A.IdPayer=1 Then 'ACN'
	   when A.IdPaymentType=2 and A.IdPayer=62 Then 'RCH'
	   when A.IdPaymentType=2 and A.IdPayer=71 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=470 Then 'SAC'
	   when A.IdPaymentType=2 and A.IdPayer=18 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=55 Then 'RCH'
	   when A.IdPaymentType=2 and A.IdPayer=14 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=20 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=23 Then 'RCH'
	   when A.IdPaymentType=2 and A.IdPayer=24 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=25 Then 'RCH'
	   when A.IdPaymentType=2 and A.IdPayer=26 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=53 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=54 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=57 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=59 Then 'NOT'--#10												  
	   when A.IdPaymentType=2 and A.IdPayer=68 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=70 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=472 Then 'RCH'
	   when A.IdPaymentType=2 and A.IdPayer=433 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=574 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=582 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=584 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=588 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=598 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=599 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=605 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=611 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=613 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=615 Then 'NOT'
	   when A.IdPaymentType=2 and A.IdPayer=491 Then 'NOT'--#4
	   when A.IdPaymentType=2 and A.IdPayer=492 Then 'NOT'--#5
	   when A.IdPaymentType=2 and A.IdPayer=5311 Then 'NOT'--#6

	   when A.IdPaymentType = 2 and A.IdPayer=490 AND LEN(A.DepositAccountNumber) = 11 then 'ACN'
	   when A.IdPaymentType = 2 and A.IdPayer=490 AND LEN(A.DepositAccountNumber) = 16 then 'CDN'
	   when A.IdPaymentType = 2 and A.IdPayer=4017 AND LEN(A.DepositAccountNumber) = 11 then 'ACN'
	   when A.IdPaymentType = 2 and A.IdPayer=4017 AND LEN(A.DepositAccountNumber) = 16 then 'CDN'

	   when A.IdPaymentType=2 and G.PAYERCODE='BPI' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='NYB' then 'NOT'

	   --brasil
	   when A.IdPaymentType=2 and G.PAYERCODE='409' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='611' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='001' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='002' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='003' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='004' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='008' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='021' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='024' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='025' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='027' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='029' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='033' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='035' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='036' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='037' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='039' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='040' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='041' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='044' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='045' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='047' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='062' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='063' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='065' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='066' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='069' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='070' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='072' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='073' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='074' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='075' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='096' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='104' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='107' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='116' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='151' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='175' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='184' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='204' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='208' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='210' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='212' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='213' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='214' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='215' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='217' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='218' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='222' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='224' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='225' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='229' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='230' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='233' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='237' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='241' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='243' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='244' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='246' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='247' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='248' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='249' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='250' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='252' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='254' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='263' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='265' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='266' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='291' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='300' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='318' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='320' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='341' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='347' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='351' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='353' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='356' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='366' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='370' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='376' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='389' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='394' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='399' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='412' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='422' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='453' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='456' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='464' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='477' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='479' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='487' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='488' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='492' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='494' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='495' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='505' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='600' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='604' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='607' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='610' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='612' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='613' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='623' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='626' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='630' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='633' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='634' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='637' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='638' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='643' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='652' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='653' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='654' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='655' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='707' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='719' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='721' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='734' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='735' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='738' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='739' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='740' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='741' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='743' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='744' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='745' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='746' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='747' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='748' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='749' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='751' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='752' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='753' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='756' then 'RCH'
	   when A.IdPaymentType=2 and G.PAYERCODE='757' then 'RCH'

	   When A.IdPaymentType=2 and G.Payercode='EK6' then 'NOT'

	   WHEN A.IdPaymentType=2 AND A.IdPayer=2629 THEN 'NOT'

	   when A.IdPaymentType=2 and A.IdPayer=5309 then 'NOT'--#1
	   when A.IdPaymentType=2 and A.IdPayer=584 then 'NOT'--#2
	   when A.IdPaymentType=2 and A.IdPayer=605 then 'NOT'--#3

	   when A.IdPaymentType=2 and A.IdPayer=471 Then 'NOT'--#11
	   when A.IdPaymentType=2 and A.IdPayer=590 Then 'NOT'--#11
	   when A.IdPaymentType=2 and A.IdPayer=64 Then 'NOT'--#11										   
														   
	   WHEN A.IdPaymentType=2 AND G.Payercode='FUN' AND LEN(ISNULL(A.DepositAccountNumber,''))=16 THEN 'CDN'
	   WHEN A.IdPaymentType=2 AND G.Payercode='FUN' AND LEN(ISNULL(A.DepositAccountNumber,''))=18 THEN 'CBE'
	  
	   WHEN A.IdPaymentType=2 AND AccountTypeId = 1 THEN 'RCH'--#7
	   WHEN A.IdPaymentType=2 AND AccountTypeId = 2 THEN 'SAC'--#7

    Else '' End as R_ACCOUNT_TYPE_CD,

    case when A.IdPaymentType=2 then A.DepositAccountNumber else '' end as R_ACCOUNT_NM,
    --Case When A.IdPaymentType<>1 Then G.PayerCode Else '' End as R_AGENT_CD, ---- Solo cuando es directed cash y deposit se pone el nombre del banco

    Case When A.IdPaymentType<>1 Then
    case G.PayerCode
	   when 'FUN' then
		  case when a.IdPaymentType=2 then 'FDO' else G.PayerCode end
			 when 'WMT1' then 'WMT'
			 when 'WMT2' then 'WMT'
			 when 'WMT3' then 'WMT'
			 when 'WMT4' then 'WMT'
		  when 'WMT5' then 'WMT'
		  else G.PayerCode end
	   Else '' 
    End as R_AGENT_CD, ---- Solo cuando es directed cash y deposit se pone el nombre del banco

    Convert(varchar(15),'') as R_AGENT_REGION_SD,
    Convert(varchar(15),'') as R_AGENT_BRANCH_SD,

    --Cambios para respetar el tipo de cambio oficial de honduras
    case
	   when isnull(UseRefExrate,0) = 0 then A.AmountInDollars
	   else dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)
    end as ORIGIN_AM,

    case
	   when isnull(UseRefExrate,0) = 0 then A.AmountInMN
	   else round(dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)*A.referenceexrate,4)
    end as DESTINATION_AM,

    case
	   when isnull(UseRefExrate,0) = 0 then A.ExRate
	   else A.referenceexrate
    end as EXCH_RATE_FX,
    --------------------------------------------------------

    Convert(varchar(21),'') as WHOLESALE_FX,
    --Convert(varchar(20),'') as FEE_AM,
    Convert(varchar(20),a.Fee) as FEE_AM,
    Convert(varchar(20),'') as DISCOUNT_AM,
    Convert(varchar(3),'') as DISCOUNT_REASON_CD,
    Convert(varchar(3),'') as S_SMS_MSG_REQ,
    'CASH' as S_PAYMENT_TYPE_CD,
    Convert(varchar(3),'') as S_ACCOUNT_TYPE_CD,
    Convert(varchar(3),'') as S_ACCOUNT_NM,
    Convert(varchar(3),'') as S_BANK_CD,
    Convert(varchar(20),'') as S_BANK_REF_NM,

    /*MA_008:ATM(6) - BEGIN*/
    --Convert(varchar(3),'') as R_SMS_MSG_REQ,

    --SMS:Short Message Service to Cellular Phone
    --MSG:Message toa na email address
    --SMG: SMS & MSG
    --NOT=None
    case
	   when A.IdPaymentType = 6 then Convert(varchar(3),ISNULL('SMS',''))
	   else Convert(varchar(3),'') 
    end as R_SMS_MSG_REQ,
    /*MA_008:ATM(6) - END*/

    Convert(varchar(3),'') as O_SMS_MSG_REQ,
    A.Folio as ORDER_NM_Agent,
    convert(varchar(15),E.Agentcity) as REGION_SD_Agent,
    Convert(varchar(15),E.IdAgent) as BRANCH_SD_Agent,
    E.AgentState as STATE_CD_Agent,
    'USA' as COUNTRY_CD_Agent,
    convert(varchar(8),F.UserName) as USER_NAME,
    Convert(varchar(20),'') as SUP_USER_NAME_Agent,
    '1' as TERMINAL_Agent,
    Replace (convert(char(10),a.dateoftransfer,20),'-','') as AGENT_DT_Agent,
    REPLACE ( convert(char(8),A.dateoftransfer,108),':','') as AGENT_TM_Agent,
    Convert(varchar(10),'') as CUSTOMER_ID_Sender,
    A.CustomerName as FIRST_NAME_Sender,
    Convert(varchar(40),'') as MIDDLE_NAME_Sender,
    ltrim(rtrim(A.CustomerFirstLastName)) as LAST_NAME_Sender,
    ltrim(rtrim(A.CustomerSecondLastName)) as MOTHER_M_NAME_Sender,
    A.CustomerAddress as ADDRESS_Sender,
    A.CustomerCity as CITY_Sender,
    A.CustomerState as STATE_CD_Sender,
    'USA' as COUNTRY_CD_Sender,
    A.CustomerZipCode as ZIP_CODE_Sender,
    Convert(varchar(15),'') as PHONE_Sender,
        
    /*MA_008:ATM(6) - BEGIN*/
    --Convert(varchar(15),'') as CELL_PHONE_Sender,
    case
	   when A.IdPaymentType = 6 then Convert(varchar(15),[dbo].[fnDeleteFormatPhoneNumber](ISNULL(A.CustomerCelullarNumber,'')))
	   else Convert(varchar(15),'') 
    end as CELL_PHONE_Sender,
    /*MA_008:ATM(6) - END*/


    Convert(varchar(100),'') as EMAIL_Sender,
    Convert(varchar(40),'') as FIRST_NAME_behalf_of,
    Convert(varchar(40),'') as MIDDLE_NAME_behalf_of,
    Convert(varchar(40),'') as LAST_NAME_behalf_of,
    Convert(varchar(40),'') as MOTHER_M_NAME_behalf_of,
    Convert(varchar(80),'') as ADDRESS_behalf_of,
    Convert(varchar(40),'') as CITY_behalf_of,
    Convert(varchar(3),'') as STATE_CD_behalf_of,
    Convert(varchar(3),'') as COUNTRY_CD_behalf_of,
    Convert(varchar(10),'') as ZIP_CODE_behalf_of,
    Convert(varchar(15),'') as PHONE_behalf_of,
    Convert(varchar(15),'') as CELL_PHONE_behalf_of,
    Convert(varchar(100),'') as EMAIL_behalf_of,
    A.BeneficiaryName as FIRST_NAME_Recipient,
    Convert(varchar(40),'') as MIDDLE_NAME_Recipient,
    ltrim(rtrim(A.BeneficiaryFirstLastName)) as LAST_NAME_Recipient,
    ltrim(rtrim(A.BeneficiarySecondLastname)) as MOTHER_M_NAME_Recipient,
    
    /*MA_008:ATM(6) - BEGIN*/
    --Convert(varchar(3),isnull(benid.BTSIdentificationType,'')) as IDENTIF_TYPE_CD_Recipient,
    CASE--#8
		WHEN A.IdPaymentType = 6 THEN CONVERT(varchar(3),'') 
		WHEN A.IdPayer = 25 THEN CONVERT(varchar(3),'') --#9
		WHEN A.IdPayer = 24 THEN CONVERT(varchar(3),'') --#9
		ELSE CONVERT(varchar(3),ISNULL(benid.BTSIdentificationType,''))
    END AS IDENTIF_TYPE_CD_Recipient,
	--'' AS IDENTIF_TYPE_CD_Recipient,--#9
    /*MA_008:ATM(6) - END*/
    
    /*MA_008:ATM(6) - BEGIN*/
    --Convert(varchar(20),isnull(BeneficiaryIdentificationNumber,'')) as IDENTIF_NM_Recipient,
    CASE--#8
		WHEN A.IdPaymentType = 6 THEN CONVERT(varchar(20),'')
		WHEN A.IdPayer = 25 THEN CONVERT(varchar(3),'') --#9
		WHEN A.IdPayer = 24 THEN CONVERT(varchar(3),'') --#9
		ELSE CONVERT(varchar(20),ISNULL(BeneficiaryIdentificationNumber,''))
    END AS IDENTIF_NM_Recipient,--#8
	--'' AS IDENTIF_NM_Recipient,--#9
    /*MA_008:ATM(6) - End*/

    Convert(varchar(40),'') as FIRST_NAME_Foreing,
    Convert(varchar(40),'') as MIDDLE_NAME_Foreing,
    Convert(varchar(40),'') as LAST_NAME_Foreing,
    Convert(varchar(40),'') as MOTHER_M_NAME_Foreing,
    A.BeneficiaryAddress as ADDRESS_Recipient,
    A.BeneficiaryCity as CITY_Recipient,
    Isnull(J.StateCodeBTS,'') as STATE_CD_Recipient,
    C.CountryCode as COUNTRY_CD_Recipient,
    Convert(varchar(10),ISNULL(A.BeneficiaryZipcode,'')) as ZIP_CODE_Recipient,

    Convert(varchar(15),ISNULL(A.BeneficiaryPhoneNumber,'')) as PHONE_Recipient,
    /*MA_008:ATM(6) - BEGIN*/
    --Convert(varchar(15),ISNULL(A.BeneficiaryCelularNumber,'')) as CELL_PHONE_Recipient,
    case
	   when A.IdPaymentType = 6 then Convert(varchar(15),ISNULL(A.DepositAccountNumber,''))
	   else Convert(varchar(15),ISNULL(A.BeneficiaryCelularNumber,''))
    end as CELL_PHONE_Recipient,
    /*MA_008:ATM(6) - END*/
    

    Convert(varchar(100),'') as EMAIL_Recipient,
    Isnull(K.BTSIdentificationType,'') as TYPE_CD,
    Isnull(K.BTSIdentificationIssuer,'') as ISSUER_CD,
    Convert(varchar(3),'') as ISSUER_STATE_CD,
    Convert(varchar(3),'') as ISSUER_COUNTRY_CD,
    
    IsNull(A.CustomerIdentificationNumber,'') as IDENTIF_NM,

    Convert(varchar(8),'') as EXPIRATION_DT,
    Convert(varchar(8),'') as DOB_DT,
    Convert(varchar(40),'') as OCCUPATION,
    Convert(varchar(11),'') as SSN,
    Convert(varchar(40),'') as SOURCE_OF_FUNDS_DS,
    Convert(varchar(40),'') as REASON_OF_TRANS_DS

    /*MA_008:ATM(6) - BEGIN*/
    ,case
	   when A.IdPaymentType = 6 then Convert(varchar(4),ISNULL('TLCL',''))
	   else Convert(varchar(4),'')
    end as CELL_CARRIER_CODE_Recipient,

    case
	   when A.IdPaymentType=6 then Convert(varchar(3),ISNULL('MEX',''))
	   else Convert(varchar(3),'')
    end as CELL_CARRIER_COUNTRY_CD_Recipient
    /*MA_008:ATM(6) - END*/

From dbo.[Transfer] A WITH (NOLOCK)
    Join dbo.CountryCurrency B WITH (NOLOCK) on (A.IdCountryCurrency=B.IdCountryCurrency)
    Join dbo.Country C WITH (NOLOCK) on (B.IdCountry=C.IdCountry)
    Join dbo.Currency D WITH (NOLOCK) on (D.IdCurrency=B.IdCurrency)
    Join dbo.Agent E WITH (NOLOCK) on (A.IdAgent=E.IdAgent)
    Join dbo.Users F WITH (NOLOCK) on (F.IdUser=A.EnterByIdUser)
    Join dbo.Payer G WITH (NOLOCK) on (G.IdPayer=A.IdPayer)
    Left Join dbo.Branch H WITH (NOLOCK) on (H.IdBranch=A.IdBranch)
    Left Join dbo.City I WITH (NOLOCK) on (I.IdCity=H.IdCity)
    Left Join dbo.[State] J WITH (NOLOCK) on (J.IdState=I.IdState)
    Left Join dbo.CustomerIdentificationType K WITH (NOLOCK) on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)
    left join dbo.Beneficiary ben WITH (NOLOCK) on ben.idbeneficiary=a.idbeneficiary
    left join dbo.[BeneficiaryIdentificationType] benid WITH (NOLOCK) on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
    left join dbo.CountryExrateConfig cex WITH (NOLOCK) on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway = 4 
    And IdStatus = 21
    --And IdTransfer in (9985299,9985300);

End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessage nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(20), ERROR_LINE()), 
	   @ErrorMessage = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetBTS',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

End Catch