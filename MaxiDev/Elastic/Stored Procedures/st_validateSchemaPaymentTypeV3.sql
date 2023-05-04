CREATE PROCEDURE [Elastic].[st_validateSchemaPaymentTypeV3] (@idPaymentType INT, @SchemaData xml)
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Agent, Elastic Search </app>
<Description> Valida En tiempo real el tipo de pago para el esquema y ciudades </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez"> Creacion</log>
<log Date="23/03/2018" Author="Snevarez"> MA_008: Se añade el tipo de pago ATM(6) </log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
</ChangeLog>

*********************************************************************/
BEGIN 
	DECLARE @XMLTable TABLE (IdGeneric INT IDENTITY, IdAgentSchema int,IdCountry INT , IdState INT, IdCity INT, cityName VARCHAR(100)/*azavala_29112019*/, stateName VARCHAR(100)/*azavala_29112019*/, LocationName VARCHAR(200) )
	DECLARE @Paytypes TABLE (idPaymentType INT )	
		
	
	DECLARE @DocHandle INT 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @SchemaData;
	
	INSERT INTO @XMLTable (IdAgentSchema,idCountry,idState,IdCity,cityName/*azavala_29112019*/, stateName/*azavala_29112019*/, LocationName)
	SELECT IdAgentSchema,idCountry,idState,IdCity, cityName/*azavala_29112019*/, stateName/*azavala_29112019*/, LocationName
	FROM OPENXML (@DocHandle, 'ArrayOfAutoCompleteDemoDto/AutoCompleteDemoDto',2)    
	WITH ( 
	IdAgentSchema int, 
	IdCountry INT,
	IdState INT,  
	IdCity INT,
	cityName VARCHAR(100),/*azavala_29112019*/
	stateName VARCHAR(100),/*azavala_29112019*/
	LocationName VARCHAR(200) 
	)
	
	
		DECLARE @ini INT, @fin INT , @schema INT,@city INT, @TestCityName varchar(max)--**
		
		IF @idPaymentType NOT IN (2,5,6)  /*MA_008*/
		BEGIN
	
			INSERT INTO @Paytypes VALUES (@idPaymentType)
			IF @idPaymentType = 1  
			INSERT INTO @Paytypes VALUES (4)
			IF @idPaymentType = 4  
			INSERT INTO @Paytypes VALUES (1)
			
			SELECT @ini=1,@fin=count(*) FROM @XMLTable		
			WHILE @ini <=@fin BEGIN 

			SELECT @schema= idAgentSchema, @city=idCity FROM @XMLTable WHERE idgeneric=@ini
			select @TestCityName=cityName from @XMLTable where IdGeneric=@ini
			if (UPPER(@TestCityName)='TLALPAN')
			begin
				insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage,ExtraData,[XML]) 
                values('[Elastic].[st_validateSchemaPaymentTypeV2]',GETDATE(),
				'IdAgentSchema: '+CAST(@schema as varchar)+', IdCity: '+CAST(@city as varchar)+', CityName: '+CAST(@TestCityName as varchar),NULL,@SchemaData)

			end
			IF NOT EXISTS (
			SELECT 1
			from AgentSchema A         
			JOIN AgentSchemaDetail AD on (A.IdAgentSchema=AD.IdAgentSchema)           
			JOIN PayerConfig PC on (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency          
			JOIN Payer P on (PC.IdPayer=P.IdPayer)     
			LEFT JOIN Branch B ON (B.IdPayer = P.IdPayer)
			WHERE 
			PC.IdPaymentType IN ( SELECT idPaymentType FROM  @Paytypes)
			AND A.IdGenericStatus =1
			AND PC.IdGenericStatus =1
			AND P.IdGenericStatus =1
			AND (B.IdGenericStatus =1 or (B.IdGenericStatus is null and PC.RequireBranch =0))
			AND A.IdAgentSchema = @schema
			AND B.IdCity = @city
			)
			DELETE FROM @XMLTable WHERE idGeneric = @ini 
			
			
			SET @ini =@ini+1
			END 
		END 
		ELSE 
		BEGIN 
	
			SELECT @ini=1,@fin=count(*) FROM @XMLTable
			
			WHILE @ini <=@fin BEGIN 
			
			SELECT @schema= idAgentSchema, @city=idCity FROM @XMLTable WHERE idgeneric=@ini
			IF NOT EXISTS (
			SELECT 1
			from AgentSchema A         
			JOIN AgentSchemaDetail AD on (A.IdAgentSchema=AD.IdAgentSchema)           
			JOIN PayerConfig PC on (AD.IdPayerConfig=PC.IdPayerConfig) --AND A.IdCountryCurrency =PC.IdCountryCurrency          
	
			WHERE 
			PC.IdPaymentType  = @idPaymentType
			AND A.IdGenericStatus =1
			AND PC.IdGenericStatus =1
			AND A.IdAgentSchema = @schema
			)
			
		   	DELETE FROM @XMLTable WHERE idGeneric = @ini 
			SET @ini =@ini+1
			END 
	
	END 
	
	SELECT (SELECT IdAgentSchema, IdCountry, IdState, IdCity, cityName/*azavala_29112019*/, stateName/*azavala_29112019*/, LocationName FROM @XMLTable ORDER BY IdGeneric ASC FOR XML PATH('AutoCompleteDemoDto') , root('ArrayOfAutoCompleteDemoDto') ) AS Result

END 
