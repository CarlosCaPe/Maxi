
CREATE procedure [BillPayment].[UpdateBillersFidelityMask]  
   @Billers XML
    , @IdBillerAggregator  int   
    , @Error varchar(max) output
as  

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>inserta y actualiza la mascara para la cuenta de los billers</Description>

<ChangeLog>

<log Date="10/08/2018" Author="amoreno">Creation</log>
<log Date="20/09/2018" Author="azavala">Modificacion de proceso para evitar Error</log>
<log Date="20/09/2018" Author="azavala">Error al ejecutarse por primera vez</log>
</ChangeLog>
*********************************************************************/
--declare @Billers xml,@IdBillerAggregator int,@Error varchar(MAX)
--set @IdBillerAggregator = 6411
--set @Billers = '<?xml version="1.0"?>
--<BillersMask>
--  <BillerMask>
--    <Length>1</Length>
--    <Mask>#</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>0</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>2</Length>
--    <Mask>##</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>00</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>3</Length>
--    <Mask>###</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>000</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>4</Length>
--    <Mask>####</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>0000</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>5</Length>
--    <Mask>#####</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>00000</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>6</Length>
--    <Mask>######</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>000000</OCRPosition>
--  </BillerMask>
--  <BillerMask>
--    <Length>12</Length>
--    <Mask>64830#######</Mask>
--    <checkType>0</checkType>
--    <checkDigits></checkDigits>
--    <OCRPosition>000000000000</OCRPosition>
--  </BillerMask>
--</BillersMask>'
create table #tempMask
(
     idBiller   		int           
    , Length 			nvarchar(100)	 COLLATE SQL_Latin1_General_CP1_CI_AS
    /*, Mask        		nvarchar(100)    COLLATE SQL_Latin1_General_CP1_CI_AS 
    , checkType		 	nvarchar(100)	 COLLATE SQL_Latin1_General_CP1_CI_AS
    , checkDigits  	    nvarchar(100)	 COLLATE SQL_Latin1_General_CP1_CI_AS
    , OCRPosition  	 	nvarchar(100)	 COLLATE SQL_Latin1_General_CP1_CI_AS*/
)
BEGIN TRY
--	--set @Message='' 
--	 set @Error=''
--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('UpdateMask-1', GETDATE(),convert(varchar(MAX),@idBiller))
Set nocount on   

declare  @DocHandle INT 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Billers

declare 
 @idBiller int
 
 

 set 	@idBiller = (select idBiller from BillPayment.Billers  as B with (nolock) where B.IdAggregator=1 and B.IdBillerAggregator=@IdBillerAggregator )
	
	
  INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate,InfoMessage, ExtraData) VALUES('UpdateBillersFidelityMask', GETDATE(), 'Insertando datos duplicados', '@IdBillerAggregator = ' + CONVERT(VARCHAR(50), @IdBillerAggregator) + '@idBiller = ' + CONVERT(VARCHAR(50), @idBiller) + CONVERT(VARCHAR(MAX), @Billers))
	
	
	
	INSERT INTO #tempMask
	( 
		[Length],
		idBiller
	    /*, Mask                	            							            		 					 	 						 
		, checkType							 
		, checkDigits        
	 	, OCRPosition*/

	 )
	SELECT 
	    Distinct ([Length])
		,@idBiller
  	    /*, Mask                	            							            		 					 	 						 
		, checkType							 
		, checkDigits        
	 	, OCRPosition  */
	FROM OPENXML (@DocHandle, '/BillersMask/BillerMask',2)
With (
		 [Length]	   varchar(500)	 COLLATE SQL_Latin1_General_CP1_CI_AS
     	/*, Mask     	   varchar(500)	 COLLATE SQL_Latin1_General_CP1_CI_AS       	            							            		 					 	 						 
		, checkType	   varchar(500)	 COLLATE SQL_Latin1_General_CP1_CI_AS					 
		, checkDigits  varchar(500)	 COLLATE SQL_Latin1_General_CP1_CI_AS    
	 	, OCRPosition  varchar(500)	 COLLATE SQL_Latin1_General_CP1_CI_AS*/
	)

	Delete BillPayment.MaskForBillers where IdBiller=@idBiller and [Length] not in (select [Length] from #tempMask)
	
	--IF((Select count(1) from BillPayment.MaskForBillers with(nolock) where IdBiller=@idBiller)>0)
	IF EXISTS(Select 1 from BillPayment.MaskForBillers with(nolock) where IdBiller=@idBiller)
		begin
			insert into BillPayment.MaskForBillers (IdBiller,[Length])
			select distinct tm.IdBiller, tm.[Length] from #tempMask tm 
			--join BillPayment.MaskForBillers M with(nolock) on M.IdBiller=tm.idBiller and M.[Length]<>tm.[Length]
			WHERE 1 = 1
			AND NOT EXISTS(SELECT 1 FROm BillPayment.MaskForBillers M with(nolock) WHERE M.IdBiller=tm.idBiller and M.[Length]=tm.[Length])
		end
	ELSE
		begin
			insert into BillPayment.MaskForBillers (IdBiller,[Length])
			select distinct tm.IdBiller, tm.[Length] from #tempMask tm
			WHERE 1 = 1
			AND NOT EXISTS(SELECT 1 FROm BillPayment.MaskForBillers M with(nolock) WHERE M.IdBiller=tm.idBiller and M.[Length]=tm.[Length])
		end
	
	--MERGE  BillPayment.MaskForBillers AS TARGET
	--USING   #tempMask AS SOURCE 
	--ON (TARGET.idBiller = SOURCE.idBiller)
	  
	
	--WHEN MATCHED  and 
	--(
	-- TARGET.Length			<> SOURCE.[Length]
	--OR TARGET.Mask			<> SOURCE.Mask  
	--OR TARGET.CheckType		<> SOURCE.checkType	  
	--OR TARGET.CheckDigits	<> SOURCE.checkDigits
	--OR TARGET.OCRPosition	<> SOURCE.OCRPosition 	
	--)
	--  THEN
	--UPDATE SET 
	--TARGET.Length= SOURCE.[Length]
	--, TARGET.Mask = SOURCE.Mask  
	--, TARGET.CheckType = SOURCE.checkType  
	--, TARGET.CheckDigits = SOURCE.checkDigits
	--, TARGET.OCRPosition = SOURCE.OCRPosition  
	--WHEN NOT MATCHED BY TARGET THEN 
	--INSERT (	     
	--     IdBiller
 --       , [Length]  
	--    , Mask   
	--    , CheckType 
 --     , CheckDigits 
	--    , OCRPosition 

	--	 	) 
	--VALUES (
	-- 		   @idBiller
	--            , Source.[Length]   
	--	 	    , Source.Mask            
	--		    , SOURCE.CheckType  
	--		    , SOURCE.CheckDigits  
	--		   	, Source.OCRPosition 	            							            		 					 	 						 	
		 	
	--	   );
		   DROP TABLE #tempMask
End Try
Begin Catch
	set @Error= ERROR_MESSAGE()
	--DROP TABLE #tempMask
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.UpdateBillersFidelityMask',Getdate(),ERROR_MESSAGE())    
End Catch