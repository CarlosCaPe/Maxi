

CREATE PROCEDURE [dbo].[st_saveBranchesBatch] (@idPayer INT , @IdGateway INT, @EnterByIdUser INT, @data xml, @HasError BIT = 0 OUT,@MessageOUT VARCHAR(200) ='' OUT)
/********************************************************************
<Author> Fgonzalez </Author>
<app> Corporate </app>
<Description>Guarda un Batch de Sucursales para un Pagador y Gateway</Description>

<ChangeLog>
<log Date="14/06/2017" Author="Fgonzalez"> Creacion</log>
</ChangeLog>

*********************************************************************/

AS BEGIN

	DECLARE @LastProcess VARCHAR(200)

	BEGIN TRY
	
	   SELECT @HasError=0, @MessageOUT=''

	   INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_saveBranchesBatch', GETDATE(), 'Validando carga de puntos de pagos, @idPayer: ' + CONVERT(VARCHAR(20), @idPayer) + ', @IdGateway: ' + CONVERT(VARCHAR(20), @IdGateway), CONVERT(VARCHAR(max), @data))
	   
	   SET @LastProcess='reading data from file in database'
	   DECLARE @XMLTable TABLE (idXml INT IDENTITY, Code VARCHAR(100), Name VARCHAR(500),  Country VARCHAR(200), IdCountry INT DEFAULT(0), StateName VARCHAR(200),  IdState INT DEFAULT(0),  CityName VARCHAR(200),  IdCity INT DEFAULT(0), Address VARCHAR(500),  Zipcode VARCHAR(10), Phone VARCHAR(20), LvOpen VARCHAR(20), LvClose VARCHAR(20), SabOpen VARCHAR(20), SabClose VARCHAR(20), DomOpen VARCHAR(20), DomClose VARCHAR(20),Status VARCHAR(100), idBranch INT DEFAULT(0) )
		
	   IF (@data IS NOT NULL ) BEGIN 
	   
		   	DECLARE @DocHandle INT 
			EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;
		
			INSERT INTO @XMLTable ([Status],Code,Name, Country,IdCountry,StateName, IdState, CityName, IdCity,[Address], Zipcode,Phone,LvOpen,LvClose,SabOpen,SabClose,DomOpen,DomClose)
			SELECT 
			[Status],Code,Name, Country,IdCountry,StateName, IdState, CityName, IdCity,[Address], Zipcode,Phone,LvOpen,LvClose,SabOpen,SabClose,DomOpen,DomClose
			FROM OPENXML (@DocHandle, 'ArrayOfBranchDataBatchDto/BranchDataBatchDto',2)    
			WITH ( 
			[Status] VARCHAR(100),   
			Code VARCHAR(100),
			Name VARCHAR(500), 
			Country VARCHAR(200),
			IdCountry INT,
			StateName VARCHAR(200), 
			IdState INT , 
			CityName VARCHAR(200), 
			IdCity INT ,
			[Address] VARCHAR(500), 
			Zipcode VARCHAR(10),
			Phone VARCHAR(20),
			LvOpen VARCHAR(20),
			LvClose VARCHAR(20),
			SabOpen VARCHAR(20),
			SabClose VARCHAR(20),
			DomOpen VARCHAR(20),
			DomClose VARCHAR(20)
			)
		END 
		
		SET @LastProcess ='updating existent branches'
		-- Actualizaciones de información en Branches existentes
		UPDATE b SET 
		b.BranchName = x.Name,
		b.IdCity = x.idCity,
		b.[Address] = x.[Address],
		b.zipcode = x.Zipcode,
		b.Phone = x.Phone,
		b.idGenericStatus=1,
		b.DateOfLastChange = getdate(),
		b.EnterByIdUser = 37,
		b.Schedule = 
			isnull(CASE WHEN nullif(x.LvOpen,'') IS NOT NULL THEN 'L-V '+x.LvOpen END,'')+ 
				isnull(CASE WHEN nullif(x.LvClose,'') IS NOT NULL  THEN ' - '+x.LvClose END,'')+ 
				isnull(CASE WHEN nullif(x.SabOpen,'') IS NOT NULL  THEN ' S '+x.SabOpen END,'')+ 
				isnull(CASE WHEN nullif(x.SabClose,'') IS NOT NULL  THEN '- '+x.SabClose END,'')+ 
				isnull(CASE WHEN nullif(x.DomOpen,'') IS NOT NULL  THEN ' D '+x.DomOpen END,'')+ 
				isnull(CASE WHEN nullif(x.DomClose,'') IS NOT NULL  THEN '- '+x.DomClose END,'')
				  --'L-V 8:00 - 17:00 S 9:00 - 13:00 D'
		FROM Branch b
		JOIN @XMLTable x ON x.code = b.code
		WHERE b.IdPayer =@idPayer
		AND x.[Status] ='Update'
		
		
		
   		--validacion para evitar inserciones dobles
	   SELECT id=IDENTITY(INT,1,1),code, total=count(*) 
	   INTO #repeatedCode
	   FROM @XMLTable x WHERE [Status]='New' 
	   GROUP BY code 
	   HAVING count(*) > 1
	
	
	
		IF EXISTS (SELECT 1 FROM  #repeatedCode) BEGIN 
		  
		  DECLARE @ini INT,@fin INT, @repcode VARCHAR(200), @idXml INT 
		  SELECT @ini=1,@fin=count(*) FROM #repeatedCode 

		  WHILE @ini <=@fin BEGIN 
		  SELECT @repcode =code FROM #repeatedCode WHERE id=@ini
		  SELECT TOP 1 @idXml =idXml FROM @XMLTable WHERE  [Status]='New' AND code= @repcode 
		  DELETE FROM @XMLTable  WHERE  [Status]='New' AND code= @repcode AND idxml != @idXml
		  SET @ini =@ini+1
		  END 	  
		 
		END 	   
		--fin de validacion de inserciones dobles
	   
	   
	   	SET @LastProcess ='creating new branches'
		
		--Se  Insertan en branch solo los que no existan
		INSERT INTO Branch (IdPayer, BranchName, IdCity, [Address], zipcode, Phone, Fax, IdGenericStatus, DateOfLastChange, EnterByIdUser, code, Schedule)
		SELECT DISTINCT	@idPayer, Name, IdCity, [Address], zipcode, Phone, '', 1, getdate(), @EnterByIdUser, code, Schedule = 
			isnull(CASE WHEN nullif(x.LvOpen,'') IS NOT NULL THEN 'L-V '+x.LvOpen END,'')+ 
				isnull(CASE WHEN nullif(x.LvClose,'') IS NOT NULL  THEN ' - '+x.LvClose END,'')+ 
				isnull(CASE WHEN nullif(x.SabOpen,'') IS NOT NULL  THEN ' S '+x.SabOpen END,'')+ 
				isnull(CASE WHEN nullif(x.SabClose,'') IS NOT NULL  THEN '- '+x.SabClose END,'')+ 
				isnull(CASE WHEN nullif(x.DomOpen,'') IS NOT NULL  THEN ' D '+x.DomOpen END,'')+ 
				isnull(CASE WHEN nullif(x.DomClose,'') IS NOT NULL  THEN '- '+x.DomClose END,'')
		FROM @XMLTable x WHERE [Status]='New' 
		AND code NOT IN (SELECT isnull(code,'') FROM Branch WITH(NOLOCK) WHERE idPayer =@idPayer)
		
		
		SET @LastProcess ='getting branch internal id'
		
		--Se obtienen los idBranch Existentes
		--y se asocian a la tabla temporal
		UPDATE X
		SET X.idBranch = b.idBranch
		FROM @XMLTable X
		INNER JOIN Branch b ON b.IdPayer = @idPayer AND b.code = x.Code
		WHERE X.[Status] ='New'
		
		SET @LastProcess ='associating branches and gateways'
		
		--Se insertan los gatewayBranch Faltantes
	    INSERT INTO dbo.GatewayBranch (IdGateway, IdBranch, GatewayBranchCode, DateOfLastChange, EnterByIdUser)
		SELECT @idGateway,IdBranch, Code,getdate(),@EnterByIdUser
		FROM 
		@XMLTable x WHERE [Status]='New' AND idBranch != 0
		AND NOT EXISTS (SELECT 1 FROM GatewayBranch AS gb WITH(NOLOCK) WHERE gb.IdGateway =@idGateway AND gb.IdBranch = x.idBranch)
	
	END TRY  
	BEGIN CATCH 
	  
	   Declare @ErrorMessage nvarchar(max)           
	   Select @ErrorMessage=ERROR_MESSAGE()          
	   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_saveBranchesBatch',Getdate(),@ErrorMessage)   
	  set @HasError =1  
	  set @MessageOUT = 'Error while '+@LastProcess
	    
	END CATCH

END 



	
