CREATE PROCEDURE [lunex].[sp_AlertLunexDuplicate]

AS
/********************************************************************
<Author> Fabian Gonzalez</Author>
<app> Job </app>
<Description> Envia alertas sobre transacciones lunex duplicadas </Description>

<ChangeLog>
<log Date="21/07/2017" Author="fgonzalez">Creacion</log>
<log Date="04/07/2019" Author="jhornedo">Add nolock</log>
</ChangeLog>

*********************************************************************/
BEGIN 

DECLARE @StartDate DATETIME ,@recipients VARCHAR(500)
IF (datepart(hour,getDate())  = 10) BEGIN 

SET @StartDate = dateadd(hour,16,Convert(DATETIME, Convert(DATE,dateadd(day,-1,getDate()))))
END ELSE BEGIN 
SET @StartDate = dateadd(hour,10,Convert(DATETIME, Convert(DATE,getDate())))
END 

SELECT ID=IDENTITY(INT,1,1), TransactionID, Total =count(*) 
INTO #tmpDuplicateTrans
FROM Lunex.ServiceLogLunex with (nolock)
WHERE DateLastChange >= @StartDate
AND Response  LIKE '%Transaction already exists%'
GROUP  BY TransactionID


IF EXISTS (SELECT 1 FROM #tmpDuplicateTrans) BEGIN 

	DECLARE @Body VARCHAR(8000) ='Los siguientes envios fueron duplicados entre <b>'+convert(VARCHAR,@StartDate,103)+' '+convert(VARCHAR,@StartDate,108)+'</b> hasta  <b>'+ convert(VARCHAR,getDate(),103)+' '+convert(VARCHAR,getDate(),108)+'</b><br/><br/><table style="font-family:Arial" border="1" cellspacing="0" cellpadding="0" ><tr Style="Background:#009C33; color:#FFF" align="center"><td width="150"><b>Transaction ID</b></td><td width="150"><b># Duplicados</b></td></tr>'
	DECLARE @ini INT,@fin INT , @transactionid INT , @total INT 
	SELECT @ini=1,@fin=count(*) FROM #tmpDuplicateTrans
	WHILE @ini <=@fin BEGIN 
	SELECT @transactionid =TransactionID, @total = total FROM #tmpDuplicateTrans WHERE ID =@ini 
	SET @Body = @Body+'<tr align="center"><td>'+convert(VARCHAR,@transactionid)+'</td><td>'+convert(VARCHAR,@total)+'</td></tr>'
	SET @ini =@ini+1
	END 
	SET @Body = @Body+'</table>'
	
	
	Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailErrorsLunex'  
	
	DECLARE @ProcID VARCHAR(200)
	SET @ProcID =OBJECT_NAME(@@PROCID)
	
	
	EXEC sp_MailQueue 
	@Source   =  @ProcID,
	@To 	  =  @recipients,      
	@Subject  =  'Recargas Lunex duplicadas',
	@Body  	  =  @body,
	@Template =  1

END 

END 