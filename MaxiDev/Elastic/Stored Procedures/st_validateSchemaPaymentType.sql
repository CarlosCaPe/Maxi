CREATE PROCEDURE [Elastic].[st_validateSchemaPaymentType] (@idPaymentType INT, @SchemaData xml)
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Agent, Elastic Search </app>
<Description> Valida En tiempo real el tipo de pago para el esquema y ciudades </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez"> Creacion</log>
<log Date="23/03/2018" Author="Snevarez"> MA_008: Se añade el tipo de pago ATM(6) </log>
</ChangeLog>

*********************************************************************/
BEGIN 
	DECLARE @XMLTable TABLE (IdGeneric INT IDENTITY, IdAgentSchema int,IdCountry INT , IdState INT, IdCity INT,LocationName VARCHAR(200) )
	DECLARE @Paytypes TABLE (idPaymentType INT )	
		
	
	DECLARE @DocHandle INT 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @SchemaData;
	
	INSERT INTO @XMLTable (IdAgentSchema,idCountry,idState,IdCity,LocationName)
	SELECT IdAgentSchema,idCountry,idState,IdCity,LocationName
	FROM OPENXML (@DocHandle, 'ArrayOfAutoCompleteModel/AutoCompleteModel',2)    
	WITH ( 
	IdAgentSchema int, 
	IdCountry INT,
	IdState INT,  
	IdCity INT,
	LocationName VARCHAR(200) 
	)
	
	
		DECLARE @ini INT, @fin INT , @schema INT,@city INT 
		
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
			
			IF NOT EXISTS (
			SELECT 1
			from AgentSchema A  WITH(NOLOCK)
			JOIN AgentSchemaDetail AD WITH(NOLOCK) on (A.IdAgentSchema=AD.IdAgentSchema)           
			JOIN PayerConfig PC WITH(NOLOCK) on (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency          
			JOIN Payer P WITH(NOLOCK) on (PC.IdPayer=P.IdPayer)     
			LEFT JOIN Branch B WITH(NOLOCK) ON (B.IdPayer = P.IdPayer)
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
			from AgentSchema A  WITH(NOLOCK)        
			JOIN AgentSchemaDetail AD WITH(NOLOCK) on (A.IdAgentSchema=AD.IdAgentSchema)           
			JOIN PayerConfig PC WITH(NOLOCK) on (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency          
	
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
	
	SELECT (SELECT IdAgentSchema, IdCountry, IdState, IdCity,LocationName FROM @XMLTable FOR XML PATH('AutoCompleteModel') , root('ArrayOfAutoCompleteModel') ) AS Result

END 
