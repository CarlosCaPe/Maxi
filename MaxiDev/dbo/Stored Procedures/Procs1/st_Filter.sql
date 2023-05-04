CREATE procedure [dbo].[st_Filter]
(                                
	@StartDate datetime = NULL,
	@EndDate datetime = NULL,
	@IdAgent int = NULL,
	@IdStatus int = NULL,
	@IdPayer int = NULL,
	@IdGateway int = NULL,
	@IdCountry int = NULL,
	@ClaimCode nVARCHAR(MAX) = NULL,
	@Folio int = NULL,
	@CustomerFirstLastName nVARCHAR(MAX) = NULL,
	@BeneficiaryFirstLastName nVARCHAR(MAX) = NULL,
	@IdCustomer int = NULL,
	@CardNumber VARCHAR(20) = NULL,
	@HasError bit output,
	@Message nVARCHAR(MAX) output
)
AS
/********************************************************************
<Author>Known</Author>
<app>MaxiCorp</app>
<Description>Search Transfer</Description>

<ChangeLog>
<log Date="27/01/2017" Author="mdelgado">Make not required dates fields when search by Folio</log>
<log Date="28/09/2017" Author="amoreno">Add fild AgentState</log>
<log Date="10/05/2018" Author="snevarez">Case to ClaimCode for TrasnferTo(TTApi)</log>
<log Date="17/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="12/09/2019" Author="erojas">Join the TransactionUploadFile table and use its columns(nolock)</log> identifier -> /*MOBILE*/
</ChangeLog>

*********************************************************************/

	--DECLARE @StartDate datetime = '20160210'
	--DECLARE @EndDate datetime = '20170210'
	----DECLARE @StartDate datetime = NULL
	----DECLARE @EndDate datetime = NULL
	--DECLARE @IdAgent int = 6031
	--DECLARE @IdStatus int = 9
	--DECLARE @IdPayer int = NULL
	--DECLARE @IdGateway int = NULL
	--DECLARE @IdCountry int = NULL
	--DECLARE @ClaimCode nVARCHAR(MAX) = NULL
	--DECLARE @Folio int = NULL
	--DECLARE @CustomerFirstLastName nVARCHAR(MAX) = NULL
	--DECLARE @BeneficiaryFirstLastName nVARCHAR(MAX) = NULL
	--DECLARE @IdCustomer int = NULL
	--DECLARE @CardNumber VARCHAR(20) = NULL
	--DECLARE @HasError bit
	--DECLARE @Message nVARCHAR(MAX)


	SET NOCOUNT ON
              
	BEGIN TRY
                      
		DECLARE @SQL nVARCHAR(MAX),@SQL2 nVARCHAR(MAX)                  
		DECLARE @SQLCount nVARCHAR(MAX),@SQLCount2 nVARCHAR(MAX)                  
		DECLARE @Total int                  
         
		DECLARE @IsHold bit
		DECLARE @IdStatusTemp int 

		IF @EndDate IS NOT NULL
			SET @EndDate = DATEADD(dd, 1, @EndDate)

		SELECT @EndDate = dbo.RemoveTimeFromDatetime(@EndDate)                        
		SELECT @StartDate = dbo.RemoveTimeFromDatetime(@StartDate)                  
             
			      
		CREATE TABLE #Result                  
		(Total INT)                  
        
		                    
		SET @SQL = '                    
			SELECT  ' + CASE WHEN @Folio IS NOT NULL THEN ' TOP 1500 ' ELSE '' END + '
				B.IdAgent,      
				A.IdTransfer,                                   
				A.IdStatus,      
				/*A.ClaimCode,*/
				CASE WHEN Api.Serial IS NULL THEN A.ClaimCode ELSE A.ClaimCode + ''_'' + CONVERT(VARCHAR(12),Api.Serial) END AS ClaimCode,/*10/05/2018*/
				A.DateOfTransfer,                            
				B.AgentCode,                            
				B.AgentName,                            
				A.Folio,                            
				A.CustomerName+ '' ''+ A.CustomerFirstLastName + '' ''+ A.CustomerSecondLastName as CustomerName,                            
				A.BeneficiaryName+ '' ''+ A.BeneficiaryFirstLastName+ '' ''+ A.BeneficiarySecondLastName as BeneficiaryName,                            
				D.PayerName,                            
				E.PaymentName as PaymentTypeName,                            
				G.CountryName,                            
				A.AmountInDollars,                            
				C.StatusName,
				f.idcountry,
				tuf.FolderName as FolderNameMobile, /*MOBILE*/
				tuf.FileName as FileNameMobile,     /*MOBILE*/
				tuf.FileType as FileTypeMobile     /*MOBILE*/
				,case when tuf.FileName is not null then 1 else 0 end IsMobile, /*MOBILE*/
				CASE WHEN BRT.IdTransfer IS NULL THEN 0 ELSE 1 END HasComplianceFormat
				,B.AgentState
			FROM Transfer A WITH(NOLOCK)
				JOIN Agent B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                            
				JOIN Status C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                            
				JOIN Payer D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                            
				JOIN PaymentType E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                            
				JOIN CountryCurrency F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)                            
				JOIN Country G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)
				LEFT JOIN TTApiSerial AS Api  WITH(NOLOCK)  On A.IdTransfer = Api.IdTransfer /*10/05/2018*/
				LEFT JOIN TransferHolds H  WITH(NOLOCK)  on (H.IdTransfer=A.IdTransfer)
				LEFT JOIN (
					SELECT BR.[IdTransfer] FROM [dbo].[BrokenRulesByTransfer] BR  WITH(NOLOCK) 
						JOIN [dbo].[ComplianceFormat] CF  WITH(NOLOCK)  ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
					WHERE LTRIM(ISNULL(CF.[FileOfName],'''')) != ''''
					GROUP BY BR.[IdTransfer]
				   ) BRT ON A.[IdTransfer] = BRT.[IdTransfer]
				/*MOBILE*/
				LEFT JOIN (SELECT MAX(IdTransactionUploadFile) IdTransactionUploadFile, IdTransfer FROM TransactionUploadFile GROUP BY IdTransfer) lastUF ON lastUF.IdTransfer = A.IdTransfer
				LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on tuf.IdTransactionUploadFile = lastUF.IdTransactionUploadFile
			WHERE '
			IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
				SET @SQL = @SQL + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
			IF @Folio IS NOT NULL
				SET @SQL = @SQL + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 

		

		SET @SQLCount= '
			SELECT Count(1) as Total
			FROM Transfer A WITH(NOLOCK) 
				LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on (A.IdTransfer=tuf.IdTransfer)  /*MOBILE*/ 
				JOIN Agent B WITH(NOLOCK)  on (A.IdAgent=B.IdAgent)                            
				JOIN Status C WITH(NOLOCK)  on (A.IdStatus=C.IdStatus)                            
				JOIN Payer D WITH(NOLOCK)  on (A.IdPayer=D.IdPayer)                            
				JOIN PaymentType E WITH(NOLOCK)  on (E.IdPaymentType=A.IdPaymentType)                            
				JOIN CountryCurrency F WITH(NOLOCK)  on (F.IdCountryCurrency=A.IdCountryCurrency)                            
				JOIN Country G WITH(NOLOCK)  on (G.IdCountry=F.IdCountry)   
				LEFT JOIN TransferHolds H WITH(NOLOCK)  on (H.IdTransfer=A.IdTransfer)
				                 
			WHERE '

			IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
				SET @SQLCount = @SQLCount + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
			IF @Folio IS NOT NULL
				SET @SQLCount = @SQLCount + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 

		
                            
		SET @SQL2 = '                                
			SELECT ' + CASE WHEN @Folio IS NOT NULL THEN ' TOP 1500 ' ELSE '' END + '
				B.IdAgent, 				             
				A.IdTransferClosed as IdTransfer,       
				A.IdStatus,                             
				A.ClaimCode,              
				A.DateOfTransfer,                            
				B.AgentCode,                            
				B.AgentName,                            
				A.Folio,                            
				A.CustomerName+ '' ''+ A.CustomerFirstLastName+ '' ''+ A.CustomerSecondLastName as CustomerName,                            
				A.BeneficiaryName+ '' ''+ A.BeneficiaryFirstLastName+ '' ''+ A.BeneficiarySecondLastName  as BeneficiaryName,                            
				A.PayerName,                            
				A.PaymentTypeName,                            
				A.CountryName,                            
				A.AmountInDollars,                            
				A.StatusName  ,
				a.idcountry,
				tuf.FolderName as FolderNameMobile, /*MOBILE*/
				tuf.FileName as FileNameMobile,     /*MOBILE*/
				tuf.FileType as FileTypeMobile     /*MOBILE*/
				,case when tuf.FileName is not null then 1 else 0 end IsMobile /*MOBILE*/
				,CASE WHEN BRT.IdTransfer IS NULL THEN 0 ELSE 1 END HasComplianceFormat
				,B.AgentState
			FROM TransferClosed A WITH(NOLOCK)                               
				JOIN Agent B WITH(NOLOCK)  on (A.IdAgent=B.IdAgent)  
			LEFT JOIN (
				SELECT BR.[IdTransfer] FROM [dbo].[BrokenRulesByTransfer] BR  WITH(NOLOCK) 
					JOIN [dbo].[ComplianceFormat] CF  WITH(NOLOCK)  ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
				WHERE LTRIM(ISNULL(CF.[FileOfName],'''')) != ''''
				GROUP BY BR.[IdTransfer]
			   ) BRT ON A.[IdTransferClosed] = BRT.[IdTransfer]
			   /*MOBILE*/
				LEFT JOIN (SELECT MAX(IdTransactionUploadFile) IdTransactionUploadFile, IdTransfer FROM TransactionUploadFile GROUP BY IdTransfer) lastUF ON lastUF.IdTransfer = A.IdTransferClosed
				LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on tuf.IdTransactionUploadFile = lastUF.IdTransactionUploadFile
			WHERE '

		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQL2 = @SQL2 + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
		IF @Folio IS NOT NULL
			SET @SQL2 = @SQL2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 

		SET @SQLCount2 = '
			SELECT                              
				Count(1) as Total                      
			FROM TransferClosed A                            
				JOIN Agent B on (A.IdAgent=B.IdAgent)                            
			WHERE '

		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQLCount2 = @SQLCount2 + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                  
			
		IF @Folio IS NOT NULL
			SET @SQLCount2 = @SQLCount2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 

		IF @IdAgent IS NOT NULL
		BEGIN                            
			SET @SQL=@SQL+'A.IdAgent='+CONVERT(VARCHAR(MAX),@IdAgent)+' AND '                   
			SET @SQLCount=@SQLCount+'A.IdAgent='+CONVERT(VARCHAR(MAX),@IdAgent)+' AND '                   
                    
			SET @SQL2=@SQL2+'A.IdAgent='+CONVERT(VARCHAR(MAX),@IdAgent)+' AND '                            
			SET @SQLCount2=@SQLCount2+'A.IdAgent='+CONVERT(VARCHAR(MAX),@IdAgent)+' AND '                            
		END                            
                     
		IF @IdStatus IS NOT NULL                            
		BEGIN 
			-- Si el IdStatus es un hold es necesario verificar que sea un Hold y que en la tabla de detalle tenga un detalle con ese Hold y sin rejected ni release

			SET @IsHold= (SELECT CanChangeToAgingHold from Status where IdStatus=@IdStatus)
			IF(@IsHold=1)                           
			BEGIN 
				SET @IdStatusTemp= 41 -- Verify Hold
				SET @SQL= @SQL +'H.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatus)+' AND H.IsReleased is null AND '    
				SET @SQLCount= @SQLCount +'H.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatus)+' AND H.IsReleased is null AND '    
			END
			ELSE 
			BEGIN 
				SET @IdStatusTemp= @IdStatus
			END
	
			SET @SQL=@SQL+'A.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatusTemp)+' AND '                  
			SET @SQLCount=@SQLCount+'A.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatusTemp)+' AND '                  
                             
			SET @SQL2=@SQL2+'A.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatus)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.IdStatus='+CONVERT(VARCHAR(MAX),@IdStatus)+' AND '                                      
		END                            
                            
		IF @IdPayer IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.IdPayer='+CONVERT(VARCHAR(MAX),@IdPayer)+' AND '
			SET @SQLCount=@SQLCount+'A.IdPayer='+CONVERT(VARCHAR(MAX),@IdPayer)+' AND '
			SET @SQL2=@SQL2+'A.IdPayer='+CONVERT(VARCHAR(MAX),@IdPayer)+' AND '
			SET @SQLCount2=@SQLCount2+'A.IdPayer='+CONVERT(VARCHAR(MAX),@IdPayer)+' AND '
		END                            
                            
		IF @IdGateway IS NOT NULL                        
		BEGIN                            
			SET @SQL=@SQL+'A.IdGateway='+CONVERT(VARCHAR(MAX),@IdGateway)+' AND '                  
			SET @SQLCount=@SQLCount+'A.IdGateway='+CONVERT(VARCHAR(MAX),@IdGateway)+' AND '                                                        
			SET @SQL2=@SQL2+'A.IdGateway='+CONVERT(VARCHAR(MAX),@IdGateway)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.IdGateway='+CONVERT(VARCHAR(MAX),@IdGateway)+' AND '                             
		END                            
                                                
		IF @IdCountry IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'F.IdCountry='+CONVERT(VARCHAR(MAX),@IdCountry)+' AND '                  
			SET @SQLCount=@SQLCount+'F.IdCountry='+CONVERT(VARCHAR(MAX),@IdCountry)+' AND '                   
			SET @SQL2=@SQL2+'A.IdCountry='+CONVERT(VARCHAR(MAX),@IdCountry)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.IdCountry='+CONVERT(VARCHAR(MAX),@IdCountry)+' AND '                                      
		END                            
                            
		IF @ClaimCode IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.ClaimCode='+CHAR(39)+@ClaimCode+CHAR(39)+' AND '                  
			SET @SQLCount=@SQLCount+'A.ClaimCode='+CHAR(39)+@ClaimCode+CHAR(39)+' AND '                  
			SET @SQL2=@SQL2+'A.ClaimCode='+CHAR(39)+@ClaimCode+CHAR(39)+' AND '                   
			SET @SQLCount2=@SQLCount2+'A.ClaimCode='+CHAR(39)+@ClaimCode+CHAR(39)+' AND '                            
		END
                     
		IF @CustomerFirstLastName IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.CustomerFirstLastName='+CHAR(39)+@CustomerFirstLastName+CHAR(39)+' AND '                
			SET @SQLCount=@SQLCount+'A.CustomerFirstLastName='+CHAR(39)+@CustomerFirstLastName+CHAR(39)+' AND '                                                
			SET @SQL2=@SQL2+'A.CustomerFirstLastName='+CHAR(39)+@CustomerFirstLastName+CHAR(39)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.CustomerFirstLastName='+CHAR(39)+@CustomerFirstLastName+CHAR(39)+' AND '                            
		END                             
                             
		IF @BeneficiaryFirstLastName IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.BeneficiaryFirstLastName='+CHAR(39)+@BeneficiaryFirstLastName+CHAR(39)+' AND '                  
			SET @SQLCount=@SQLCount+'A.BeneficiaryFirstLastName='+CHAR(39)+@BeneficiaryFirstLastName+CHAR(39)+' AND '                   
			SET @SQL2=@SQL2+'A.BeneficiaryFirstLastName='+CHAR(39)+@BeneficiaryFirstLastName+CHAR(39)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.BeneficiaryFirstLastName='+CHAR(39)+@BeneficiaryFirstLastName+CHAR(39)+' AND '                            
		END                             

		IF @IdCustomer IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.IdCustomer='+CONVERT(VARCHAR(MAX),@IdCustomer)+' AND '                  
			SET @SQLCount=@SQLCount+'A.IdCustomer='+CONVERT(VARCHAR(MAX),@IdCustomer)+' AND '                  
			SET @SQL2=@SQL2+'A.IdCustomer='+CONVERT(VARCHAR(MAX),@IdCustomer)+' AND '                  
			SET @SQLCount2=@SQLCount2+'A.IdCustomer='+CONVERT(VARCHAR(MAX),@IdCustomer)+' AND '                            
		END                            
   
		IF @CardNumber IS NOT NULL                            
		BEGIN                            
			SET @SQL=@SQL+'A.IdCustomer in (SELECT IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1 AND CardNumber='+CHAR(39)+@CardNumber+CHAR(39)+')'+' AND '
			SET @SQLCount=@SQLCount+'A.IdCustomer in (SELECT IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1 AND CardNumber='+CHAR(39)+@CardNumber+CHAR(39)+')'+' AND '                
                             
			SET @SQL2=@SQL2+'A.IdCustomer in (SELECT IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1 AND CardNumber='+CHAR(39)+@CardNumber+CHAR(39)+')'+' AND '                
			SET @SQLCount2=@SQLCount2+'A.IdCustomer in (SELECT IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1 AND CardNumber='+CHAR(39)+@CardNumber+CHAR(39)+')'+' AND '                           
		END

		SET @SQL = @SQL + ' 1 = 1  Union '+ @SQL2 + ' 1 = 1 order by A.DateOfTransfer desc'                   
		SET @SQLCount = @SQLCount+' 1 = 1   '+@SQLCount2+ ' 1 = 1 '
		
		SELECT @SQL
	
		INSERT INTO #Result                   
			Exec (@SQLCount)                     
                  
		SELECT @Total = SUM(Total) from #Result                  

		IF @Total = 0                   
		BEGIN                  
		   SELECT @Message =  dbo.GetMessageFromLenguajeResorces (0,36)                   
		   SET @HasError = 1
		   PRINT @Message                
		   RETURN                  
		END

		IF @Total < 3000                   
		BEGIN                  
			SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,35)                   
			SET @HasError = 0
			PRINT @Message
			EXEC (@SQL)                  
		END                  
		ELSE                   
		BEGIN                  
			SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,34)
			PRINT @Message                   
			SET @HasError=1
		END                         
                    
	END TRY
	                                                      
	BEGIN CATCH
		SET @HasError = 1
		DECLARE @ErrorMessage NVARCHAR(MAX)                                                       
		SELECT @ErrorMessage=ERROR_MESSAGE()           
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_Filter',Getdate(),@ErrorMessage)                                                      
		PRINT ERROR_MESSAGE()
		DROP TABLE #Result
    END CATCH
	--DROP TABLE #Result



