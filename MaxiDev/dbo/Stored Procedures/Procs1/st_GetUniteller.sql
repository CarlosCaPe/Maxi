

CREATE Procedure [dbo].[st_GetUniteller]
AS 

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="06/01/2020" Author="jdarellano" Name="#1">Se agrega IdPayer=5334 para Bantrab.</log>
<log Date="06/01/2020" Author="jdarellano" Name="#2">Se agrega IdPayer=5333 para 7 Eleven.</log>
<log Date="17/03/2022" Author="jcsierra" Name="#3">Se agrega IdPayer=5485 Aurrera Express.</log>
<log Date="18/05/2022" Author="adominguez" Name="#4">Se agrega formato a fechas.</log>
<log Date="23/05/2022" Author="adominguez" Name="#5">Se agrega la leyenda 'Reason Other' en el campo reserved3 solo para SACOMBANK de Vietnam.</log>
<log Date="23/05/2022" Author="adominguez" Name="#6">Se pagadores Asia</log>
<log Date="04/07/2022" Author="adominguez" Name="#7">Se agrega la separacion de nombre y segundo nombre.</log>
<log Date="05/08/2022" Author="jdarellano" Name="#8">Se agrega IdPayer=5333 para Walmart Express.</log>
<log Date="10/08/2022" Author="adominguez" Name="#9">Se agrega el pagador Caja las huastecas.</log>
<log Date="24/08/2022" Author="jdarellano" Name="#10">Se agrega IdPayer 5557 para Aurrera Express 8,000.</log>
<log Date="30/08/2022" Author="adominguez" Name="#11">Se agregan pagadores de Indonesia.</log>
<log Date="30/10/2022" Author="adominguez" Name="#12">Se pagador Coop fronteriza para Honduras.</log>  
<log Date="10/11/2022" Author="adominguez" Name="#13">Se agregan pagadores de More.</log> 
<log Date="2023/01/30" Author="jdarellano" Name="#14">Se cambia IdPayer 5955 por el 5835, ya es el IdPayer correcto en Producción.</log>
<log Date="10/02/2022" Author="adominguez" Name="#15">Se agrega config para Interbank Soles.</log> 
</ChangeLog>
******************************************* **************************/

Set nocount on                             
                        
--- Get Minutes to wait to be send to service ---                        
Declare @MinutsToWait Int                        
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                        
                        
---  Update transfer to Attempt -----------------                        
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=22 and  IdStatus=20                      
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                            
--------- Tranfer log ---------------------------                    
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                     
Select 21,IdTransfer,GETDATE() from #temp                        


Select 
--SECURITY INFORMATION
Trans.ClaimCode						as txIdentifier,
Trans.ClaimCode						as correspondentRefNumber,

--Por tipo de cambio a Honduras
case 
    when isnull(UseRefExrate,0) = 0 then Trans.AmountInMN 
    else round(dbo.funGetConvertAmount(Trans.AmountInMN ,Trans.referenceexrate)*Trans.referenceexrate,4)
end
/*Trans.AmountInMN*/					as paymentAmount,

CASE WHEN Curr.CurrencyCode = 'MXP' 
	THEN 'MXN' 
	ELSE Curr.CurrencyCode 
END									as paymentCurrency,
Coun.CountryCodeISO3166             as paymentCountry,
CASE Trans.IdPaymentType
	WHEN 1 THEN '001' --Cash
	WHEN 2 THEN '005' --Credit to acct
	WHEN 3 THEN '007' --Delivery
	WHEN 4 THEN '003' --Directed cash
END									as paymentType,
case 
    --select * from payer where payercode='banorte'
    when trans.idpayer=927 then 'CPM'
    when trans.idpayer=928 then 'ISSEG'
    when trans.idpayer=931 then 'UNIBANK'
    when trans.idpayer=932 then 'SCOTIA_SV'
    when trans.idpayer=933 then 'DAVIVIENDA'
	when trans.idpayer=934 then 'ATLANTIDA'
	when trans.idpayer=935 then 'BOLIVARIANO'
    when trans.idpayer=937 then 'SOL'
    when trans.idpayer=938 then 'WOO'
    when trans.idpayer=929 then 'OCCIDENTE'
    when trans.idpayer=926 then 'BANORTE'
    when trans.idpayer=1005 then 'CARIBEXPRESS_DR'
	when trans.idpayer=1009 then 'BANORTE'
	when trans.idpayer=1010 then 'CPM'
	when trans.idpayer=1011 then 'SOL'
    when trans.idpayer=1012 then 'WOO'
	when trans.idpayer = 2550 then 'WALMART'
	when trans.idpayer = 2551 then 'WALMART'
	when trans.idpayer = 2552 then 'WALMART'
	when trans.idpayer = 2553 then 'WALMART'

	when trans.idpayer = 5283 then 'WALMART'
	when trans.idpayer = 5284 then 'WALMART'
	when trans.idpayer = 5285 then 'WALMART'
	when trans.idpayer = 5714 then 'WALMART'--#8

	when trans.idpayer = 2201 then 'BARAHONA_DR'
	when trans.idpayer = 2202 then 'BONAO_DR'
	when trans.idpayer = 2203 then 'CIBAO_DR'
	when trans.idpayer = 2204 then 'COTUI_DR'
	when trans.idpayer = 2205 then 'DOMINICANA_DR'
	when trans.idpayer = 2206 then 'DUARTE_DR'
	when trans.idpayer = 2207 then 'HIGUAMO_DR'
	when trans.idpayer = 2208 then 'NACIONAL_DR'
	when trans.idpayer = 2209 then 'PREVISORA_DR'
	when trans.idpayer = 2210 then 'VEGA_REAL_DR'
	when trans.idpayer = 2211 then 'MAGUANA_DR'
	when trans.idpayer = 2212 then 'MOCANA_DR'
	when trans.idpayer = 2213 then 'NOROESTANA_DR'
	when trans.idpayer = 2214 then 'NORTENA_DR'
	when trans.idpayer = 2215 then 'PERAVIA_DR'
	when trans.idpayer = 2216 then 'ASOC_POPULAR_DR'
	when trans.idpayer = 2217 then 'ROMANA_DR'
	when trans.idpayer = 2218 then 'BDI_DR'
	when trans.idpayer = 2219 then 'CARIBEX_BHD_DR'
	when trans.idpayer = 2220 then 'CARIBE_DR'
	when trans.idpayer = 2221 then 'RESERVAS_DR'
	when trans.idpayer = 2222 then 'DOM_PROGRESO_DR'
	when trans.idpayer = 2223 then 'LEON_DR'
	when trans.idpayer = 2224 then 'LOPEZ_HARO_DR'
	when trans.idpayer = 2225 then 'POPULAR_DOM_DR'
	when trans.idpayer = 2226 then 'SANTA_CRUZ_DR'
	when trans.idpayer = 2227 then 'VIMENCA_DR'
	when trans.idpayer = 2228 then 'SCOTIA_DR'

	when trans.idpayer = 5210 then 'S_BAJIO'
	when trans.idpayer = 5211 then 'S_BANAMEX'
	when trans.idpayer = 5212 then 'S_BASE'
	when trans.idpayer = 5213 then 'S_FAMSA'
	when trans.idpayer = 5214 then 'S_BANCOMEXT'
	when trans.idpayer = 5215 then 'S_BANJERCITO'
	when trans.idpayer = 5216 then 'S_BOFA'
	when trans.idpayer = 5217 then 'S_BANREGIO'
	when trans.idpayer = 5218 then 'S_BANSI'
	when trans.idpayer = 5219 then 'S_CIBANCO'
	when trans.idpayer = 5220 then 'S_HSBC'
	when trans.idpayer = 5221 then 'S_INBURSA'
	when trans.idpayer = 5222 then 'S_JPMORGAN'
	when trans.idpayer = 5223 then 'S_SANTANDER'
	when trans.idpayer = 5224 then 'S_MONEX'
	when trans.idpayer = 5225 then 'S_INTERACCIONES'
	when trans.idpayer = 5226 then 'S_SCOTIA'
	when trans.idpayer = 5227 then 'S_WALMART'
	when trans.idpayer = 5228 then 'S_BANSEFI'
	when trans.idpayer = 5229 then 'S_BANCOPPEL'

	when trans.idpayer = 5231 then 'S_AFIRME'
	when trans.idpayer = 5232 then 'S_COMPARTAMOS'
	when trans.idpayer = 5233 then 'S_BANKAOOL'
	when trans.idpayer = 5234 then 'S_BANCREA'
	when trans.idpayer = 5235 then 'S_LIBERTAD'
	when trans.idpayer = 5236 then 'S_HUASTECAS'
	when trans.idpayer = 5237 then 'S_INBURSA'
	when trans.idpayer = 5238 then 'S_CPM' 

	when trans.idpayer = 5334 then 'BANTRAB'--#1
	when trans.idpayer = 5333 then '7ELEVEN'--#2
	when trans.idpayer = 5485 then 'AURRERA'--#3
	WHEN trans.idpayer = 5557 THEN 'AURRERA'--#10

	when trans.idpayer = 5518 then 'BANCOLOMBIA'
	when trans.idpayer = 5520 then 'POPULAR'
	when trans.idpayer = 5524 then 'BADOPEM_DR'
	when trans.idpayer = 5525 then 'BRIO_DR'
	when trans.idpayer = 5527 then 'BLDEHARO_DR'
	when trans.idpayer = 5528 then 'BADEMI_DR'
	when trans.idpayer = 5529 then 'BBDA_DR'
	when trans.idpayer = 5530 then 'APERAVIA_DR'
	when trans.idpayer = 5531 then 'ANORTENA_DR'
	when trans.idpayer = 5532 then 'BPROVIDENCIAL_DR'
	when trans.idpayer = 5533 then 'BPROMERICA_DR'
	when trans.idpayer = 5534 then 'BPROGRESO_DR'
	when trans.idpayer = 5535 then 'BTUI_DR'
	when trans.idpayer = 5536 then 'BBELLBANK_DR'
	when trans.idpayer = 5537 then 'AROMANA_DR'
	when trans.idpayer = 5538 then 'BAGRICOLA_DR'
	when trans.idpayer = 5539 then 'ADOMIN_DR'
	when trans.idpayer = 5540 then 'BAMERICAS_DR'
	when trans.idpayer = 5541 then 'BMOTOR_DR'
	when trans.idpayer = 5542 then 'ACIBAO_DR'
	when trans.idpayer = 5543 then 'BUNION_DR'
	when trans.idpayer = 5544 then 'ABONAO_DR'
	when trans.idpayer = 5545 then 'BATLANTICO_DR'
	when trans.idpayer = 5546 then 'AMOCANA_DR'
	when trans.idpayer = 5547 then 'ANACIONAL_DR'
	when trans.idpayer = 5548 then 'BCONFISA_DR'
	when trans.idpayer = 5549 then 'BCITIBANK_DR'
	when trans.idpayer = 5550 then 'APOPULAR_DR'
	when trans.idpayer = 5551 then 'AVEGREAL_DR'
	when trans.idpayer = 5552 then 'ANOROESTANA_DR'
	when trans.idpayer = 5553 then 'BATLAS_DR'
	when trans.idpayer = 5554 then 'BNACVIVIENDA_DR'
	when trans.idpayer = 5555 then 'BFIHOGAR_DR'
	

	/*Pagadores Asia*/ --#6
when trans.idpayer = 5558 then 'BDO'
when trans.idpayer = 5559 then 'BPI'
when trans.idpayer = 5560 then 'PNB'
when trans.idpayer = 5561 then 'M_LHUILLIER'
when trans.idpayer = 5562 then 'PALAWAN'
when trans.idpayer = 5563 then 'METRO'
when trans.idpayer = 5564 then 'SIANDE'
when trans.idpayer = 5565 then 'SACOMBANK'
when trans.idpayer = 5566 then 'VIETCOM'
when trans.idpayer = 5567 then 'DONGABANK'
when trans.idpayer = 5568 then 'ALLB_PHP'
when trans.idpayer = 5569 then 'ANZ_PHP'
when trans.idpayer = 5570 then 'AUB_PHP'
when trans.idpayer = 5571 then 'BDOF_PHP'
when trans.idpayer = 5572 then 'BANGK_PHP'
when trans.idpayer = 5573 then 'BOFA_PHP'
when trans.idpayer = 5574 then 'BCH_PHP'
when trans.idpayer = 5575 then 'BOC_PHP'
when trans.idpayer = 5576 then 'BOT_PHP'
when trans.idpayer = 5577 then 'BDON_PHP'
when trans.idpayer = 5578 then 'BDOP_PHP'
when trans.idpayer = 5579 then 'BOFO_PHP'
when trans.idpayer = 5580 then 'BPIF_PHP'
when trans.idpayer = 5581 then 'CLHU_PHP'
when trans.idpayer = 5582 then 'CBS_PHP'
when trans.idpayer = 5583 then 'CBC'
when trans.idpayer = 5584 then 'CTB_PHP'
when trans.idpayer = 5585 then 'CIMB_PHP'
when trans.idpayer = 5586 then 'CITI_PHP'
when trans.idpayer = 5587 then 'DCPAY_PHP'
when trans.idpayer = 5588 then 'DB_PHP'
when trans.idpayer = 5589 then 'DBF_PHP'
when trans.idpayer = 5590 then 'DUNGO_PHP'
when trans.idpayer = 5591 then 'EWB_PHP'
when trans.idpayer = 5592 then 'EWRB_PHP'
when trans.idpayer = 5593 then 'EQSB_PHP'
when trans.idpayer = 5594 then 'FCB_PHP'
when trans.idpayer = 5595 then 'GXH_PHP'
when trans.idpayer = 5596 then 'HSBC_PHP'
when trans.idpayer = 5597 then 'HSBCS_PHP'
when trans.idpayer = 5598 then 'IBOK_PHP'
when trans.idpayer = 5599 then 'INGO_PHP'
when trans.idpayer = 5600 then 'ISLA_PHP'
when trans.idpayer = 5601 then 'ISLAM_PHP'
when trans.idpayer = 5602 then 'JMPC_PHP'
when trans.idpayer = 5603 then 'KEBH_PHP'
when trans.idpayer = 5604 then 'LNDBNKF_PHP'
when trans.idpayer = 5605 then 'MAL_PHP'
when trans.idpayer = 5606 then 'MAY_PHP'
when trans.idpayer = 5607 then 'MTROBNKF_PHP'
when trans.idpayer = 5608 then 'MIZUB_PHP'
when trans.idpayer = 5609 then 'MUFG_PHP'
when trans.idpayer = 5610 then 'OMINP_PHP'
when trans.idpayer = 5611 then 'PRTN_PHP'
when trans.idpayer = 5612 then 'PMP_PHP'
when trans.idpayer = 5613 then 'PBCOM_PHP'
when trans.idpayer = 5614 then 'PBB_PHP'
when trans.idpayer = 5615 then 'PSB_PHP'
when trans.idpayer = 5616 then 'PTB_PHP'
when trans.idpayer = 5617 then 'PVB_PHP'
when trans.idpayer = 5618 then 'PNBF_PHP'
when trans.idpayer = 5619 then 'PNBS_PHP'
when trans.idpayer = 5620 then 'PSBC_PHP'
when trans.idpayer = 5621 then 'QCAPI_PHP'
when trans.idpayer = 5622 then 'RCBC'
when trans.idpayer = 5623 then 'RCBCS_PHP'
when trans.idpayer = 5624 then 'RSB_PHP'
when trans.idpayer = 5625 then 'RBGI_PHP'
when trans.idpayer = 5626 then 'SB_PHP'
when trans.idpayer = 5627 then 'SHINH_PHP'
when trans.idpayer = 5628 then 'SCB_PHP'
when trans.idpayer = 5629 then 'STRBK_PHP'
when trans.idpayer = 5630 then 'SMBC_PHP'
when trans.idpayer = 5631 then 'SUN_PHP'
when trans.idpayer = 5632 then 'UCPBS_PHP'
when trans.idpayer = 5633 then 'UB_PHP'
when trans.idpayer = 5634 then 'UCPB_PHP'
when trans.idpayer = 5635 then 'UOB_PHP'
when trans.idpayer = 5636 then 'WLTH_PHP'
when trans.idpayer = 5637 then 'YSBP_PHP'
 
/*Caja las Huastecas*/
when trans.idpayer = 5716 then 'FOLIO_MEX'	--#9	
/*Pagadores Indonesia*/--#11
when trans.idpayer = 5845 then 'MAYBANK_ID'
when trans.idpayer = 5846 then 'JANBARBANK_ID'--'JABAR_ID'
when trans.idpayer = 5847 then 'JATENG_ID'
when trans.idpayer = 5848 then 'JATIM_ID'
when trans.idpayer = 5849 then 'QNB_ID'
when trans.idpayer = 5850 then 'LAMPUNG_ID'
when trans.idpayer = 5851 then 'MALUKU_ID'
when trans.idpayer = 5852 then 'MANDIRI_ID'
when trans.idpayer = 5853 then 'MAYAPADA_ID'
when trans.idpayer = 5854 then 'MAYORA_ID'
when trans.idpayer = 5855 then 'BANKMEGA_ID'
when trans.idpayer = 5856 then 'MESTIKA_ID'
when trans.idpayer = 5857 then 'MUAMALAT_ID'
when trans.idpayer = 5858 then 'NAGARI_ID'
when trans.idpayer = 5859 then 'NAGARA_ID'
when trans.idpayer = 5860 then 'CIMBNIAGA_ID'
when trans.idpayer = 5861 then 'OCBCNISP_ID'
when trans.idpayer = 5862 then 'BNTB_ID'
when trans.idpayer = 5863 then 'BNIT_ID'
when trans.idpayer = 5864 then 'NUSANTA_ID'
when trans.idpayer = 5865 then 'BPANINI_ID'
when trans.idpayer = 5866 then 'BPAPUA_ID'
when trans.idpayer = 5867 then 'BPERMATA_ID'
when trans.idpayer = 5868 then 'BRAKYAT_ID'
when trans.idpayer = 5869 then 'BRIAU_ID'
when trans.idpayer = 5870 then 'BSULUTU_ID'
when trans.idpayer = 5871 then 'SUMSEI_ID'
when trans.idpayer = 5872 then 'SUMUT_ID'
when trans.idpayer = 5873 then 'BINDIA_ID'
when trans.idpayer = 5874 then 'SYAMANDIRI_ID'
when trans.idpayer = 5875 then 'SYAMEGA_ID'
when trans.idpayer = 5876 then 'ACEHBNK_ID' --'BACEH_ID'
when trans.idpayer = 5877 then 'BPDBALI_ID'
when trans.idpayer = 5878 then 'BDIY_ID'
when trans.idpayer = 5879 then 'JABMBI_ID'
when trans.idpayer = 5880 then 'KALBAR_ID'
when trans.idpayer = 5881 then 'KALSEL_ID'
when trans.idpayer = 5882 then 'KALTENG_ID'
when trans.idpayer = 5883 then 'KALTIM_ID'
when trans.idpayer = 5884 then 'SULTRA_ID'
when trans.idpayer = 5885 then 'SULSERBAR_ID'
when trans.idpayer = 5886 then 'SULTENG_ID'
when trans.idpayer = 5887 then 'BSINARMAS_ID'
when trans.idpayer = 5888 then 'EKONOMI_ID'
when trans.idpayer = 5889 then 'BTNAGARA_ID'
when trans.idpayer = 5890 then 'CITIBANK_ID'
when trans.idpayer = 5891 then 'STDCHART_ID'
when trans.idpayer = 5892 then 'JTRUST_ID'
when trans.idpayer = 5893 then 'BRI_ID'
when trans.idpayer = 5894 then 'BJABAR_ID'
when trans.idpayer = 5895 then 'RABOBANK_ID'
when trans.idpayer = 5896 then 'BPRKS_ID'
when trans.idpayer = 5897 then 'BCASIA_ID'
when trans.idpayer = 5898 then 'BSYARIAH_ID'
when trans.idpayer = 5899 then 'SBI_ID'
when trans.idpayer = 5900 then 'JASA_ID'
when trans.idpayer = 5901 then 'MASPION_ID'
when trans.idpayer = 5902 then 'BCA_ID'
when trans.idpayer = 5903 then 'BVICTORIA_ID'
when trans.idpayer = 5904 then 'BANTAR_ID'
when trans.idpayer = 5905 then 'CTBC_ID'
when trans.idpayer = 5906 then 'WINDU_ID'
when trans.idpayer = 5907 then 'BTOKYO_ID'
when trans.idpayer = 5908 then 'ANZ_ID'
when trans.idpayer = 5909 then 'ARTHA_ID'
when trans.idpayer = 5910 then 'DBS_ID'
when trans.idpayer = 5911 then 'BOCHINA_ID'
when trans.idpayer = 5912 then 'BUMI_ID'
when trans.idpayer = 5913 then 'KEB_ID'
when trans.idpayer = 5914 then 'BROYAL_ID'
when trans.idpayer = 5915 then 'NOBU_ID'
when trans.idpayer = 5916 then 'BVSYARIAH_ID'
when trans.idpayer = 5917 then 'BPANIND_ID'
when trans.idpayer = 5918 then 'SAHABAT_ID'
when trans.idpayer = 5919 then 'AGRIS_ID'
when trans.idpayer = 5920 then 'SHINAN_ID'
when trans.idpayer = 5921 then 'ICBC_ID'
when trans.idpayer = 5922 then 'YUDHA_ID'
when trans.idpayer = 5923 then 'BPRIMA_ID'
when trans.idpayer = 5924 then 'DINAR_ID'
when trans.idpayer = 5925 then 'BTPNS_ID'
when trans.idpayer = 5926 then 'CNB_ID'
when trans.idpayer = 5927 then 'MANTAP_ID'
when trans.idpayer = 5928 then 'HARDA_ID'
when trans.idpayer = 5929 then 'MAYBANKS_ID'
when trans.idpayer = 5930 then 'BHSBCI_ID'
when trans.idpayer = 5931 then 'BPREKA_ID'
when trans.idpayer = 5932 then 'LINKAJA_ID'
when trans.idpayer = 5933 then 'INDOSAT_ID'
when trans.idpayer = 5934 then 'BCOMM_ID'--'BCOMMON_ID'
when trans.idpayer = 5935 then 'BNI_ID'
when trans.idpayer = 5936 then 'ATMB_ID'
when trans.idpayer = 5937 then 'ATMBPLUS_ID'
when trans.idpayer = 5938 then 'BRIAGRON_ID'
when trans.idpayer = 5939 then 'BANKARTOS_ID'
when trans.idpayer = 5940 then 'BENKULU_ID'
when trans.idpayer = 5941 then 'BANKOUB_ID'
when trans.idpayer = 5942 then 'BUKOPINBNK_ID'--'BUKOPIN_ID'
when trans.idpayer = 5943 then 'MNC_ID'
when trans.idpayer = 5944 then 'BTPN_ID'
when trans.idpayer = 5945 then 'BACPITAL_ID'
when trans.idpayer = 5946 then 'BDANAMON_ID'
when trans.idpayer = 5947 then 'BANKDKI_ID'
when trans.idpayer = 5948 then 'GANESHA_ID'
when trans.idpayer = 5949 then 'BWOORI_ID'
when trans.idpayer = 5950 then 'BHSBC_ID'
when trans.idpayer = 5951 then 'INDEX_ID'
when trans.idpayer = 5952 then 'PERDANA_ID'		  

when Trans.IdPayer = 5835 then 'FRONTERIZA'--#12											

/*Pagadores More*/--#13
when trans.idpayer = 6046 then 'MMTPA'
when trans.idpayer = 6047 then 'MMTPY'
when trans.idpayer = 6048 then 'MTPY_MAXI'
when trans.idpayer = 6049 then 'MTPY_PRACTI'
when trans.idpayer = 6050 then 'MTPY_AQP'
when trans.idpayer = 6051 then 'MMTUY'
when trans.idpayer = 6052 then 'MTUY_RED'
when trans.idpayer = 6053 then 'MTUY_HERITAGE'
when trans.idpayer = 6054 then 'MTUY_BSANTANDER'
when trans.idpayer = 6055 then 'MTUY_HSBC'
when trans.idpayer = 6056 then 'MTUY_BBVA'
when trans.idpayer = 6057 then 'MTUY_CITIBANK'
when trans.idpayer = 6058 then 'MTUY_SCOTIABANK'
when trans.idpayer = 6059 then 'MTUY_BITAU'
when trans.idpayer = 6060 then 'MTUY_BREPUBLICA'
when trans.idpayer = 6061 then 'MTUY_BANDES'
when trans.idpayer = 6062 then 'MMTAR'
when trans.idpayer = 6063 then 'MTAR_ITAU'
when trans.idpayer = 6064 then 'MTAR_SANTANDER'
when trans.idpayer = 6065 then 'MTAR_BCORDOBA'
when trans.idpayer = 6066 then 'MTAR_BCOLUMBIA'
when trans.idpayer = 6067 then 'MTAR_BCHACO'
when trans.idpayer = 6068 then 'MTAR_ICBC'
when trans.idpayer = 6069 then 'MTAR_BSTACRUZ'
when trans.idpayer = 6070 then 'MTAR_PROVINCIA'
when trans.idpayer = 6071 then 'MTAR_VALORES'
when trans.idpayer = 6072 then 'MTAR_PROVTIERRA'
when trans.idpayer = 6073 then 'MTAR_BNACION'
when trans.idpayer = 6074 then 'MTAR_HSBC'
when trans.idpayer = 6075 then 'MTAR_PROVERIOS'
when trans.idpayer = 6076 then 'MTAR_BCOMAFI'
when trans.idpayer = 6077 then 'MTAR_CITIBANK'
when trans.idpayer = 6078 then 'MTAR_CREDICOOP'
when trans.idpayer = 6079 then 'MTAR_PATAGONIA'
when trans.idpayer = 6080 then 'MTAR_PROVSFE'
when trans.idpayer = 6081 then 'MTAR_PROVCORRIEN'
when trans.idpayer = 6082 then 'MTAR_BCIUDAD'
when trans.idpayer = 6083 then 'MTAR_GALICIA'
when trans.idpayer = 6084 then 'MTAR_BMACRO'
when trans.idpayer = 6085 then 'MTAR_BSUPERVIE'
when trans.idpayer = 6086 then 'MTAR_BINDUSTRIAL'
when trans.idpayer = 6087 then 'MTAR_BRIOJA'
when trans.idpayer = 6088 then 'MTAR_BBVA'
when trans.idpayer = 6089 then 'MTAR_PROVPAMPA'
when trans.idpayer = 6090 then 'MTAR_PROVNEUQUEN'
when trans.idpayer = 6091 then 'MTAR_BFORMOSA'
when trans.idpayer = 6092 then 'MTAR_BFINANSUR'
when trans.idpayer = 6093 then 'MTAR_BSNJUAN'
when trans.idpayer = 6094 then 'MTAR_SANESTERO'
when trans.idpayer = 6095 then 'MTAR_BHIPOTEC'
when trans.idpayer = 6097 then 'MTBO_PYME'
when trans.idpayer = 6098 then 'MTBO_ECON'
when trans.idpayer = 6099 then 'MTBO_FIE'
when trans.idpayer = 6100 then 'MTBO_BNB'
when trans.idpayer = 6101 then 'MTBO_BPC'
when trans.idpayer = 6102 then 'MTBO_BFASSIL'
when trans.idpayer = 6103 then 'MTBO_FINANFIE'
when trans.idpayer = 6104 then 'MTBO_BGANADERO'
when trans.idpayer = 6105 then 'MTBO_BANDES'
when trans.idpayer = 6106 then 'MTBO_COOPJNAZ'
when trans.idpayer = 6107 then 'MTBO_BSTACRUZ'
when trans.idpayer = 6108 then 'MTBO_BBISA'
when trans.idpayer = 6109 then 'MTBO_BSOL'
when trans.idpayer = 6110 then 'MTBO_BNACIONAL'
when trans.idpayer = 6111 then 'MTBO_BECOFUTURO'
when trans.idpayer = 6112 then 'MTBO_BECONOMICO'
when trans.idpayer = 6113 then 'MTBO_BBCP'
when trans.idpayer = 6114 then 'MTBO_BFORTALEZA'
when trans.idpayer = 6115 then 'MTBO_BDOBRASIL'
when trans.idpayer = 6116 then 'MTBO_BUNION'
when trans.idpayer = 6117 then 'MMTCH'
when trans.idpayer = 6118 then 'MTCH_BPENTA'
when trans.idpayer = 6119 then 'MTCH_INVERSIONES'
when trans.idpayer = 6120 then 'MTCH_BFALABELLA'
when trans.idpayer = 6121 then 'MTCH_BITAU'
when trans.idpayer = 6122 then 'MTCH_BBVA'
when trans.idpayer = 6123 then 'MTCH_TRANSBANK'
when trans.idpayer = 6124 then 'MTCH_BDESARROLLO'
when trans.idpayer = 6125 then 'MTCH_BSECURITY'
when trans.idpayer = 6126 then 'MTCH_BCONSORCIO'
when trans.idpayer = 6127 then 'MTCH_BINTERNAC'
when trans.idpayer = 6128 then 'MTCH_BSANTIAGO'
when trans.idpayer = 6129 then 'MTCH_SERVIPAG'
when trans.idpayer = 6130 then 'MTCH_CITYBNK'
when trans.idpayer = 6131 then 'MTCH_BBICE'
when trans.idpayer = 6132 then 'MTCH_BESTADO'
when trans.idpayer = 6133 then 'MTCH_HSBC'
when trans.idpayer = 6134 then 'MTCH_BRIPLEY'
when trans.idpayer = 6135 then 'MTCH_CREDICHILE'
when trans.idpayer = 6136 then 'MMTBO'
when trans.idpayer = 6137 then 'INTERBANK'
else
        ''
end
AS paymentLocation,
CASE WHEN Trans.IdPaymentType = 2
	THEN Trans.DepositAccountNumber
	ELSE ''
END									AS accountNumber,
case when trans.idpayer IN (1005,2201,2202,2203,2204,2205,2206,2207,2208,2209,2210,2211,2212,2213,2214,2215,2216,2217,2218,2219,2220,2221,2222,2223,2224,2225,2226,2227,2228) and trans.IdPaymentType=2 then 'SAVING' 
	when trans.idpayer IN (2218, 2220, 2221, 2225, 2226, 2227, 5511, 5524, 5525, 5526, 5527, 5528, 5529, 5530, 5531, 5532, 5533, 5534, 5535, 5536, 5537, 5538, 5539, 5540, 5541, 5542, 5543, 5544, 5545, 5546, 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5555, 6137) and trans.IdPaymentType=2 and Trans.AccountTypeId = 1 then 'CHECKING'--#15
	when trans.idpayer IN (2218, 2220, 2221, 2225, 2226, 2227, 5511, 5524, 5525, 5526, 5527, 5528, 5529, 5530, 5531, 5532, 5533, 5534, 5535, 5536, 5537, 5538, 5539, 5540, 5541, 5542, 5543, 5544, 5545, 5546, 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5555, 6137) and trans.IdPaymentType=2 and Trans.AccountTypeId = 2 then 'SAVING'--#15
	when trans.idpayer IN (5518) and trans.IdPaymentType=2 and Trans.AccountTypeId = 1 then 'D'
	when trans.idpayer IN (5518) and trans.IdPaymentType=2 and Trans.AccountTypeId = 2 then 'S'
	when trans.idpayer IN (6053,6054,6055,6056,6057,6058,6059,6060,6061) and trans.IdPaymentType=2 and Trans.AccountTypeId = 1 then 'CTE'
	when trans.idpayer IN (6053,6054,6055,6056,6057,6058,6059,6060,6061) and trans.IdPaymentType=2 and Trans.AccountTypeId = 2 then 'AHO'
else '' end 						AS accountType,
Trans.GatewayBranchCode				as payingAgentBranchCode,
--SOURCE INFORMATION
Agen.AgentCode						as txAgentCode,
dbo.fn_EspecialChrOFF(Agen.AgentState)						as txAgentState,
'US'								as txOriginCountry,
'USD'								as txOriginCurrency,
--Cambios para respetar el tipo de cambio oficial de honduras
case 
    when isnull(UseRefExrate,0) = 0 then Trans.AmountInDollars 
    else dbo.funGetConvertAmount(Trans.AmountInMN ,Trans.referenceexrate)
end
/*Trans.AmountInDollars*/				as txAmount,  
Trans.Fee							as txFee,
--Cambios para respetar el tipo de cambio oficial de honduras
case 
    when isnull(UseRefExrate,0) = 0 then Trans.ExRate 
    else Trans.referenceexrate
end
/*Trans.ExRate*/						as txExchangeRate,
'005'								as txCaptureMethod,		--GUI, Front-End App
CASE WHEN Trans.DateOfTransfer IS NULL
	THEN '' 
	ELSE FORMAT (Trans.DateOfTransfer, 'MMddyyyyHHmmss') END as txCreationDateLocal, --#4
--BENEFICARY INFORMATION
Trans.IdBeneficiary					as beneRefNumber,		--Reference number that uniquely identifies the beneficiary in the correspondent’s system
case SUBSTRING(Trans.BeneficiaryName,0, CHARINDEX(' ', Trans.BeneficiaryName))
when '' then Trans.BeneficiaryName
Else SUBSTRING(Trans.BeneficiaryName, 0 , CHARINDEX(' ', Trans.BeneficiaryName))
end		as beneFirstName,--#7
case SUBSTRING(Trans.BeneficiaryName,CHARINDEX(' ',Trans.BeneficiaryName),30)
when Trans.BeneficiaryName then ''
else SUBSTRING(Trans.BeneficiaryName,CHARINDEX(' ',Trans.BeneficiaryName),30)
end	as beneMidName,--#7
dbo.fn_EspecialChrOFF(Trans.BeneficiaryFirstLastName)		as beneLastName,
																	   
case when isnull(dbo.fn_EspecialChrOFF(Trans.BeneficiarySecondLastName),'')='' then '' else dbo.fn_EspecialChrOFF(Trans.BeneficiarySecondLastName) end		as beneSecondLastName,
CASE WHEN ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryAddress),'')='' THEN 'CONOCIDO'	else 	dbo.fn_EspecialChrOFF(Trans.BeneficiaryAddress) end	as beneAddress1,
''									as beneAddress2,
--isnull(case when isnull(dbo.fn_EspecialChrOFF(Trans.BeneficiaryCity),'')='' then c.CityName	ELSE 	Trans.BeneficiaryCity END,'')		as beneCity,
isnull(case when isnull(dbo.fn_EspecialChrOFF(Trans.BeneficiaryCity),'')='' then c.CityName	ELSE 	Trans.BeneficiaryCity END,'MEX')		as beneCity,
/*
case 
    when Coun.CountryCodeISO3166='MX' then 'AGU'								
    else 'HN-CM'
end as beneState, 
*/
--isnull(s.StateCodeISO3166,'') beneState,
isnull(s.StateCodeISO3166, 
	case 
		when Coun.CountryCodeISO3166='MX' and Trans.IdPaymentType=2 then 'MEX'
		when Coun.CountryCodeISO3166='PH' and Trans.IdPaymentType=2 then st.StateCodeISO3166
		when Coun.CountryCodeISO3166='ID' and Trans.IdPaymentType=2 then st.StateCodeISO3166																			  
		when Coun.CountryCodeISO3166='AR' and Trans.IdPaymentType=2 then st.StateCodeISO3166--#13
		when Coun.CountryCodeISO3166='BO' and Trans.IdPaymentType=2 then st.StateCodeISO3166--#13
		when Coun.CountryCodeISO3166='CL' and Trans.IdPaymentType=2 then st.StateCodeISO3166--#13
		when Coun.CountryCodeISO3166='PE' and Trans.IdPaymentType=2 then st.StateCodeISO3166--#13
		when Coun.CountryCodeISO3166='UY' and Trans.IdPaymentType=2 then st.StateCodeISO3166--#13
		else '' end) beneState,			 
/*'MX'*/
Coun.CountryCodeISO3166 			as beneCountry,
CASE WHEN ISNULL(Trans.BeneficiaryZipcode,'') = '' THEN '00000' ELSE dbo.fn_EspecialChrOFF(Trans.BeneficiaryZipCode) END as benePostalCode,
CASE WHEN ISNULL(Trans.BeneficiaryPhoneNumber,'') = '' THEN '0000000000' else dbo.fn_EspecialChrOFF(Trans.BeneficiaryPhoneNumber) END as benePhone,
CASE WHEN Trans.BeneficiaryBornDate IS NULL
	THEN '' 
	ELSE FORMAT (Trans.BeneficiaryBornDate, 'MMddyyyy') END as beneBirthDate,--#4
''									as beneIdentificationType,
''									as beneIdentificationNumber,
''									as beneEmail,
--SENDER INFORMATION
Trans.IdCustomer					as senderRefNumber, --Reference number that uniquely identifies the sender in the correspondent system
dbo.fn_EspecialChrOFF(Trans.CustomerName)					as senderFirstName,
''									as senderMidName,
dbo.fn_EspecialChrOFF(Trans.CustomerFirstLastName)			as senderLastName,
dbo.fn_EspecialChrOFF(Trans.CustomerSecondLastName)		as senderSecondLastName,
dbo.fn_EspecialChrOFF(Trans.CustomerAddress)				as senderAddress1,
''									as senderAddress2,
dbo.fn_EspecialChrOFF(Trans.CustomerCity)					as senderCity,
dbo.fn_EspecialChrOFF(Trans.CustomerState)					as senderState,
dbo.fn_EspecialChrOFF(Trans.CustomerZipcode)				as senderPostalCode,
CASE WHEN ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerPhoneNumber),'') = '' THEN '0000000000' ELSE dbo.fn_EspecialChrOFF(Trans.CustomerPhoneNumber) END	as senderPhone,
CASE WHEN Trans.CustomerBornDate IS NULL
	THEN '' 
	ELSE FORMAT (Trans.CustomerBornDate, 'MMddyyyy') END	as senderBirthDate,--#4
case when len(isnull(CusIdType.Name,''))>30 then substring(isnull(CusIdType.Name,''),1,30)
else
    isnull(CusIdType.Name,'')
end as senderIdentificationType,

case when len(isnull(Trans.CustomerIdentificationNumber,''))>20 then substring(isnull(Trans.CustomerIdentificationNumber,''),1,20)
else
    isnull(Trans.CustomerIdentificationNumber,'')
end as senderIdentificationNumber,
''									as senderEmail,
''									as reserved1,
''									as reserved2,
case When trans.idpayer = 5565 then 'Reason Other' --#5
else ''								
End as reserved3,
'' AccountCreditAdditionalData,
'' ComplianceAdditionalData,
case 
when Coun.CountryCodeISO3166='AR' then 'beneCuil!#!' + BeneficiaryIdentificationNumber
when Coun.CountryCodeISO3166='CL' then 'beneRut!#!' + BeneficiaryIdentificationNumber   
else '' 
End OtherAdditionalData, -- #10
'' PurposeOfTransaction,
'' RelationToBeneficiary,
'' SourceOfIncome
from [dbo].[Transfer] Trans WITH (NOLOCK)
INNER JOIN [dbo].[CountryCurrency] CoCurrency WITH (NOLOCK)
	on Trans.IdCountryCurrency = CoCurrency.IdCountryCurrency
INNER JOIN [dbo].[Country] Coun WITH (NOLOCK)
	on CoCurrency.IdCountry = Coun.IdCountry
INNER JOIN [dbo].[Currency] Curr WITH (NOLOCK)
	on CoCurrency.IdCurrency = Curr.IdCurrency
INNER JOIN [dbo].[Agent] Agen WITH (NOLOCK)
	on Trans.IdAgent = Agen.IdAgent
INNER JOIN [dbo].[Payer] Pay WITH (NOLOCK)
	on Trans.IdPayer = Pay.IdPayer							   
INNER JOIN [dbo].[PaymentType] PaTy WITH (NOLOCK)
													  
									
	on Trans.IdPaymentType = PaTy.IdPaymentType
left JOIN [dbo].branch b WITH (NOLOCK) on Trans.idbranch=b.idbranch
left join dbo.City c WITH (NOLOCK) on b.idcity=c.idcity
left join dbo.[State] s WITH (NOLOCK) on c.idstate=s.idstate
left join dbo.City cit WITH (NOLOCK) on cit.IdCity = Trans.TransferIdCity
left join dbo.[State] st WITH (NOLOCK) on cit.idstate=st.idstate
LEFT JOIN [dbo].[CustomerIdentificationType] CusIdType WITH (NOLOCK) 
	on Trans.CustomerIdCustomerIdentificationType = CusIdType.IdCustomerIdentificationType
left join dbo.CountryExrateConfig cex WITH (NOLOCK) on CoCurrency.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=Trans.idgateway
Where Trans.IdGateway=22 and IdStatus=21 

