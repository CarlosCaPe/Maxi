CREATE Procedure [dbo].[st_FindCustomersById]
--@name varchar(40),
--@firstLastName varchar(40), 
--@secondLastName varchar(40),
--@cellular varchar (15),
--@phone varchar(15),
--@idAgent int
@idCustomer int
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="31/03/2020" Author="bortega">Agregar campos Tax Req:: 00158</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
<log Date="2020/11/20" Author="jcsierra" Name="Occupations"> Se consideran las antiguas ocupaciones FIX CR M00207	</log>
<log Date="2020/12/10" Author="jcsierra" Name="Occupations"> Se eliminan los datos de identificacion en caso que este inactiva	</log>
<log Date="2020/12/10" Author="jcsierra" Name="Occupations"> Se considera Occupation Detail </log>
<log Date="2022/06/16" Author="jdarellano" Name="#1">Se agrega USA como código por default para valores nulos de Dialing.</log>
<log Date="19/09/2022" Author="jcsierra" name="MP-1268">Se corrige la leyenda de recibir SMS's</log>
<log Date="25/10/2022" Author="maprado"  name="MP-1165">Se agrega GlobalAttribute para default en valores nulos de Dialing.</log>
</ChangeLog>
********************************************************************/
--------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--------------------------------

--set @name = LTRIM(RTRIM(ISNULL(@name,'')))
--set @firstLastName = LTRIM(RTRIM(ISNULL(@firstLastName,'')))
--set @secondLastName = LTRIM(RTRIM(ISNULL(@secondLastName,'')))
--set @cellular = LTRIM(RTRIM(ISNULL(@cellular,'')))
--set @phone = LTRIM(RTRIM(ISNULL(@phone,'')))

--declare @nameT nvarchar(40),@firstLastNameT nvarchar(40), @secondLastNameT nvarchar(40),@cellularT nvarchar (15),@phoneT nvarchar(15)
--set @nameT = '%'+LTRIM(RTRIM(ISNULL(@name,'')))+'%'
--set @firstLastNameT = '%'+LTRIM(RTRIM(ISNULL(@firstLastName,'')))+'%'
--set @secondLastNameT = '%'+LTRIM(RTRIM(ISNULL(@secondLastName,'')))+'%'
--set @cellularT = '%'+LTRIM(RTRIM(ISNULL(@cellular,'')))+'%'
--set @phoneT = '%'+LTRIM(RTRIM(ISNULL(@phone,'')))+'%'
--set @idAgent = case when @idAgent =0 then null else @idAgent end

DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

/* MP-1165*/
DECLARE @UsaCode INT = CAST(NULLIF([dbo].[GetGlobalAttributeByName]('UsaCountryCode'),'') AS INT)

SELECT
	[Project2].[IdCustomer] AS [IdCustomer], 
	[Project2].[Address] AS [Address], 
	[Project2].[BornDate] AS [BornDate], 
	[Project2].[CelullarNumber] AS [CelullarNumber], 
	[Project2].[City] AS [City], 
	[Project2].[IdAgentCreatedBy] AS [IdAgentCreatedBy], 
	[Project2].[FirstLastName] AS [FirstLastName], 
	[Project2].[IdCustomerIdentificationType] AS [IdCustomerIdentificationType], 
	[Project2].[Name] AS [Name], 
	[Project2].[IdentificationNumber] AS [IdentificationNumber], 
	[Project2].[Occupation] AS [Occupation], 
	[Project2].[PhoneNumber] AS [PhoneNumber], 
	[Project2].[SecondLastName] AS [SecondLastName], 
	[Project2].[SSNumber] AS [SSNumber], 
	[Project2].[State] AS [State], 
	[Project2].[Zipcode] AS [Zipcode], 
	[Project2].[ExpirationIdentification] AS [ExpirationIdentification], 
	[Project2].[IdCarrier] AS [IdCarrier], 
	[Project2].[IdentificationIdCountry] AS [IdentificationIdCountry], 
	[Project2].[IdentificationIdState] AS [IdentificationIdState], 
	[Project2].[CardNumber] AS [CardNumber],
	[Project2].[Country] as [Country],
	[Project2].[IdCountryOfBirth] AS [IdCountryOfBirth],
	[Project2].[ReceiveSms] AS [ReceiveSms],
	[Project2].[OccupationDetail] AS [OccupationDetail],	 /*S44:REQ. MA.025*/
	[Project2].[IdTypeTax] AS [IdTypeTax],	--Req:: 00158
	[Project2].[IdTaxDupli] AS [IdTaxDupli],  --Req:: 00158
	--[Project2].[IdOccupation] AS [IdOccupation],    /* M00207*/
	--[Project2].[IdSubcategoryOccupation] AS [IdSubcategoryOccupation],    /* M00207*/
	--[Project2].[SubcategoryOccupationOther] AS [SubcategoryOccupationOther]   /* M00207*/


	CASE 
		WHEN ISNULL([Project2].Occupation, '') <> '' AND ISNULL([Project2].[IdOccupation], 0) = 0 THEN 10
		ELSE [Project2].[IdOccupation]
	END [IdOccupation],

	CASE 
		WHEN ISNULL([Project2].Occupation, '') <> '' AND ISNULL([Project2].[IdSubcategoryOccupation], 0) = 0 THEN 16
		ELSE [Project2].[IdSubcategoryOccupation]
	END [IdSubcategoryOccupation],

	CASE 
		WHEN ISNULL([Project2].Occupation, '') <> '' AND ISNULL([Project2].[IdOccupation], 0) = 0 AND ISNULL([Project2].[IdSubcategoryOccupation], 0) = 0 THEN 
			CASE 
				WHEN [Project2].Occupation IN ('--OTHER--', '--OTRA--') THEN [Project2].OccupationDetail
				ELSE [Project2].Occupation 
			END
		ELSE [Project2].[SubcategoryOccupationOther]
	END [SubcategoryOccupationOther],
	[Project2].[IdDialingCodePhoneNumber] AS [IdDialingCodePhoneNumber] 
FROM ( 

	SELECT 
	[Filter1].[IdCustomer] AS [IdCustomer], 
	[Filter1].[IdAgentCreatedBy] AS [IdAgentCreatedBy], 
	[Filter1].[IdCustomerIdentificationType] AS [IdCustomerIdentificationType], 
	[Filter1].[Name] AS [Name], 
	[Filter1].[FirstLastName] AS [FirstLastName], 
	[Filter1].[SecondLastName] AS [SecondLastName], 
	[Filter1].[Address] AS [Address], 
	[Filter1].[City] AS [City], 
	[Filter1].[State] AS [State], 
	[Filter1].[Zipcode] AS [Zipcode], 
	[Filter1].[PhoneNumber] AS [PhoneNumber], 
	[Filter1].[CelullarNumber] AS [CelullarNumber], 
	[Filter1].[SSNumber] AS [SSNumber], 
	[Filter1].[BornDate] AS [BornDate], 
	[Filter1].[Occupation] AS [Occupation], 
	[Filter1].[IdentificationNumber] AS [IdentificationNumber], 
	[Filter1].[ExpirationIdentification] AS [ExpirationIdentification], 
	[Filter1].[IdCarrier] AS [IdCarrier], 
	[Filter1].[IdentificationIdCountry] AS [IdentificationIdCountry], 
	[Filter1].[IdentificationIdState] AS [IdentificationIdState], 
	[Limit1].[CardNumber] AS [CardNumber],
	[Filter1].[Country] AS [Country],
	[Filter1].[IdCountryOfBirth] AS [IdCountryOfBirth],
	[Filter1].[ReceiveSms] AS [ReceiveSms]
	,[Filter1].[OccupationDetail] AS [OccupationDetail],	/*S44:REQ. MA.025*/
	[Filter1].[IdTypeTax] AS [IdTypeTax],		--Req:: 00158
	[Filter1].[IdTaxDupli] AS [IdTaxDupli],		--Req:: 00158
	[Filter1].[IdOccupation] AS [IdOccupation],    /* M00207*/
	[Filter1].[IdSubcategoryOccupation] AS [IdSubcategoryOccupation],    /* M00207*/
	[Filter1].[SubcategoryOccupationOther] AS [SubcategoryOccupationOther],   /* M00207*/
	[Filter1].[IdDialingCodePhoneNumber] AS [IdDialingCodePhoneNumber]
	FROM (
			SELECT TOP 1
			       [C].[IdCustomer] AS [IdCustomer], 
				   [C].[IdAgentCreatedBy] AS [IdAgentCreatedBy], 
				   [C].[IdCustomerIdentificationType] AS [IdCustomerIdentificationType], 
				   [C].[Name] AS [Name], [C].[FirstLastName] AS [FirstLastName], 
				   [C].[SecondLastName] AS [SecondLastName], 
				   [C].[Address] AS [Address], 
				   [C].[City] AS [City], 
				   [C].[State] AS [State], 
				   [C].[Zipcode] AS [Zipcode], 
				   [C].[PhoneNumber] AS [PhoneNumber], 
				   [C].[CelullarNumber] AS [CelullarNumber], 
				   [C].[SSNumber] AS [SSNumber], 
				   [C].[BornDate] AS [BornDate], 
				   [C].[Occupation] AS [Occupation], 
				   [C].[IdentificationNumber] AS [IdentificationNumber], 
				   [C].[ExpirationIdentification] AS [ExpirationIdentification], 
				   [C].[IdCarrier] AS [IdCarrier], 
				   [C].[IdentificationIdCountry] AS [IdentificationIdCountry], 
				   [C].[IdentificationIdState] AS [IdentificationIdState], 
				   [C].[Country] AS [Country], 
				   [C].[IdCountryOfBirth] AS [IdCountryOfBirth], 
				   ISNULL([CN].[AllowSentMessages],0) [ReceiveSms],
				   [C].[OccupationDetail], [C].[IdTypeTax] AS [IdTypeTax], 
				   [C].[IdTaxDupli] AS [IdTaxDupli],
				   [C].[IdOccupation] AS [IdOccupation],
				   [C].[IdSubcategoryOccupation] AS [IdSubcategoryOccupation],
				   [C].[SubcategoryOccupationOther] AS [SubcategoryOccupationOther],
				   ISNULL([C].[IdDialingCodePhoneNumber],@UsaCode) AS [IdDialingCodePhoneNumber]--#1
			  FROM [dbo].[Customer] [C] (NOLOCK)
			  -- LEFT JOIN [Infinite].[CellularNumber] [CN] WITH (NOLOCK) ON [C].[CelullarNumber] = [CN].[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode -- - #MP-1268
				LEFT JOIN DialingCodePhoneNumber dc WITH (NOLOCK) ON dc.IdDialingCodePhoneNumber = c.IdDialingCodePhoneNumber -- + #MP-1268
				LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON [C].[CelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = ISNULL(dc.Prefix, @InterCode) -- + #MP-1268
			  WHERE [C].[IdCustomer] = @idCustomer
				

			--WHERE (1 = [C].[IdGenericStatus]) and (@idAgent is null or [C].[IdAgentCreatedBy]=@idAgent) and (@name='' or [C].[Name] like @nameT) and (@firstLastName='' or [C].[FirstLastName] like @firstLastNameT) and (@secondLastName='' or [C].[SecondLastName] like @secondLastNameT) 
			--		and (@cellular='' or [C].[CelullarNumber] like @cellularT) and (@phone='' or [C].[PhoneNumber] like @phoneT)  
		)AS [Filter1]
	left join  
    [CardVIP] [Limit1] (NOLOCK) on [Filter1].[IdCustomer] = [Limit1].[IdCustomer] and [Limit1].[IdGenericStatus]=1 and [Limit1].IdCardVip=(select max(IdCardVip) from [CardVIP] where idcustomer =[Limit1].[IdCustomer])
    /*(
			SELECT TOP (1) [Extent2].[IdCustomer], [Extent2].[CardNumber] AS [CardNumber]
			FROM [dbo].[CardVIP] AS [Extent2]
			WHERE (1 = [Extent2].[IdGenericStatus]) 
	) AS [Limit1] on [Filter1].[IdCustomer] = [Limit1].[IdCustomer]*/
)  AS [Project2]
ORDER BY [Project2].[Name] ASC, [Project2].[FirstLastName] ASC, [Project2].[SecondLastName] ASC



