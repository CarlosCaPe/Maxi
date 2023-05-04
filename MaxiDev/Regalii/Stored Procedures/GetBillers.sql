CREATE procedure [Regalii].[GetBillers]
--[Regalii].[GetBillers] 1242,30,'Isapres'
(
    @Idagent int,
    @IdCountry int,
    @BillerType nvarchar(max)
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez">Sp que obtiene los billes por pais y tipo de biller</log>
</ChangeLog>
*********************************************************************/

declare @BillerTypeCell varchar(500) = (select Value from GlobalAttributes with(nolock) where Name='RegaliiBillerTypeCell')
declare @IdOtherProduct int

if (@BillerType != @BillerTypeCell or @BillerType = 'PostPaidCell')
	set @IdOtherProduct = 14
else
	set @IdOtherProduct = 17


	--select @IdOtherProduct



--Biller Info
select 
    b.IdBiller,Name,BillerType,CanCheckBalance,SupportsPartialPayments,RequiresNameOnAccount
	,case
		when b.IdOtherProduct = 17 then AvailableTopupAmounts
		else ''
	end AvailableTopupAmounts
	,HoursToFulfill,LocalCurrency,AccountNumberDigits,Mask,BillType, BillerType,Country CountryRegaliiName ,IdCountry,b.IdCurrency,
    isnull(LocalCurrency,CurrencyCode) CurrencyCode,
 --   case
	--	when b.IdOtherProduct = 14 then ISNULL(c.exchange,1)
	--	else 0
	--end exchange,
	ISNULL(c.exchange,1) exchange,
    case
		when b.IdOtherProduct = 14 then isnull(sc.spread,0)
		else 0
	end CurrencySpread,
	b.TopUpCommission
from 
    [Regalii].[Billers] b with(nolock)
LEFT join 
    [Regalii].[Currencies] c with(nolock) on b.idcurrency=c.idcurrency
left join
    currency cu with(nolock) on c.idcurrency=cu.idcurrency
left join 
    Regalii.CurrenciesSpread sc with(nolock) on b.IdCurrency=sc.IdCurrency
where  b.IdOtherProduct = @IdOtherProduct 
	and idcountry=@IdCountry
	and b.IdGenericStatus = 1
	and billertype=@BillerType


if @IdOtherProduct = 14
BEGIN
	--Declare @IdOtherProduct int = 14
	Declare @idfeebyotherproducts int=0
	Declare @idCommissionbyotherproducts int=0
	--Fee Info
	select @idfeebyotherproducts=idfeebyotherproducts,@idCommissionbyotherproducts=idCommissionbyotherproducts from [AgentOtherProductInfo] with(nolock) where idagent=@Idagent and idotherproduct=@IdOtherProduct

	select IdFeeDetailByOtherProductsr,IdFeeByOtherProducts,FromAmount,ToAmount,Fee,IsFeePercentage  from [FeeDetailByOtherProducts] with(nolock) where idfeebyotherproducts=@idfeebyotherproducts
	select IdCommissionDetailByProvider,IdCommissionByOtherProducts,FromAmount,ToAmount,AgentCommissionInPercentage,CorporateCommissionInPercentage,ExtraAmount  from [CommissionDetailByOtherProducts] with(nolock) where idCommissionbyotherproducts=@idCommissionbyotherproducts
END