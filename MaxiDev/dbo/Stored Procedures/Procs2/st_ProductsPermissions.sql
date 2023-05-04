CREATE PROCEDURE [dbo].[st_ProductsPermissions] (@IdUser INT, @ProductType INT, @HasPermissions BIT OUT)
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This function obtains the permissions on specific modules according to the requirement Req_M2An055</Description>

<ChangeLog>
<log Date="18/05/2018" Author="snevarez">Creation of the function </log>
<log Date="30/05/2018" Author="snevarez">Add multiAgent validation </log>
</ChangeLog>
*********************************************************************/
BEGIN
    --DECLARE @HasPermissions BIT = 0;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    /*30/May/2018 - Begin*/
    IF(NOT EXISTS(Select 1 From AgentUser WITH(NOLOCK) Where IdUser = @IdUser))
    BEGIN
	   SET @HasPermissions = 1;
	   RETURN;
    END
    /*30/May/2018 - End*/
	
    DECLARE @OptionUsers TABLE
    (
	   Id INT IDENTITY(1,1),
	   IdOption INT,
	   IdApplication  INT,
	   IdModule INT,
	   IdModuloMaster INT
    );

    --IdApplication	Name
    --1	FrontOffice
    INSERT INTO @OptionUsers (IdOption,IdApplication,IdModule,IdModuloMaster)
	   Select 
		  O.IdOption    
		  ,M.IdApplication
		  ,M.IdModule
		  ,MM.IdModuloMaster
	   From [dbo].[OptionUsers] AS OU
		  Inner Join [dbo].[Option] AS O On OU.IdOption = O.IdOption
		  Inner Join [dbo].[Modulo] AS M On O.IdModule = M.IdModule
		  Inner Join [dbo].[ModuloMaster] AS MM On MM.IdModuloMaster = M.IdModuloMaster
		  Inner Join [dbo].[Application] AS A On A.IdApplication = M.IdApplication
	   Where 
		   M.IdApplication = 1
		   And OU.IdUser = @IdUser;

    DECLARE @Options TABLE
    (
	   Id INT IDENTITY(1,1),
	   IdOption INT,
	   IdApplication  INT,
	   IdModule INT,
	   IdModuloMaster INT
    );

    --IdModuloMaster	Description
    --(QA:21/PROD:1020)	Checks Agent

    --2	Money Transfer Agent

    --4	Bill Payment Agent 
    --(QA:23/PROD:1022)	Bill Payment Agent International

    --14	Top UP
    --(QA:24/PROD:1023)	Regalii Top Up

    --10	Long Distance

    INSERT INTO @Options (IdOption,IdApplication,IdModule,IdModuloMaster)
    SELECT 
    O.IdOption
	   ,M.IdApplication
	   ,M.IdModule	
	   ,M.IdModuloMaster
    FROM [dbo].[Option] AS O
	   Inner Join [dbo].[Modulo] AS M On O.IdModule = M.IdModule
	   Inner Join [dbo].[Application] AS A On A.IdApplication = M.IdApplication
    WHERE M.IdModuloMaster in (1020
					   ,2
					   ,4, 1022
					   ,14,1023
					   ,10)
	   AND M.IdApplication = 1;

    /*2	Money Transfer Agent*/
    IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
			 INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster = 2)
	   AND @ProductType = 0
    )
    BEGIN
	   SET @HasPermissions  = 1;
    END

    /*4	Bill Payment Agent 
	 QA:23/PROD:1022	Bill Payment Agent International*/
    IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
			 INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (4,1022))
	   AND @ProductType = 1
    )
    BEGIN
	   SET @HasPermissions  = 1;
    END

     /*14	Top UP
	  QA:24/PROD:1023	Regalii Top Up*/
    IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
			 INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (14,1023))
	   AND @ProductType = 2
    )
    BEGIN
	   SET @HasPermissions  = 1;
    END

    /*10	Long Distance*/
    IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
			 INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster = 10)
	   AND @ProductType = 4
    )
    BEGIN
	   SET @HasPermissions  = 1;
    END

    /*QA:21/PROD:1020	Checks Agent*/
    IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
			 INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster = 1020)
	   AND @ProductType = 5
    )
    BEGIN
	   SET @HasPermissions  = 1;
    END
END
