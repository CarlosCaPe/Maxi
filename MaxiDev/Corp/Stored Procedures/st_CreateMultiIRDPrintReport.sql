CREATE PROCEDURE Corp.st_CreateMultiIRDPrintReport
	@CheckImgXml	XML,
	@ReportGUID		NVARCHAR(max) OUTPUT
AS
BEGIN

	DECLARE @DocHandleCheckImg	INT
	--DECLARE @NewGUIDStr 		NVARCHAR(50)
 	DECLARE @NewGUID 			UNIQUEIDENTIFIER
  
 	SELECT @NewGUID = newid()
	
	CREATE TABLE #XmlCheckImg (
		ImgBytes	VARCHAR(max),
		ReportText	VARCHAR(max),
		ImgOrder	INT,
		IsCheckImg	BIT,
		MaxiLine1	NVARCHAR(100),
		MaxiLine2	NVARCHAR(100),
		MaxiLine3	NVARCHAR(100),
		AgentLine1	NVARCHAR(100),
		AgentLine2	NVARCHAR(100),
		AgentLine3	NVARCHAR(100)
			
	)	
	
	EXEC sp_xml_preparedocument @DocHandleCheckImg output, @CheckImgXml	
   
	
	INSERT INTO #XmlCheckImg
	SELECT ImgBytes, ReportText, ImgOrder, IsCheckImg, MaxiLine1, MaxiLine2, MaxiLine3, AgentLine1, AgentLine2, AgentLine3
	FROM OPENXML (@DocHandleCheckImg, '/Main/CheckImages', 2)
	WITH (
		ImgBytes VARCHAR(max),
		ReportText VARCHAR(max),
		ImgOrder	INT,
		IsCheckImg	BIT,
		MaxiLine1	NVARCHAR(100),
		MaxiLine2	NVARCHAR(100),
		MaxiLine3	NVARCHAR(100),
		AgentLine1	NVARCHAR(100),
		AgentLine2	NVARCHAR(100),
		AgentLine3	NVARCHAR(100)		
	)  
	
	SELECT @ReportGUID = convert(NVARCHAR(50), @NewGUID)
	
	INSERT INTO Corp.MultiIRDPrintReport (ReportGUID, ImgBytes, ReportText, ImgOrder, IsCheckImg, MaxiLine1, MaxiLine2, MaxiLine3, AgentLine1, AgentLine2, AgentLine3)
	SELECT @ReportGUID, ImgBytes, ReportText, ImgOrder, IsCheckImg, MaxiLine1, MaxiLine2, MaxiLine3, AgentLine1, AgentLine2, AgentLine3
	FROM #XmlCheckImg
	
	

END	