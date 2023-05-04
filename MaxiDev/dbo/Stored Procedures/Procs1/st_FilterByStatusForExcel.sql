CREATE procedure [dbo].[st_FilterByStatusForExcel]                    
(                    
@StartDate datetime = NULL,                          
@EndDate datetime = NULL,                      
@IdAgent int,                      
@IdStatus int,                      
@IdPayer int,                      
@IdGateway int,                      
@IdCountry int,                       
@ClaimCode nvarchar(max),                      
@Folio int = NULL,                      
@CustomerFirstLastName nvarchar(max),                      
@BeneficiaryFirstLastName nvarchar(max),                      
@IdCustomer int,     
@CardNumber varchar(20),    
@HasError bit output,            
@Message nvarchar(max) output               
)                    
AS             
/********************************************************************
<Author>Known</Author>
<app>MaxiCorp</app>
<Description>Search Transfer</Description>

<ChangeLog>
<log Date="27/01/2017" Author="mdelgado">Make not required dates fields when search by Folio</log>
<log Date="10/02/2017" Author="fgonzalez">Correction in search date filters</log>
</ChangeLog>
*********************************************************************/

	--DECLARE @StartDate datetime = '20160101'
	--DECLARE @EndDate datetime = '20170201'
	----DECLARE @StartDate datetime = NULL
	----DECLARE @EndDate datetime = NULL
	--DECLARE @IdAgent int = 6031
	--DECLARE @IdStatus int = NULL
	--DECLARE @IdPayer int = NULL
	--DECLARE @IdGateway int = NULL
	--DECLARE @IdCountry int = NULL
	--DECLARE @ClaimCode nVARCHAR(MAX) = NULL
	--DECLARE @Folio int = 677
	--DECLARE @CustomerFirstLastName nVARCHAR(MAX) = NULL
	--DECLARE @BeneficiaryFirstLastName nVARCHAR(MAX) = NULL
	--DECLARE @IdCustomer int = NULL
	--DECLARE @CardNumber VARCHAR(20) = NULL
	--DECLARE @HasError bit
	--DECLARE @Message nVARCHAR(MAX)
	
	SET NOCOUNT ON			   
	
	BEGIN TRY
            
	Declare @SQL Nvarchar(max),@SQL2 nvarchar(max)            
	Declare @SQLCount nvarchar(max),@SQLCount2 nvarchar(max)            
	Declare @Total int            
       
	        
	Create table #Result
	(Total int)            
	
	IF @EndDate IS NOT NULL            
		Set @EndDate=DATEADD(dd, 1, @EndDate)               

	            
	Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate)            
	Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)            
            
	                
	SET @SQL = 'Select B.IdAgent, A.IdTransfer, A.IdStatus, A.ClaimCode, A.DateOfTransfer, B.AgentCode, 
			B.AgentName, 
			A.Folio, 
			A.CustomerName+ '' ''+ A.CustomerFirstLastName + '' ''+ A.CustomerSecondLastName as CustomerName,
			A.BeneficiaryName+ '' ''+ A.BeneficiaryFirstLastName+ '' ''+ A.BeneficiarySecondLastName as BeneficiaryName, 
			D.PayerName,
			E.PaymentName as PaymentTypeName,
			G.CountryName,
			A.AmountInDollars,
			C.StatusName,
			I.GatewayName,
			A.AmountInMN,
			J.CurrencyName,
			A.DateStatusChange 
		From Transfer AS A WITH(NOLOCK) 
			inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
			inner Join Status AS C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                
			inner Join Payer AS D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                
			inner Join PaymentType AS E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                
			inner Join CountryCurrency AS F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)
			inner Join Country AS G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)            
			inner Join TransferDetail AS H WITH(NOLOCK) on (A.IdTransfer=H.IdTransfer)
			inner Join Gateway AS I WITH(NOLOCK) on (I.IdGateway=A.IdGateway)
			inner Join Currency AS J WITH(NOLOCK) on (J.IdCurrency=F.IdCurrency)
		WHERE '
		IF @IdStatus IS NOT NULL
			SET @SQL = @SQL + ' H.IdStatus = ' + Convert(varchar(max),@IdStatus) + ' AND  '
		
		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQL = @SQL + ' H.DateOfMovement >='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  H.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
		
		IF @Folio IS NOT NULL
				SET @SQL = @SQL + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND '			

        

		SET @SQLCount='            
			Select                  
				Count(1) as Total            
			From Transfer AS A WITH(NOLOCK) 
				inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
				inner Join Status AS C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                
				inner Join Payer AS D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                
				inner Join PaymentType AS E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                
				inner Join CountryCurrency AS F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)                
				inner Join Country AS G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)            
				inner Join TransferDetail AS H WITH(NOLOCK) on (A.IdTransfer=H.IdTransfer)                
			Where '
			IF @IdStatus IS NOT NULL
				SET @SQLCount = @SQLCount+ ' H.IdStatus = ' + Convert(varchar(max),@IdStatus) + ' AND  '

		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQLCount = @SQLCount + ' H.DateOfMovement>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  H.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
		IF @Folio IS NOT NULL
			SET @SQLCount = @SQLCount + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 
            
            
            
		SET @SQL2='                    
			SELECT     
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
				A.StatusName,
				A.GatewayName,
				A.AmountInMN,
				A.CurrencyName,
				A.DateStatusChange                
			From TransferClosed AS A WITH(NOLOCK) 
				inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
				inner Join TransferClosedDetail AS C WITH(NOLOCK) on (C.IdTransferClosed=A.IdTransferClosed)            
			Where '
		
		IF @IdStatus IS NOT NULL
			SET @SQL2 = @SQL2 + ' C.IdStatus = ' + Convert(varchar(max),@IdStatus) + ' AND  '				
               
		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQL2 = @SQL2 + ' C.DateOfMovement>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  C.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
		IF @Folio IS NOT NULL
			SET @SQL2 = @SQL2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 
            
		Set @SQLCount2='            
		Select            
			Count(1) as Total               
		From TransferClosed AS A WITH(NOLOCK) 
			inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
			inner Join TransferClosedDetail AS C WITH(NOLOCK) on (C.IdTransferClosed=A.IdTransferClosed)            
		Where 			'

		IF @IdStatus IS NOT NULL
			SET @SQLCount2 = @SQLCount2 + ' C.IdStatus = ' + Convert(varchar(max),@IdStatus) + ' AND  '
			

		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQLCount2 = @SQLCount2 + ' C.DateOfMovement>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  C.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
		IF @Folio IS NOT NULL
			SET @SQLCount2 = @SQLCount2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 
                
                      
If @IdAgent is not null                      
Begin                      
 Set @SQL=@SQL+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '             
 Set @SQLCount=@SQLCount+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '             
              
 Set @SQL2=@SQL2+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                      
 Set @SQLCount2=@SQLCount2+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                      
             
End                      
                    
                      
If @IdPayer is not null                      
Begin                      
 Set @SQL=@SQL+'A.IdPayer='+Convert(varchar(max),@IdPayer)+' And '             
 Set @SQLCount=@SQLCount+'A.IdPayer='+Convert(varchar(max),@IdPayer)+' And '                      
                      
 Set @SQL2=@SQL2+'A.IdPayer='+Convert(varchar(max),@IdPayer)+' And '            
 Set @SQLCount2=@SQLCount2+'A.IdPayer='+Convert(varchar(max),@IdPayer)+' And '                                
End                      
                      
If @IdGateway is not null                      
Begin                      
 Set @SQL=@SQL+'A.IdGateway='+Convert(varchar(max),@IdGateway)+' And '            
 Set @SQLCount=@SQLCount+'A.IdGateway='+Convert(varchar(max),@IdGateway)+' And '                      
                       
 Set @SQL2=@SQL2+'A.IdGateway='+Convert(varchar(max),@IdGateway)+' And '            
 Set @SQLCount2=@SQLCount2+'A.IdGateway='+Convert(varchar(max),@IdGateway)+' And '                       
End                      
                      
                      
If @IdCountry is not null                      
Begin                      
 Set @SQL=@SQL+'F.IdCountry='+Convert(varchar(max),@IdCountry)+' And '            
 Set @SQLCount=@SQLCount+'F.IdCountry='+Convert(varchar(max),@IdCountry)+' And '             
                                
 Set @SQL2=@SQL2+'A.IdCountry='+Convert(varchar(max),@IdCountry)+' And '            
 Set @SQLCount2=@SQLCount2+'A.IdCountry='+Convert(varchar(max),@IdCountry)+' And '                                
End                      
                      
                      
If @ClaimCode is not null                      
Begin                      
 Set @SQL=@SQL+'A.ClaimCode='+char(39)+@ClaimCode+CHAR(39)+' And '            
 Set @SQLCount=@SQLCount+'A.ClaimCode='+char(39)+@ClaimCode+CHAR(39)+' And '            
                       
 Set @SQL2=@SQL2+'A.ClaimCode='+char(39)+@ClaimCode+CHAR(39)+' And '             
 Set @SQLCount2=@SQLCount2+'A.ClaimCode='+char(39)+@ClaimCode+CHAR(39)+' And '                               
End                      
                               
If @CustomerFirstLastName is not null                      
Begin                      
 Set @SQL=@SQL+'A.CustomerFirstLastName='+char(39)+@CustomerFirstLastName+CHAR(39)+' And '            
 Set @SQLCount=@SQLCount+'A.CustomerFirstLastName='+char(39)+@CustomerFirstLastName+CHAR(39)+' And '             
                       
 Set @SQL2=@SQL2+'A.CustomerFirstLastName='+char(39)+@CustomerFirstLastName+CHAR(39)+' And '            
 Set @SQLCount2=@SQLCount2+'A.CustomerFirstLastName='+char(39)+@CustomerFirstLastName+CHAR(39)+' And '                      
End                       
                       
If @BeneficiaryFirstLastName is not null                      
Begin                      
 Set @SQL=@SQL+'A.BeneficiaryFirstLastName='+char(39)+@BeneficiaryFirstLastName+CHAR(39)+' And '            
 Set @SQLCount=@SQLCount+'A.BeneficiaryFirstLastName='+char(39)+@BeneficiaryFirstLastName+CHAR(39)+' And '             
                       
 Set @SQL2=@SQL2+'A.BeneficiaryFirstLastName='+char(39)+@BeneficiaryFirstLastName+CHAR(39)+' And '            
 Set @SQLCount2=@SQLCount2+'A.BeneficiaryFirstLastName='+char(39)+@BeneficiaryFirstLastName+CHAR(39)+' And '                      
End                       
                      
                      
If @IdCustomer is not null                      
Begin                      
 Set @SQL=@SQL+'A.IdCustomer='+Convert(varchar(max),@IdCustomer)+' And '            
 Set @SQLCount=@SQLCount+'A.IdCustomer='+Convert(varchar(max),@IdCustomer)+' And '            
                       
 Set @SQL2=@SQL2+'A.IdCustomer='+Convert(varchar(max),@IdCustomer)+' And '            
 Set @SQLCount2=@SQLCount2+'A.IdCustomer='+Convert(varchar(max),@IdCustomer)+' And '                      
End  
  
  
If @CardNumber is not null                              
Begin                              
 Set @SQL=@SQL+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK) where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '  
 Set @SQLCount=@SQLCount+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK) where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                  
                               
 Set @SQL2=@SQL2+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK) where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                  
 Set @SQLCount2=@SQLCount2+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK) where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                             
End    
  
                      
                 
Set @SQL = @SQL+' 1=1   Union '+ @SQL2 + ' 1=1 '             
Set @SQLCount = @SQLCount + ' 1 = 1   Union ' + @SQLCount2+ ' 1 = 1 '                


Print @SQL
Print @SQLCount
             
Insert into #Result             
Exec (@SQLCount)               
            
Select @Total=SUM(Total) from #Result            
            
 If @Total =0             
Begin            
   Select @Message =dbo.GetMessageFromLenguajeResorces (0,36)             
   Set @HasError=1          
   Return            
End            
            
            
If @Total < 3000             
Begin            
   Select @Message =dbo.GetMessageFromLenguajeResorces (0,35)             
   Set @HasError=0            
   Exec (@SQL)            
End            
Else             
Begin            
    Select @Message =dbo.GetMessageFromLenguajeResorces (0,34)             
 Set @HasError=1            
End                   
              
End Try                                                
Begin Catch   
	PRINT 'ERROR'
 Set @HasError = 1                                                
 Declare @ErrorMessage nvarchar(max)                                                 
 Select @ErrorMessage=ERROR_MESSAGE()
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_FilterByStatusForExcel',Getdate(),@ErrorMessage)                                                
End Catch 


DROP TABLE #Result

