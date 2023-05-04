
CREATE   procedure [BillPayment].[UpdateBillers]  
  @Billers XML,
    @JsonResponse varchar(max),
	@IdAggregator int,
    @Error varchar(max) output
as  
/********************************************************************
<Author>Alexis Zavala</Author>
<app>External Providers (API)</app>
<Description>Load of billers after downloaded from Aggregators into MAXI structure</Description>

<ChangeLog>
<log Date="21/01/2018" Author="azavala">Creation</log>
<log Date="26/04/2019" Author="azavala">Modificacion de BuyRate solo para FidelityExpress y no modificacion de Name Maxi con NameAggregator de los proveedores para conservar los nombres asignados por maxi :: Ref: 26/04/2019_azavala</log>
<log Date="09/05/2019" Author="azavala">Validacion de msrpFee :: Ref: 090520191700_azavala</log>
<log Date="09/05/2019" Author="azavala">Validacion de ProcessFee :: Ref: 090520191900_azavala</log>
<log Date="13/05/2019" Author="azavala">Validacion de Convert msrpFee con decimales :: Ref: 130520191338_azavala</log>
<log Date="13/05/2019" Author="azavala">Validacion de Isnull isFixedFee sea igual a 0 #1</log>
<log Date="04/06/2019" Author="azavala">Se modifica el proceso para la actualizacion de datos, se valida que choise data no sea null y se activa el proceso para deshabilitar billers que ya no se descarguen desde el servicio del proveedor:: Ref: 040620191446_azavala</log>
<log Date="04/06/2019" Author="azavala">se valida si estatus es 2 colocarlo con estatus 0, si no se deja el estatus en el que esta el biller:: Ref: 040620192307_azavala</log>
<log Date="14/09/2020" Author="esalazar">validacion para actualizacion de status de billers con registro xml. Req:: M00271</log>
<log Date="14/09/2020" Author="esalazar">validacion para lectura de xml por diferencias en campos de FidelityExpress Req:: M00271</log>
<log Date="25/09/2020" Author="jdarellano" Name="#1">Validación por disinto estatus.</log>
<log Date="29/09/2020" Author="esalazar">validacion status 1 o 0 si tiene configuracion o no Req:: M00271</log>
<log Date="07/10/2020" Author="esalazar">Fix temporal para idbillers duplicados de fidelity Req:: M00271</log>
<log Date="2023/01/31" Author="jdarellano">Cambio de tabla para guardar log de actualizazión de billers, según proveedor (BM-800).</log>
<log Date="2023/04/10" Author="jacardenas">Se agrega el @IdAggregator a los logs de errores para identificar el provider que fallo BM-866.</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
	SET NOCOUNT ON;
	
	-- Log: alrededor de 29 000 registros no caben en la columna xml 
	--INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData,[XMl]) VALUES('[BillPayment].[UpdateBillers]', GETDATE(), 'Validacion XML Billers @IdAggregator: '+CONVERT(VARCHAR(MAX), @IdAggregator), CONVERT(NVARCHAR(MAX), @JsonResponse),NULL);
	INSERT INTO MAXILOG.dbo.ChargeBillersLog (MessageLog,IdProvider,LogDate) VALUES ('Update Billers',@IdAggregator,GETDATE());

	TRUNCATE TABLE BILLPAYMENT.BillersTempOct;

	DECLARE @BillersTempFidelity TABLE
	(
		[Name] varchar(MAX)
  		, NameAggregator varchar(MAX)            	            							            		 					 	 						 
		, CutOffTime varchar(MAX)			 
		, IdBillerAggregator int
	 	, BuyRate decimal(18,2)                            
	 	, Category varchar(MAX)
 		, CategoryAggregator varchar(MAX)
	 	, Posting varchar(MAX)
	 	, PostingAggregator varchar(MAX)
	 	, Relationship varchar(MAX)
	 	, IdStatus int
		, choiseData varchar(MAX)
		, idAggregator int
		, cancelAllowed bit
		, billerInstructions varchar(500)
		, isFixedFee bit
		, msrpFee decimal(18,2)
	)

	declare  @DocHandle INT 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Billers

	IF(@IdAggregator<>1) /*M00271 NO Fidelity= lectura normal  */
		BEGIN																																																					
		INSERT INTO @BillersTempFidelity
	(	Name
  		, NameAggregator                	            							            		 					 	 						 
		, CutOffTime							 
		, IdBillerAggregator        
	 	, BuyRate                               
	 	, Category 
 		, CategoryAggregator  
	 	, Posting	 
	 	, PostingAggregator 	
	 	, Relationship
	 	, IdStatus
		, choiseData
		, idAggregator
		, cancelAllowed
		, billerInstructions
		, isFixedFee
		, msrpFee
	 )
	SELECT 
	 biller_name	
	 , biller_name
	 , cutoffTime  
	 , biller_id
   , case when processFee='0' or processFee='' then 0 else Convert(decimal(18,2),processFee) end as processFee -- 090520191900_azavala
   , category
   , category
   , processTime as posting
   , processTime as posting
   , ''
   , 1
   , isnull(choiseData,'') --040620191446_azavala
   , idAggregator
   , cancelAllowed
   , billerInstructions
   , isFixedFee = ISNULL(isFixedFee, 0) --#1
   , case when (msrpFee='0' or msrpFee='' or msrpFee is null) then 0 else Convert(decimal(18,2),(Convert(decimal(18,2),msrpFee)/100)) end as msrpFee -- 090520191700_azavala; 130520191338_azavala
	FROM OPENXML (@DocHandle, '/BillerList/billerInfo',2)
	With (
			biller_name varchar(500),
			cutoffTime 	varchar(500),
			biller_id int,
			processFee varchar(50),
			category varchar(500),
			processTime varchar(500),
			choiseData varchar(MAX),
			idAggregator int,
			cancelAllowed bit,
			billerInstructions varchar(500),
			isFixedFee bit,
			msrpFee varchar(50)
	)
		END
	ELSE
		BEGIN

WITH TempBillersXML AS
(
			SELECT 
			 billerName as Name	
			 ,billerName as NameAggregator
			 ,cutoffTime  as CutOffTime
			 ,billerId as IdBillerAggregator
		   , case when processFee='0' or processFee='' then 0 else Convert(decimal(18,2),processFee) end as BuyRate -- 090520191900_azavala
		   , category as Category
		   , category as CategoryAggregator
		   , processDays as Posting
		   , processDays as PostingAggregator
		   , '' as Relationship
		   , 1 as IdStatus
		   , isnull(choiseData,'') as choiseData --040620191446_azavala
		   , idAggregator
		   , cancelAllowed
		   , billerInstructions
		   , isFixedFee = ISNULL(isFixedFee, 0) --#1
		   , case when (msrpFee='0' or msrpFee='' or msrpFee is null) then 0 else Convert(decimal(18,2),(Convert(decimal(18,2),msrpFee)/100)) end as msrpFee -- 090520191700_azavala; 130520191338_azavala
			,ROW_NUMBER() OVER (PARTITION BY billerId  ORDER BY billerName desc ) AS billerRows 
			FROM OPENXML (@DocHandle, '/BillerList/billerInfo',2)
			With (
					billerName varchar(500),
					cutoffTime 	varchar(500),
					billerId int,
					processFee varchar(50),
					category varchar(500),
					processDays varchar(500),
					choiseData varchar(MAX),
					idAggregator int,
					cancelAllowed bit,
					billerInstructions varchar(500),
					isFixedFee bit,
					msrpFee varchar(50)
			)
)
	

			INSERT INTO @BillersTempFidelity
			(	Name
  				, NameAggregator                	            							            		 					 	 						 
				, CutOffTime							 
				, IdBillerAggregator        
	 			, BuyRate                               
	 			, Category 
 				, CategoryAggregator  
	 			, Posting	 
	 			, PostingAggregator 	
	 			, Relationship
	 			, IdStatus
				, choiseData
				, idAggregator
				, cancelAllowed
				, billerInstructions
				, isFixedFee
				, msrpFee
			 )
			 SELECT 
			 Name
  				, NameAggregator                	            							            		 					 	 						 
				, CutOffTime							 
				, IdBillerAggregator        
	 			, BuyRate                               
	 			, Category 
 				, CategoryAggregator  
	 			, Posting	 
	 			, PostingAggregator 	
	 			, Relationship
	 			, IdStatus
				, choiseData
				, idAggregator
				, cancelAllowed
				, billerInstructions
				, isFixedFee
				, msrpFee
			 FROM TempBillersXML
			 where billerRows = 1
	
		
		
		END
	insert into BILLPAYMENT.BillersTempOct
	select * from @BillersTempFidelity
	--select * from @BillersTempFidelity
	--set @IdAggregator = (select distinct(idAggregator) from @BillersTempFidelity)
	--Select @IdAggregator as IdAggregator
	--select * from BillPayment.Billers   select * from BillPayment.Categorys          select * from BillPayment.Posting                    select * from BillPayment.Billers
	
	MERGE  BillPayment.Billers AS TARGET
	USING @BillersTempFidelity AS SOURCE 
	ON (TARGET.idBillerAggregator = SOURCE.idBillerAggregator and TARGET.IdAggregator=@IdAggregator and TARGET.choiseData=SOURCE.choiseData)--040620191446_azavala
	  
	
	WHEN MATCHED AND TARGET.IdAggregator=SOURCE.idAggregator AND
	(TARGET.NameAggregator <> SOURCE.NameAggregator
	OR TARGET.CutOffTime <> SOURCE.CutOffTime  
	OR TARGET.BuyRate <> SOURCE.BuyRate	  
	OR TARGET.CategoryAggregator <> SOURCE.CategoryAggregator
	OR TARGET.PostingAggregator <> SOURCE.PostingAggregator
	OR TARGET.Category <> SOURCE.CategoryAggregator
	OR TARGET.msrpFee <> SOURCE.msrpFee
	OR TARGET.IdStatus <> SOURCE.IdStatus--#1
	)
	  THEN 
	UPDATE SET 
	/*TARGET.Name = case when @IdAggregator=5 then TARGET.Name else SOURCE.NameAggregator end -- 26/04/2019_azavala
	, */TARGET.NameAggregator= SOURCE.NameAggregator
	, TARGET.CutOffTime = SOURCE.CutOffTime  
	, TARGET.BuyRate = case when @IdAggregator=5 then TARGET.BuyRate else SOURCE.BuyRate end -- 26/04/2019_azavala
	, TARGET.Category = isnull((select top 1 CategoryMaxi from BillPayment.Categorys with (nolock) where  CategoryAggregator = SOURCE.CategoryAggregator), 'Other')
	, TARGET.CategoryAggregator = SOURCE.CategoryAggregator
	, TARGET.PostingAggregator = SOURCE.PostingAggregator   
	, TARGET.Posting = (select top 1 PostingMaxi from BillPayment.Posting with (nolock) where  PostingAggregator = SOURCE.PostingAggregator)
	, TARGET.CancelAllowed = SOURCE.cancelAllowed
	, TARGET.BillerInstructions = SOURCE.BillerInstructions
	, TARGET.IsFixedFee = SOURCE.IsFixedFee
	, TARGET.msrpFee = SOURCE.msrpFee
	, TARGET.IdStatus = 
	CASE WHEN TARGET.IdStatus=0 THEN 0 ELSE
		CASE WHEN @IdAggregator=1  THEN
			CASE
			WHEN 
			EXISTS(select top 1 B.IdBiller from BillPayment.Billers B join BillPayment.AgentForBillers AB on AB.IdBiller =  B.IdBiller where B.IdBillerAggregator = SOURCE.idBillerAggregator AND  B.IdAggregator = SOURCE.IdAggregator AND B.choiseData=SOURCE.choiseData) OR
			EXISTS(select top 1 B.IdBiller from BillPayment.Billers B join BillPayment.StateForBillers SFB on SFB.IdBiller =  B.IdBiller where B.IdBillerAggregator = SOURCE.idBillerAggregator AND  B.IdAggregator = SOURCE.IdAggregator AND B.choiseData=SOURCE.choiseData)
			THEN 1
			ELSE 0	 ---20200929
			END
		ELSE 1
		END
	  END ---M00271 
	
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (Name
	    , NameAggregator   
	    , IdAggregator 
      , Posting 
	    , PostingAggregator 
	    , BuyRate  
	    , Relationship          	            							            		 					 	 						 
			, CutOffTime 
		 	, IdStatus							 
			, IdBillerAggregator
		 	, Category                   
		 	, CategoryAggregator 
		 	, IsDomestic
			, ChoiseData
			, CancelAllowed
			, BillerInstructions
			, IsFixedFee
			, MsrpFee
		 	) 
	VALUES (Source.Name
			, Source.Name 
			, @IdAggregator            
			,  (select top 1 PostingMaxi from BillPayment.Posting with (nolock) where  PostingAggregator = SOURCE.PostingAggregator) 
			, SOURCE.Posting  
			, Source.BuyRate 
			, case when SOURCE.PostingAggregator like '%(NC)' and @IdAggregator=5 THEN 'Non Contracted' else '' end  	            							            		 					 	 						 
			, Source.CutOffTime	 
			, 0			 
			, Source.IdBillerAggregator       
			, (select top 1 CategoryMaxi from BillPayment.Categorys with (nolock) where  CategoryAggregator = Source.CategoryAggregator) 
	 		, Source.CategoryAggregator 
			, 1
			, SOURCE.choiseData
			, SOURCE.cancelAllowed
			, SOURCE.billerInstructions
			, SOURCE.IsFixedFee
			, SOURCE.MsrpFee
		   )
	WHEN NOT MATCHED BY SOURCE and TARGET.IdAggregator=@IdAggregator THEN --040620191446_azavala
	UPDATE SET --040620191446_azavala
	TARGET.IdStatus= 2;--040620191446_azavala

END TRY
BEGIN CATCH
	set @Error = 'Error'
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('BillPayment.UpdateBillers|'+ Convert(varchar,@IdAggregator),GETDATE(),ERROR_MESSAGE() + Convert(varchar(500),ERROR_LINE()))
END CATCH


