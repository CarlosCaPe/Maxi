CREATE procedure [Corp].[st_FilterByStatus]
(                    
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @IdAgent int = NULL,
    @IdStatus int = NULL,
    @IdPayer int = NULL,
    @IdGateway int = NULL,
    @IdCountry int = NULL,
    @ClaimCode nvarchar(max) = NULL,
    @Folio int = NULL,
    @CustomerFirstLastName nvarchar(max) = NULL,
    @BeneficiaryFirstLastName nvarchar(max) = NULL,
    @IdCustomer int = NULL,
    @CardNumber varchar(20) = NULL,
	@IdPaymentMethod INT = NULL,
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
<log Date="28/09/2017" Author="amoreno">Add fild AgentState</log>
<log Date="10/05/2018" Author="snevarez">Case to ClaimCode for TrasnferTo(TTApi)</log>
<log Date="12/12/2018" Author="jmolina">Add with Nolock in queries</log>
<log Date="12/09/2019" Author="erojas">Join the TransactionUploadFile table and use its columns(nolock)</log> identifier -> /*MOBILE*/
<log Date="16/02/2023" Author="jfresendiz">BM-664 Retornar dirección y teléfono del punto de pago</log>
<log Date="03/01/2022" Author="jcsierra">Add IdPaymentMethod parameters</log>
</ChangeLog>
*********************************************************************/
            
Set nocount on              
                           
              
Begin Try              
            
Declare @SQL nvarchar(max),@SQL2 nvarchar(max)            
Declare @SQLCount nvarchar(max),@SQLCount2 nvarchar(max)            
Declare @Total int            
            
Create table #Result            
(Total int)            
            
Set @EndDate=DATEADD(dd, 1, @EndDate)               
            
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate)            
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)            
            
                
Set @SQL='                    
Select          
B.IdAgent,
B.AgentState,        
A.IdTransfer,  
A.IdStatus,                  
/*A.ClaimCode,*/
CASE WHEN Api.Serial IS NULL THEN A.ClaimCode ELSE A.ClaimCode + ''_'' + CONVERT(VARCHAR(12),Api.Serial) END AS ClaimCode, /*10/05/2018*/
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
tuf.IdTransfer as IdTransferMobile, /*MOBILE*/
tuf.FolderName as FolderNameMobile, /*MOBILE*/
tuf.FileName as FileNameMobile,     /*MOBILE*/
tuf.FileType as FileTypeMobile     /*MOBILE*/
,case when tuf.FileName is not null then 1 else 0 end IsMobile /*MOBILE*/
,CASE WHEN BRT.IdTransfer IS NULL THEN 0 ELSE 1 END HasComplianceFormat,
A.IdPaymentMethod,
pm.PaymentMethod,
B.AgentAddress,
B.AgentPhone
From Transfer AS A WITH(NOLOCK)                
inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
inner Join Status AS C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                
inner Join Payer AS D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                
inner Join PaymentType AS E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                
inner Join CountryCurrency AS F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)                
inner Join Country AS G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)            
inner Join TransferDetail AS H WITH(NOLOCK) on (A.IdTransfer=H.IdTransfer)
JOIN PaymentMethod pm WITH(NOLOCK) ON pm.IdPaymentMethod = A.IdPaymentMethod
LEFT JOIN TTApiSerial AS Api WITH(NOLOCK) On A.IdTransfer = Api.IdTransfer /*10/05/2018*/
LEFT JOIN (
	SELECT BR.[IdTransfer] FROM [dbo].[BrokenRulesByTransfer] AS BR WITH(NOLOCK) 
		INNER JOIN [dbo].[ComplianceFormat] AS CF WITH(NOLOCK) ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE LTRIM(ISNULL(CF.[FileOfName],'''')) != ''''
	GROUP BY BR.[IdTransfer]
   ) BRT ON A.[IdTransfer] = BRT.[IdTransfer]
LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on (A.IdTransfer=tuf.IdTransfer)  /*MOBILE*/                
Where H.IdStatus='+Convert(varchar(max),@IdStatus)+ ' And  '  

IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
SET @SQL = @SQL + ' H.DateOfMovement>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  H.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
IF @Folio IS NOT NULL
SET @SQL = @SQL + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 

--H.DateOfMovement>='+Char(39)+Convert(varchar(max),@StartDate)+Char(39)+' And  H.DateOfMovement<'+Char(39)+Convert(varchar(max),@EndDate)+Char(39)+' And                 
--H.IdStatus='+Convert(varchar(max),@IdStatus)+ ' And  '            
            
Set @SQLCount='            
Select                  
Count(1) as Total            
From Transfer AS A WITH(NOLOCK) 
LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on (A.IdTransfer=tuf.IdTransfer)  /*MOBILE*/     
inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
inner Join Status AS C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                
inner Join Payer AS D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                
inner Join PaymentType AS E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)  
inner Join CountryCurrency AS F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)                
inner Join Country AS G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)            
inner Join TransferDetail AS H WITH(NOLOCK) on (A.IdTransfer=H.IdTransfer)                
Where H.IdStatus='+Convert(varchar(max),@IdStatus)+ ' And  '            

IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
SET @SQLCount = @SQLCount + ' H.DateOfMovement>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  H.DateOfMovement<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
IF @Folio IS NOT NULL
SET @SQLCount = @SQLCount + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND ' 
            
            
            
Set @SQL2='                    
Select     
B.IdAgent, 
B.AgentState,            
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
a.idcountry,
tuf.IdTransfer as IdTransferMobile, /*MOBILE*/
tuf.FolderName as FolderNameMobile, /*MOBILE*/
tuf.FileName as FileNameMobile,     /*MOBILE*/
tuf.FileType as FileTypeMobile     /*MOBILE*/
,case when tuf.FileName is not null then 1 else 0 end IsMobile /*MOBILE*/
,CASE WHEN BRT.IdTransfer IS NULL THEN 0 ELSE 1 END HasComplianceFormat,
A.IdPaymentMethod,
pm.PaymentMethod,
B.AgentAddress,
B.AgentPhone
From TransferClosed AS A WITH(NOLOCK) 
inner Join Agent AS B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                
inner Join TransferClosedDetail AS C WITH(NOLOCK) on (C.IdTransferClosed=A.IdTransferClosed)
JOIN PaymentMethod pm WITH(NOLOCK) ON pm.IdPaymentMethod = A.IdPaymentMethod
LEFT JOIN (
	SELECT BR.[IdTransfer] FROM [dbo].[BrokenRulesByTransfer] AS BR WITH(NOLOCK) 
		INNER JOIN [dbo].[ComplianceFormat] AS CF WITH(NOLOCK) ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE LTRIM(ISNULL(CF.[FileOfName],'''')) != ''''
	GROUP BY BR.[IdTransfer]
   ) BRT ON A.[IdTransferClosed] = BRT.[IdTransfer]
   LEFT JOIN TransactionUploadFile tuf WITH(NOLOCK) on (A.IdTransferClosed=tuf.IdTransfer)  /*MOBILE*/ 
Where C.IdStatus='+Convert(varchar(max),@IdStatus)+ ' And  '            
               
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
Where C.IdStatus='+Convert(varchar(max),@IdStatus)+ ' And  '              

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

IF @IdPaymentMethod IS NOT NULL                            
BEGIN                            
	SET @SQL=@SQL+'A.IdPaymentMethod='+CONVERT(VARCHAR(MAX), @IdPaymentMethod)+' AND '
	SET @SQLCount=@SQLCount+'A.IdPaymentMethod='+CONVERT(VARCHAR(MAX), @IdPaymentMethod)+' AND '
	SET @SQL2=@SQL2+'A.IdPaymentMethod='+CONVERT(VARCHAR(MAX), @IdPaymentMethod)+' AND '
	SET @SQLCount2=@SQLCount2+'A.IdPaymentMethod='+CONVERT(VARCHAR(MAX), @IdPaymentMethod)+' AND '
END  
                      
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
  
                      
                 
Set @SQL=@SQL+' 1=1   Union '+@SQL2+ ' 1=1 '             
Set @SQLCount=@SQLCount+' 1=1   Union '+@SQLCount2+ ' 1=1 '                

--print @SQL                
             
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
 Set @HasError=1                                                
 Declare @ErrorMessage nvarchar(max)                                                 
 Select @ErrorMessage=ERROR_MESSAGE()                                                
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_FilterByStatus',Getdate(),@ErrorMessage)                                                
End Catch




