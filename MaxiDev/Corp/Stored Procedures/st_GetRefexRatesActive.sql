CREATE PROCEDURE [Corp].[st_GetRefexRatesActive]
(
	@idCountryCurrency int,
	@idGateway int
)
AS  
Set nocount on;
IF OBJECT_ID('tempdb.dbo.#TmpBills', 'U') IS NOT NULL
  DROP TABLE #Rows;
IF OBJECT_ID('tempdb.dbo.#TmpBills', 'U') IS NOT NULL
  DROP TABLE #DatosTemp; 
Begin try
Create Table #Rows (
IdRefexRate int,
Active bit,
DateOfLastChange datetime,
RefExRate money,
CountryCode nvarchar(max),
IdCountry int,
CountryName nvarchar(max),
IdCurrency int,
CurrencyCode nvarchar(max),
CurrencyName nvarchar(max),
IdCountryCurrency int,
IdUser int,
UserName nvarchar(max),
IdGateway int,
GatewayCode nvarchar(max),
GatewayName nvarchar(max),
IdPayer int,
PayerName nvarchar(max),
PayerCode nvarchar(max)
);
Create Table #DatosTemp (
IdRefexRate int,
Active bit,
DateOfLastChange datetime,
RefExRate money,
CountryCode nvarchar(max),
IdCountry int,
CountryName nvarchar(max),
IdCurrency int,
CurrencyCode nvarchar(max),
CurrencyName nvarchar(max),
IdCountryCurrency int,
IdUser int,
UserName nvarchar(max),
IdGateway int,
GatewayCode nvarchar(max),
GatewayName nvarchar(max),
IdPayer int,
PayerName nvarchar(max),
PayerCode nvarchar(max)
);
	if (@idCountryCurrency >0 and @idGateway = 0)
	begin
		Insert into #Rows
		Select 
		IdRefexRate, Active, ref.DateOfLastChange, RefExRate, CountryCode, CC.IdCountry, CountryName, CC.IdCurrency, CurrencyCode,
		CurrencyName, ref.IdCountryCurrency, ref.EnterByIdUser as IdUser, UserName, ref.IdGateway, G.Code as GatewayCode, GatewayName, 0 as IdPayer, '' as PayerName,'' as PayerCode
		from RefExRate ref WITH (NOLOCK)
		join CountryCurrency CC WITH (NOLOCK) on ref.IdCountryCurrency = CC.IdCountryCurrency
		join Country Co WITH (NOLOCK) on CC.IdCountry = Co.IdCountry
		join Currency Cu WITH (NOLOCK) on CC.IdCurrency = Cu.IdCurrency
		join Users U WITH (NOLOCK) on ref.EnterByIdUser = U.IdUser
		join Gateway G WITH (NOLOCK) on ref.IdGateway = G.IdGateway
		-- join Payer P on ref.IdPayer = P.IdPayer
		where ref.IdCountryCurrency = @idCountryCurrency 
		and ref.IdPayer is null 
		and ref.Active = 1 
		and ref.IdGateway in (Select distinct IdGateway from PayerConfig WITH(NOLOCK) where IdCountryCurrency = @idCountryCurrency);

		Insert into #Rows
		Select distinct
		0 as IdRefexRate, 1 as Active, '' as DateOfLastChange, 0 as RefExRate, '' as CountryCode, 0 as IdCountry, '' as CountryName, 0 as IdCurrency, '' as CurrencyCode,
		'' as CurrencyName, @idCountryCurrency as IdCountryCurrency, 0 as IdUser, '' as UserName, G.IdGateway, G.Code as GatewayCode, GatewayName, 0 as IdPayer, '' as PayerName, '' as PayerCode
		from Gateway G WITH(NOLOCK)
		join (Select distinct IdGateway from PayerConfig WITH(NOLOCK) where IdCountryCurrency = @idCountryCurrency and IdGateway not in(Select IdGateway from #Rows)) GS
		on G.IdGateway = GS.IdGateway
	end
	else if (@idCountryCurrency >0 and @idGateway > 0)
	begin
		Insert into #Rows
		Select 
		IdRefexRate, Active, ref.DateOfLastChange, RefExRate, CountryCode, CC.IdCountry, CountryName, CC.IdCurrency, CurrencyCode,
		CurrencyName, ref.IdCountryCurrency, ref.EnterByIdUser as IdUser, UserName, ref.IdGateway, G.Code as GatewayCode, GatewayName, ref.IdPayer, PayerName, PayerCode
		from RefExRate ref WITH (NOLOCK)
		join CountryCurrency CC WITH (NOLOCK) on ref.IdCountryCurrency = CC.IdCountryCurrency
		join Country Co WITH (NOLOCK) on CC.IdCountry = Co.IdCountry
		join Currency Cu WITH (NOLOCK) on CC.IdCurrency = Cu.IdCurrency
		join Users U WITH (NOLOCK) on ref.EnterByIdUser = U.IdUser
		join Gateway G WITH (NOLOCK) on ref.IdGateway = G.IdGateway
		join Payer P WITH (NOLOCK) on ref.IdPayer = P.IdPayer
		where ref.IdCountryCurrency = @idCountryCurrency and ref.Active = 1 and ref.IdGateway = @idGateway and ref.IdPayer in (Select distinct IdPayer from PayerConfig WITH(NOLOCK) where IdCountryCurrency = @idCountryCurrency and IdGateway = @idGateway)

		Insert into #Rows
		Select distinct
		0 as IdRefexRate, 1 as Active, '' as DateOfLastChange, 0 as RefExRate, '' as CountryCode, 0 as IdCountry, '' as CountryName, 0 as IdCurrency, '' as CurrencyCode,
		'' as CurrencyName, @idCountryCurrency as IdCountryCurrency, 0 as IdUser, '' as UserName, idGateway as IdGateway, Code as GatewayCode, GatewayName, P.IdPayer,
		PayerName, PayerCode
		from CountryCurrency 
		cross join Gateway WITH (NOLOCK)
		cross join Payer P WITH (NOLOCK)
		join (Select distinct IdPayer from PayerConfig WITH (NOLOCK) where IdCountryCurrency = @idCountryCurrency and IdGateway = @idGateway and IdPayer not in (Select distinct IdPayer from #Rows)) PS
		on P.IdPayer = PS.IdPayer
		where IdGateway = @idGateway
	end 
	else
	begin
		Insert into #Rows
		Select 
		IdRefexRate, Active, ref.DateOfLastChange, RefExRate, CountryCode, CC.IdCountry, CountryName, CC.IdCurrency, CurrencyCode, CurrencyName, ref.IdCountryCurrency, 
		ref.EnterByIdUser as IdUser, UserName, 0 as IdGateway, '' as GatewayCode, '' as GatewayName, 0 as IdPayer, '' as PayerName, '' as PayerCode
		from RefExRate ref WITH (NOLOCK)
		join CountryCurrency CC WITH (NOLOCK) on ref.IdCountryCurrency = CC.IdCountryCurrency
		join Country Co WITH (NOLOCK) on CC.IdCountry = Co.IdCountry
		join Currency Cu WITH (NOLOCK) on CC.IdCurrency = Cu.IdCurrency
		join Users U WITH (NOLOCK) on ref.EnterByIdUser = U.IdUser
		where ref.Active = 1 and ref.IdGateway is null and ref.IdPayer is null
	end

	Insert into #DatosTemp
	Select
	IdRefexRate, 
	Active, 
	ref.DateOfLastChange, 
	RefExRate, 
	CountryCode, 
	CC.IdCountry, 
	CountryName, 
	CC.IdCurrency, 
	CurrencyCode,
	CurrencyName, 
	ref.IdCountryCurrency, 
	ref.EnterByIdUser as IdUser, 
	UserName, 
	isnull(ref.IdGateway, 0) as IdGateway, 
	G.Code as GatewayCode, 
	GatewayName, 
	isnull(ref.IdPayer,0) as IdPayer, 
	isnull(PayerName, '') as PayerName, 
	isnull(PayerCode, '') as PayerCode

	from RefExRate ref WITH (NOLOCK)
	join CountryCurrency CC WITH (NOLOCK) on ref.IdCountryCurrency = CC.IdCountryCurrency
	join Country Co WITH (NOLOCK) on CC.IdCountry = Co.IdCountry
	join Currency Cu WITH (NOLOCK) on CC.IdCurrency = Cu.IdCurrency
	left join Users U WITH (NOLOCK) on ref.EnterByIdUser = U.IdUser
	left join Gateway G WITH (NOLOCK) on ref.IdGateway = G.IdGateway
	left join Payer P WITH (NOLOCK) on ref.IdPayer = P.IdPayer

	Insert into #Rows
	Select * FROM #DatosTemp
	where #DatosTemp.IdGateway in (Select isnull(IdGateway,0) from #Rows)
	and #DatosTemp.Active = 0
	and #DatosTemp.IdPayer in (Select isnull(IdPayer,0) from #Rows)
	and #DatosTemp.IdCountryCurrency in (Select isnull(IdCountryCurrency,0) from #Rows)

	Select * from #Rows
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetRefexRatesActive',Getdate(),@ErrorMessage);
End catch
