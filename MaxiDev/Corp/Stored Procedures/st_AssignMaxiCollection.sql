CREATE PROCEDURE [Corp].[st_AssignMaxiCollection]
(
    @IdUser 			INT,
    @IdAgents 			XML,
    @IsSpanishLanguage	INT,    
    @HasError 			BIT OUT,
    @MessageOut 		VARCHAR(max) OUT
)
AS

IF @IdUser=0 
    BEGIN
        SET @IdUser = NULL
    END


DECLARE @CurrentDate 	DATETIME
DECLARE @DocHandle 		INT 
DECLARE @IdAssign 		INT
DECLARE @IdAssignTop 	INT
DECLARE @IdAgent 		INT
DECLARE @LastIdAssign	INT


CREATE TABLE #Assign
(
    IdAssign	INT IDENTITY (1,1),
    IdAgent 	INT,
)

SET @CurrentDate=[dbo].[RemoveTimeFromDatetime](getdate())

--Inicializar Variables
SET @HasError=0
--maxi merge
SELECT @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   
--Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,72)   

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@IdAgents 

insert into #Assign
SELECT value From OPENXML (@DocHandle, '/root/value',2) 
    WITH (      
        value INT 'text()'
    )

EXEC sp_xml_removedocument @DocHandle 

--SELECT @IdAssign = 1,@IdAssignTop=MAX(IdAssign) FROM #Assign

WHILE EXISTS (SELECT TOP 1 1 FROM #Assign)
BEGIN
    
    SELECT TOP 1 @IdAgent = IdAgent FROM  #Assign
    
    
    IF EXISTS(SELECT TOP 1 1 FROM MaxiCollectionAssign WHERE IdAgent = @IdAgent) 
    BEGIN 
    	
    	SELECT @LastIdAssign = A.IdMaxiCollectionAssign
    	FROM (
    	
	    	SELECT ROW_NUMBER() OVER (PARTITION BY IdAgent ORDER BY DateOfAssign DESC) AS RowNum, *
	    	FROM MaxiCollectionAssign
	    	WHERE IdAgent = @IdAgent
    	
    	) A
    	WHERE A.RowNum = 1
     
        UPDATE MaxiCollectionAssign SET iduser = @IdUser, DateOfAssign = @CurrentDate
        WHERE IdMaxiCollectionAssign = @LastIdAssign
                   
    END
    ELSE
    BEGIN    
    
        INSERT INTO MaxiCollectionAssign (Idagent,Iduser,DateOfAssign) 
        VALUES (@IdAgent,@IdUser,@CurrentDate)    
        
    END
    
    --select @IdAssign,@IdAgent agent,@IdUser users
	DELETE  #Assign WHERE IdAgent = @IdAgent
end

end try

BEGIN CATCH

 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AssignMaxiCollection',Getdate(),@ErrorMessage) 
    
END CATCH
