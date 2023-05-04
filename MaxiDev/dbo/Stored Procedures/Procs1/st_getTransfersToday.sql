CREATE PROCEDURE [dbo].[st_getTransfersToday]
AS
BEGIN 
DECLARE @today DATETIME =convert(DATE,getDate())

--Se obtienen los que son cancelados y rechazados ese dia
DECLARE @invalid INT 
SELECT @invalid = count(1) 
FROM Transfer WITH (NOLOCK) 
WHERE 
DateStatusChange
BETWEEN  @today AND dateadd(day,1,@today)
AND IdStatus IN (22,31) 

SELECT 
total= count(*) - @invalid,
rate=(SELECT Convert(float,count(*))/10 FROM Transfer  WITH (NOLOCK) WHERE DateOfTransfer >= dateadd(minute,-10,getDate())) 
FROM Transfer WITH (NOLOCK) 
WHERE 
DateOfTransfer BETWEEN  @today AND dateadd(day,1,@today)


END 
