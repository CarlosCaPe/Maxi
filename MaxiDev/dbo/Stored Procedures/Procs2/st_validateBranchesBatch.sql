
CREATE PROCEDURE [dbo].[st_validateBranchesBatch] (@idPayer INT , @data xml)
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Corporate </app>
<Description> Valida a un Batch de sucursales y les busca codigo de ubicación </Description>
<SampleCall>@idPayer=5245, @Data='<ArrayOfBranchDataBatchDto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><BranchDataBatchDto> <Zipcode>20135</Zipcode> <IdCity>0</IdCity> <IdState>0</IdState> <IdCountry>0</IdCountry> <DomClose /> <DomOpen>Todo el Dia</DomOpen> <SabClose /> <SabOpen>07:00 - 15:00</SabOpen> <LvClose>19:00</LvClose> <LvOpen>08:00</LvOpen> <Phone>123456789</Phone> <Address>Calle Principal #123 541 Centro.</Address> <CityName>Gutierrez</CityName> <StateName>Chiapas</StateName> <Country>Mexico</Country> <Name>San juan de Calvillo</Name> <Code>000556</Code> </BranchDataBatchDto> </ArrayOfBranchDataBatchDto>'
</SampleCall>

<ChangeLog>
<log Date="13/06/2017" Author="Fgonzalez">Creacion</log>
</ChangeLog>

*********************************************************************/

AS BEGIN

   DECLARE @XMLTable TABLE (idXml INT IDENTITY, Code VARCHAR(100), Name VARCHAR(500),  Country VARCHAR(200), IdCountry INT DEFAULT(0), StateName VARCHAR(200),  IdState INT DEFAULT(0),  CityName VARCHAR(200),  IdCity INT DEFAULT(0), Address VARCHAR(500),  Zipcode VARCHAR(10), Phone VARCHAR(20), LvOpen VARCHAR(20), LvClose VARCHAR(20), SabOpen VARCHAR(20), SabClose VARCHAR(20), DomOpen VARCHAR(20), DomClose VARCHAR(20), idLocation INT, LocationName VARCHAR(200) DEFAULT('') ,Status VARCHAR(100) )
	
   IF (@data IS NOT NULL ) BEGIN 
   
	   	DECLARE @DocHandle INT 
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;
	
		INSERT INTO @XMLTable (	Code,Name, Country,IdCountry,StateName, IdState, CityName, IdCity,Address, Zipcode,Phone,LvOpen,LvClose,SabOpen,SabClose,DomOpen,DomClose)
		SELECT 
		Code,Name, Country,IdCountry,StateName, IdState, CityName, IdCity,Address, Zipcode,Phone,LvOpen,LvClose,SabOpen,SabClose,DomOpen,DomClose
		FROM OPENXML (@DocHandle, 'ArrayOfBranchDataBatchDto/BranchDataBatchDto',2)    
		WITH (    
		Code VARCHAR(100),
		Name VARCHAR(500), 
		Country VARCHAR(200),
		IdCountry INT,
		StateName VARCHAR(200), 
		IdState INT , 
		CityName VARCHAR(200), 
		IdCity INT ,
		Address VARCHAR(500), 
		Zipcode VARCHAR(10),
		Phone VARCHAR(20),
		LvOpen VARCHAR(20),
		LvClose VARCHAR(20),
		SabOpen VARCHAR(20),
		SabClose VARCHAR(20),
		DomOpen VARCHAR(20),
		DomClose VARCHAR(20)
		)
	  WHERE Name !='' AND  Name!='Nombre' AND Name!='Name';
	END 


	DECLARE @ini INT,@fin INT , @name VARCHAR(200) ,@idOut INT 
	SELECT @ini=1,@fin=count(*) FROM @XMLTable
	WHILE @ini <=@fin BEGIN 
	SELECT @name = isnull(CityName,'')+' '+isnull(StateName,'')+' '+isnull(Country,'') FROM @XMLTable WHERE idXml =@ini

	EXECUTE st_findLocationByName @name,0,@idOut OUT 

	UPDATE @XMLTable SET idLocation = @idOut WHERE idXml =@ini 
	SET @ini =@ini+1
	END 
	
	UPDATE Temp
	SET Temp.LocationName = loc.LocationName,
		Temp.IdCountry = loc.idCountry,
		Temp.idState = loc.idState,
		Temp.idCity = loc.idCity,
		Temp.Name = upper(Temp.Name),
		Temp.Address= upper(Temp.Address)
	FROM @XMLTable Temp 
	LEFT JOIN Location loc
	ON loc.idLocation =Temp.idLocation


	UPDATE @XMLTable SET Status='New'	

	UPDATE @XMLTable SET Status='Update' WHERE code IN (
	SELECT code FROM Branch WHERE IdPayer = @idPayer
	)
		
	UPDATE @XMLTable SET Status='No Match', IdCountry=0 , IdState=0, IdCity=0,LocationName='' WHERE idlocation=0
	
	SELECT * FROM @XMLTable
	
	
END 

