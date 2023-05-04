

CREATE procedure [dbo].[st_FindCustomerLight2]
@name varchar(40),
@firstLastName varchar(40), 
@secondLastName varchar(40),
@cellular varchar (15),
@phone varchar(15),
@idAgent int
--idCustomer
as

--------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--------------------------------

set @name = LTRIM(RTRIM(ISNULL(@name,'')))
set @firstLastName = LTRIM(RTRIM(ISNULL(@firstLastName,'')))
set @secondLastName = LTRIM(RTRIM(ISNULL(@secondLastName,'')))
set @cellular = LTRIM(RTRIM(ISNULL(@cellular,'')))
set @phone = LTRIM(RTRIM(ISNULL(@phone,'')))

declare @nameT nvarchar(40),@firstLastNameT nvarchar(40), @secondLastNameT nvarchar(40),@cellularT nvarchar (15),@phoneT nvarchar(15)
set @nameT = '"'+LTRIM(RTRIM(ISNULL(@name,'')))+'*"'
set @firstLastNameT = '"'+LTRIM(RTRIM(ISNULL(@firstLastName,'')))+'*"'
set @secondLastNameT = '"'+LTRIM(RTRIM(ISNULL(@secondLastName,'')))+'*"'
set @cellularT = '"'+LTRIM(RTRIM(ISNULL(@cellular,'')))+'*"'
set @phoneT = '"'+LTRIM(RTRIM(ISNULL(@phone,'')))+'*"'
set @idAgent = case when @idAgent =0 then null else @idAgent end



CREATE TABLE  #customerPivot  (IdCustomer INT)


DECLARE @SQL VARCHAR(max)

SET  @SQL='insert into #customerPivot SELECT [C].[IdCustomer] '
SET @SQL= @SQL +'FROM [dbo].[Customer] [C] (NOLOCK)'
SET @SQL=@SQL +'		WHERE 1 = [C].[IdGenericStatus]'
IF @idAgent IS NOT NULL AND @idAgent > 0 
SET @SQL=@SQL +'	 	AND [C].[IdAgentCreatedBy]='+Convert(VARCHAR(200),@idAgent)+' '
IF @name !=''
SET @SQL=@SQL +'	    AND CONTAINS([C].[Name],'''+@nameT+''') '
IF @firstLastName != ''
SET @SQL=@SQL +'		AND CONTAINS([C].[FirstLastName] ,'''+@firstLastNameT+''')'
IF @secondLastName !=''
SET @SQL=@SQL +'		AND CONTAINS([C].[SecondLastName],'''+@secondLastNameT+''')'
IF @cellular !=''
SET @SQL=@SQL +'		AND CONTAINS([C].[CelullarNumber],'''+@cellularT+''')'
IF @phone !=''
SET @SQL=@SQL +'		AND CONTAINS([C].[PhoneNumber],'''+@phoneT+''')'

SET @SQL = @SQL+ ' OPTION (RECOMPILE)'

EXEC(@SQL)

CREATE UNIQUE CLUSTERED INDEX TMP_PKCustomer ON #customerPivot (idCustomer)


		
SELECT
[Project2].[IdCustomer] AS [IdCustomer], 
[Project2].[Address] AS [Address], 
--[Project2].[BornDate] AS [BornDate], 
[Project2].[CelullarNumber] AS [CelullarNumber], 
[Project2].[City] AS [City], 
--[Project2].[IdAgentCreatedBy] AS [IdAgentCreatedBy], 
[Project2].[FirstLastName] AS [FirstLastName], 
--[Project2].[IdCustomerIdentificationType] AS [IdCustomerIdentificationType], 
[Project2].[Name] AS [Name], 
--[Project2].[IdentificationNumber] AS [IdentificationNumber], 
--[Project2].[Occupation] AS [Occupation], 
[Project2].[PhoneNumber] AS [PhoneNumber], 
[Project2].[SecondLastName] AS [SecondLastName], 
--[Project2].[SSNumber] AS [SSNumber], 
[Project2].[State] AS [State], 
--[Project2].[Zipcode] AS [Zipcode], 
--[Project2].[ExpirationIdentification] AS [ExpirationIdentification], 
--[Project2].[IdCarrier] AS [IdCarrier], 
--[Project2].[IdentificationIdCountry] AS [IdentificationIdCountry], 
--[Project2].[IdentificationIdState] AS [IdentificationIdState], 
[Project2].[CardNumber] AS [CardNumber],
[Project2].[Country] as [Country]
FROM ( 

SELECT 
	[C].[IdCustomer] AS [IdCustomer], 
	[C].[Name] AS [Name], 
	[C].[FirstLastName] AS [FirstLastName], 
	[C].[SecondLastName] AS [SecondLastName], 
	[C].[Address] AS [Address], 
	[C].[City] AS [City], 
	[C].[State] AS [State], 
	[C].[PhoneNumber] AS [PhoneNumber], 
	[C].[CelullarNumber] AS [CelullarNumber], 
	[Limit1].[CardNumber] AS [CardNumber],
	[C].[Country] AS [Country]
	FROM #customerPivot AS [Filter1]
	INNER JOIN Customer AS [C]
	ON [C].idCustomer = [Filter1].idCustomer
	left join  [CardVIP] [Limit1] (NOLOCK) 
	on [Filter1].[IdCustomer] = [Limit1].[IdCustomer] 
	and [Limit1].[IdGenericStatus]=1 
	and [Limit1].IdCardVip=(select max(IdCardVip) from [CardVIP] where idcustomer =[Limit1].[IdCustomer] AND IdGenericStatus=1)
    )  AS [Project2]
ORDER BY [Project2].[Name] ASC, [Project2].[FirstLastName] ASC, [Project2].[SecondLastName] ASC

DROP TABLE #customerPivot
