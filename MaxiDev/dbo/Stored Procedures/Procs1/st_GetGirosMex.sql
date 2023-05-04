CREATE PROCEDURE [dbo].[st_GetGirosMex]
	-- Add the parameters for the stored procedure here
AS
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="04/04/2019" Author="jdarellano" Name="#1">Se agrega IdPayer=5303 por caso de nuevo pagador creado para que contenga datos faltantes para Girosmex.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--- Get Minutes to wait to be send to service ---                                              
	DECLARE @MinutsToWait INT
	SELECT @MinutsToWait=CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] (NOLOCK) WHERE [Name] = 'TimeFromReadyToAttemp'
	--Set @MinutsToWait=0

	---  Update transfer to Attempt -----------------
	SELECT
		[IdTransfer]
	INTO #temp
	FROM TRANSFER (NOLOCK)
	WHERE
		DATEDIFF(MINUTE,[DateOfTransfer],GETDATE())>@MinutsToWait
		AND [IdGateway] = 24
		AND IdStatus=20

	UPDATE [dbo].[Transfer] SET [IdStatus] = 21, [DateStatusChange] = GETDATE()
		WHERE [IdTransfer] IN (SELECT [IdTransfer] FROM #temp WITH (NOLOCK))

	--------- Tranfer log ---------------------------
	INSERT INTO [dbo].[TransferDetail] ([IdStatus],[IdTransfer],[DateOfMovement])
		SELECT 21,[IdTransfer],GETDATE() FROM #temp

	DECLARE @ClaveCorresponsal NVARCHAR(MAX)
	SELECT @ClaveCorresponsal = [Value] FROM [dbo].[ServiceAttributes] (NOLOCK) WHERE [Code] = 'GIROS_MEX' AND AttributeKey = 'Clave'

	SELECT
		T.[IdPaymentType] TIPO_TRANSACCION
		,CONVERT(NVARCHAR(4), 'NULL') CVE_TRANSACCION
		,@ClaveCorresponsal CLAVE_CORRESPONSAL
		,CONVERT(NVARCHAR(10), FORMAT(T.[DateOfTransfer],'MM/dd/yyyy')) FECHA_MOV
		,CONVERT(NVARCHAR(5), T.[DateOfTransfer], 108) HORA_MOV
		,CONVERT(NVARCHAR(4), 'NULL') TIPO_MOV
		,2 MONEDA_ENVIO -- 2 IS US DOLLARS FOR GIROSMEX
		,CONVERT(NVARCHAR(MAX),T.[AmountInDollars]) MONTO_ENVIO
		,CONVERT(NVARCHAR(MAx),T.[ExRate]) TIPO_CAMBIO
		,CONVERT(NVARCHAR(MAX),T.[Fee]) SERVICIO
		,CASE CU.[IdCurrency] WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END MONEDA_PAGO -- 1 Peso, 2 Dollar
		,CONVERT(NVARCHAR(MAX),T.[AmountInMN]) MONTO_PESOS
		,CASE T.[IdPayer]
			WHEN 980 THEN 8		-- AGENCIAS GIROSMEX
			WHEN 1007 THEN 8		-- AGENCIAS GIROSMEX
			WHEN 1008 THEN 8		-- AGENCIAS GIROSMEX
			WHEN 981 THEN 1		-- BANAMEX
			WHEN 982 THEN 2		-- BANCOMER
			WHEN 983 THEN 3		-- HSBC
			WHEN 984 THEN 4		-- SANTANDER
			WHEN 985 THEN 10	-- BANORTE
			WHEN 986 THEN 11	-- BANRURAL
			WHEN 987 THEN 12	-- SCOTIABANK INVERLAT
			WHEN 988 THEN 18	-- CIBANCO
			WHEN 989 THEN 31	-- BANCO DEL BAJIO
			WHEN 990 THEN 32	-- BANCO MEXICO
			WHEN 991 THEN 33	-- BANCOMEXT
			WHEN 992 THEN 34	-- BANOBRAS
			WHEN 993 THEN 35	-- BANJERCITO
			WHEN 994 THEN 37	-- IXE BANCO
			WHEN 995 THEN 38	-- BANCO INBURSA
			WHEN 996 THEN 44	-- BANCA AFIRME
			WHEN 997 THEN 45	-- MERCANTIL NTE
			WHEN 998 THEN 55	-- BANCO AZTECA
			WHEN 999 THEN 56	-- AUTOFIN MEX
			WHEN 1000 THEN 58	-- FAMSA
			WHEN 1001 THEN 59	-- MULTIVA
			WHEN 1002 THEN 61	-- WAL-MART MEX
			WHEN 1003 THEN 62	-- NAC. FINANCIERA
			WHEN 1004 THEN 64	-- BANCOPPEL
			WHEN 5303 THEN 8		-- AGENCIAS GIROSMEX--#1
			WHEN 5304 THEN 8		-- AGENCIAS GIROSMEX--#1
			ELSE 0 END NO_BANCO
		,CASE T.[IdPaymentType] WHEN 1 THEN '''''' WHEN 2 THEN T.[DepositAccountNumber] ELSE '' END NO_CUENTA
		, 0 NP_PP
		--,ISNULL(CONVERT(INT, B.code),'') NO_SUCURSAL
		,CASE T.[IdPayer]
			WHEN 980 THEN ISNULL(CONVERT(INT, B.code),'')		-- AGENCIAS GIROSMEX
			WHEN 1007 THEN ISNULL(CONVERT(INT, B.code),'')		-- AGENCIAS GIROSMEX
			WHEN 1008 THEN ISNULL(CONVERT(INT, B.code),'')		-- AGENCIAS GIROSMEX
			WHEN 981 THEN '2'		-- BANAMEX
			WHEN 982 THEN '1111'		-- BANCOMER
			WHEN 983 THEN '2449'		-- HSBC
			WHEN 984 THEN '3596'		-- SANTANDER
			WHEN 985 THEN '5980'	-- BANORTE
			WHEN 986 THEN '7980'	-- BANRURAL
			WHEN 987 THEN '17541'	-- SCOTIABANK INVERLAT
			WHEN 988 THEN '24984'	-- CIBANCO
			WHEN 989 THEN '24392'	-- BANCO DEL BAJIO
			WHEN 990 THEN '24985'	-- BANCO MEXICO
			WHEN 991 THEN '24986'	-- BANCOMEXT
			WHEN 992 THEN '24987'	-- BANOBRAS
			WHEN 993 THEN '24988'	-- BANJERCITO
			WHEN 994 THEN '24990'	-- IXE BANCO
			WHEN 995 THEN '24991'	-- BANCO INBURSA
			WHEN 996 THEN '24997'	-- BANCA AFIRME
			WHEN 997 THEN '24998'	-- MERCANTIL NTE
			WHEN 998 THEN '25008'	-- BANCO AZTECA
			WHEN 999 THEN '25009'	-- AUTOFIN MEX
			WHEN 1000 THEN '25011'	-- FAMSA
			WHEN 1001 THEN '25012'	-- MULTIVA
			WHEN 1002 THEN '25014'	-- WAL-MART MEX
			WHEN 1003 THEN '25015'	-- NAC. FINANCIERA
			WHEN 1004 THEN '25017'	-- BANCOPPEL
			WHEN 5303 THEN ISNULL(CONVERT(INT, B.code),'')		-- AGENCIAS GIROSMEX--#1
			WHEN 5304 THEN ISNULL(CONVERT(INT, B.code),'')		-- AGENCIAS GIROSMEX--#1
			ELSE '' END NO_SUCURSAL
		,CONVERT(NVARCHAR(20),T.[CustomerName]) F_NAME_R
		,CONVERT(NVARCHAR(20),T.[CustomerFirstLastName]) L_NAME_R
		,CONVERT(NVARCHAR(20),T.[CustomerSecondLastName]) M_NAME_R
		,CONVERT(NVARCHAR(40),T.[CustomerAddress]) ADDRESS_R
		,REPLACE(REPLACE(REPLACE(dbo.fn_EspecialChrOFF(ISNULL(T.[CustomerPhoneNumber],'')),' ',''),'(',''),')','') PHONE_R
		,CONVERT(NVARCHAR(6),T.[CustomerZipcode]) ZIPCODE_R
		,CONVERT(NVARCHAR(2),T.[CustomerState]) ST_CODE
		,CONVERT(NVARCHAR(50),T.[CustomerCity]) CD_CODE
		,CONVERT(NVARCHAR(20),T.[BeneficiaryName]) NOMBRE_B
		,CONVERT(NVARCHAR(20),T.[BeneficiaryFirstLastName]) APELLIDO_PAT_B
		,CONVERT(NVARCHAR(20),T.[BeneficiarySecondLastName]) APELLIDO_MAT_B
		,CONVERT(NVARCHAR(60),T.[BeneficiaryAddress]) DIRECCION_B
		,REPLACE(REPLACE(REPLACE(dbo.fn_EspecialChrOFF(ISNULL(T.[BeneficiaryPhoneNumber],'')),' ',''),'(',''),')','') TELEFONO_B
		,CONVERT(NVARCHAR(5),T.[BeneficiaryZipcode]) CP_B
		,CASE T.[IdPaymentType]
			WHEN 1 THEN CONVERT(NVARCHAR(3),S.[StateCodeISO3166])
			ELSE 'DIF' END ST_CODE_B
		,CASE T.[IdPaymentType]
			WHEN 1 THEN ISNULL([dbo].[fn_GetGirosMexCityId](CT.[IdCity]),'')
			ELSE '12735' END CD_CODE_B
		,CONVERT(NVARCHAR(30),T.[ClaimCode]) CLAVE_COBRO
	FROM [dbo].[Transfer] T (NOLOCK)
	JOIN [dbo].[CountryCurrency] CC (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
	JOIN [dbo].[Currency] CU (NOLOCK) ON CC.[IdCurrency] = CU.[IdCurrency]
	LEFT JOIN [dbo].[Branch] B (NOLOCK) ON T.[IdBranch] = B.[IdBranch]
	LEFT JOIN [dbo].[City] CT ON B.[IdCity] = CT.[IdCity]
	LEFT JOIN [dbo].[State] S (NOLOCK) ON CT.[IdState] = S.[IdState]
	WHERE
		T.[IdGateway] = 24 -- GIROSMEX
		AND T.[IdStatus] = 21

END
