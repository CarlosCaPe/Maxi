CREATE FUNCTION [dbo].[fnProductsPermissions]
( @IdUser INT)
RETURNS @ProductsPermissions TABLE 
(
    Id INT,
    OtherProducts  VARCHAR(50),
    IsPermissions BIT
)
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
		
    INSERT INTO @ProductsPermissions (Id, OtherProducts,IsPermissions) 
	   VALUES
			 (0,'Money Transfer',1)
			 ,(1,'Bill Payment', 0)
			 ,(2,'Top Up',0)
			 ,(3,'E-Gift',0)
			 ,(4,'Long Distance',0)
			 ,(5,'Checks',0);
			 
	   /*30/May/2018 - Begin*/
	   IF(NOT EXISTS(Select 1 From AgentUser WITH(NOLOCK) Where IdUser = @IdUser))
	   BEGIN		 
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
	   )

	   /*Obtiene permisos del usuario*/
	   --IdApplication	Name
	   --1	FrontOffice
	   INSERT INTO @OptionUsers (IdOption,IdApplication,IdModule,IdModuloMaster)
		  Select 
			 O.IdOption    
			 ,M.IdApplication
			 ,M.IdModule
			 ,MM.IdModuloMaster
		  From [dbo].[OptionUsers] AS OU WITH(NOLOCK)
			 Inner Join [dbo].[Option] AS O WITH(NOLOCK) On OU.IdOption = O.IdOption
			 Inner Join [dbo].[Modulo] AS M WITH(NOLOCK) On O.IdModule = M.IdModule
			 Inner Join [dbo].[ModuloMaster] AS MM WITH(NOLOCK) On MM.IdModuloMaster = M.IdModuloMaster
			 Inner Join [dbo].[Application] AS A WITH(NOLOCK) On A.IdApplication = M.IdApplication
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

	   /*Se obtiene las opciones de los modulos correspondientes*/
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
	   FROM [dbo].[Option] AS O WITH(NOLOCK)
		  Inner Join [dbo].[Modulo] AS M WITH(NOLOCK) On O.IdModule = M.IdModule
		  Inner Join [dbo].[Application] AS A WITH(NOLOCK) On A.IdApplication = M.IdApplication
	   WHERE M.IdModuloMaster in (1020
							 ,2
							 ,4, 1022
							 ,14,1023
							 ,10)
		  AND M.IdApplication = 1;

	   /*Se evaluan los permisos*/
	   /*QA:21/PROD:1020	Checks Agent*/
	   IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
				    INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster = 1020)
		  )
	   BEGIN
		  UPDATE @ProductsPermissions SET IsPermissions = 1  WHERE OtherProducts = 'Checks';
	   END

	   /*2	Money Transfer Agent*/
	   IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
				    INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (2))
		  )
	   BEGIN
		  UPDATE @ProductsPermissions SET IsPermissions = 1  WHERE OtherProducts = 'Money Transfer';
	   END

	   /*
	   4	Bill Payment Agent 
	   QA:23/PROD:1022	Bill Payment Agent International
	   */
	   IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
				    INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (4,1022))
		  )
	   BEGIN
		  UPDATE @ProductsPermissions SET IsPermissions = 1  WHERE OtherProducts = 'Bill Payment';
	   END

	   /*
	   14	Top UP
	   QA:24/PROD:1023	Regalii Top Up
	   */
	   IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
				    INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (14,1023))
		  )
	   BEGIN
		  UPDATE @ProductsPermissions SET IsPermissions = 1  WHERE OtherProducts = 'Top UP';
	   END

	   /*10	Long Distance*/
	   IF( EXISTS(SELECT 1 FROM @OptionUsers AS OU
				    INNER JOIN @Options AS O ON OU.IdOption = O.IdOption AND OU.IdModuloMaster in (10))
		  )
	   BEGIN
		  UPDATE @ProductsPermissions SET IsPermissions = 1  WHERE OtherProducts = 'Long Distance';
	   END

    RETURN
END






