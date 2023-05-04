/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="07/12/2018" Author="smacias"> Creado </log>
<log Date="28/07/2020" Author="jgomez"> Se agrega columna BenCellPhoneIsRequired </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [Corp].[st_GetPayerConfigByPayer]
(
	@idPayer int
)
AS  

Set nocount on;
Begin try
	Select 
	PC.IdPaymentType, RequireBranch, CountryName, CurrencyName, DepositHold, GatewayName, GenericStatus, PC.IdCountryCurrency,
	PC.IdGateway, PC.IdGenericStatus, IdPayerConfig, PaymentName, SpreadValue, EnabledSchedule, StartTime, EndTime, case 
    when PC.BenCellPhoneIsRequired is null then 0 else PC.BenCellPhoneIsRequired end BenCellPhoneIsRequired
	,PC.BranchCodeIsRequired
	from PayerConfig PC with (NOLOCK) 
	join CountryCurrency CC with (NOLOCK) on PC.IdCountryCurrency = CC.IdCountryCurrency 
	join Country Cou with (NOLOCK) on CC.IdCountry = Cou.IdCountry
	join Currency Curr with (NOLOCK) on CC.IdCurrency = Curr.IdCurrency 
	join Gateway GT with (NOLOCK) on PC.IdGateway = GT.IdGateway 
	join GenericStatus GS with (NOLOCK) on PC.IdGenericStatus = GS.IdGenericStatus
	join PaymentType PT with (NOLOCK) on PC.IdPaymentType = PT.IdPaymentType
	where PC.IdPayer = @idPayer
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetPayerConfigByPayer',Getdate(),@ErrorMessage);
End catch