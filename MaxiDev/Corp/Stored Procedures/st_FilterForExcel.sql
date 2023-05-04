CREATE procedure [Corp].[st_FilterForExcel]                                
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

	Set nocount on                     
                     
Begin Try                        
                      
Declare @SQL nvarchar(max),@SQL2 nvarchar(max)                  
Declare @SQLCount nvarchar(max),@SQLCount2 nvarchar(max)                  
Declare @Total int                  
          
Set @EndDate=DATEADD(dd, 1, @EndDate)             
                         
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate)                        
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)                  
                  
Create table #Result                  
(Total int)                  
                  
                  
                  
                        
                            
	Set @SQL='                    
		Select
			B.IdAgent,      
			A.IdTransfer,                              
			A.IdStatus,      
			A.ClaimCode,                            
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
			H.GatewayName,
			A.AmountInMN,
			I.CurrencyName,
			A.DateStatusChange  
		From Transfer A WITH(NOLOCK)                            
			Join Agent B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                            
			Join Status C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                            
			Join Payer D WITH(NOLOCK)  on (A.IdPayer=D.IdPayer)                            
			Join PaymentType E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                            
			Join CountryCurrency F WITH(NOLOCK)  on (F.IdCountryCurrency=A.IdCountryCurrency)                            
			Join Country G WITH(NOLOCK)  on (G.IdCountry=F.IdCountry)
			Join Gateway H WITH(NOLOCK) on (H.IdGateway=A.IdGateway)
			Join Currency I WITH(NOLOCK) on (I.IdCurrency=F.IdCurrency)                            
			Left Join TransferHolds thold WITH(NOLOCK) on (thold.IdTransfer=A.IdTransfer)        
		Where '                            

		IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
			SET @SQL = @SQL + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
		IF @Folio IS NOT NULL
			SET @SQL = @SQL + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND '
                  
                  
	Set @SQLCount= '
		Select  Count(1) as Total                            
		From Transfer A  WITH(NOLOCK)                           
			Join Agent B WITH(NOLOCK)  on (A.IdAgent=B.IdAgent)                            
			Join Status C WITH(NOLOCK) on (A.IdStatus=C.IdStatus)                            
			Join Payer D WITH(NOLOCK) on (A.IdPayer=D.IdPayer)                            
			Join PaymentType E WITH(NOLOCK) on (E.IdPaymentType=A.IdPaymentType)                            
			Join CountryCurrency F WITH(NOLOCK) on (F.IdCountryCurrency=A.IdCountryCurrency)                            
			Join Country G WITH(NOLOCK) on (G.IdCountry=F.IdCountry)                  
			Left Join TransferHolds thold WITH(NOLOCK)  on (thold.IdTransfer=A.IdTransfer)
		Where '                            

	IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
		SET @SQLCount = @SQLCount + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
	IF @Folio IS NOT NULL
		SET @SQLCount = @SQLCount + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND '                   
                  
                            
	Set @SQL2='                                
		Select
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
		From TransferClosed A WITH(NOLOCK)                            
			Join Agent B WITH(NOLOCK) on (A.IdAgent=B.IdAgent)                            
		Where '                            

	IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
		SET @SQL2 = @SQL2 + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
	IF @Folio IS NOT NULL
		SET @SQL2 = @SQL2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND '                   
                  
	Set @SQLCount2='                  
		Select	Count(1) as Total                      
		From TransferClosed A WITH(NOLOCK)                        
			Join Agent B on (A.IdAgent=B.IdAgent)                            
		Where '

	IF @EndDate IS NOT NULL AND  @StartDate IS NOT NULL
		SET @SQLCount2 = @SQLCount2 + ' A.DateOfTransfer>='+CHAR(39)+CONVERT(VARCHAR(MAX),@StartDate)+CHAR(39)+' AND  A.DateOfTransfer<'+CHAR(39)+CONVERT(VARCHAR(MAX),@EndDate)+CHAR(39)+' AND '                            
			
	IF @Folio IS NOT NULL
		SET @SQLCount2 = @SQLCount2 + ' A.Folio = ' + CONVERT(VARCHAR(MAX),@Folio) + ' AND '                  
                            
                            
If @IdAgent is not null                            
Begin                            
 Set @SQL=@SQL+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                   
 Set @SQLCount=@SQLCount+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                   
                    
 Set @SQL2=@SQL2+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                            
 Set @SQLCount2=@SQLCount2+'A.IdAgent='+Convert(varchar(max),@IdAgent)+' And '                            
                   
End                            
                            
If @IdStatus is not null                            
Begin 
 -- Si el IdStatus es un hold es necesario verificar que sea un Hold y que en la tabla de detalle tenga un detalle con ese Hold y sin rejected ni release
 
 Declare @IsHold bit
 Declare @IdStatusTemp int 

 set @IsHold= (Select CanChangeToAgingHold from Status WITH(NOLOCK) where IdStatus=@IdStatus)
 if(@IsHold=1)                           
	Begin 
		set @IdStatusTemp= 41 -- Verify Hold
		Set @SQL= @SQL +'thold.IdStatus='+Convert(varchar(max),@IdStatus)+' And thold.IsReleased is null And '    
		Set @SQLCount= @SQLCount +'thold.IdStatus='+Convert(varchar(max),@IdStatus)+' And thold.IsReleased is null And '    
	End
 Else 
	Begin 
		set @IdStatusTemp= @IdStatus
	End
	
 Set @SQL=@SQL+'A.IdStatus='+Convert(varchar(max),@IdStatusTemp)+' And '                  
 Set @SQLCount=@SQLCount+'A.IdStatus='+Convert(varchar(max),@IdStatusTemp)+' And '                  
                             
 Set @SQL2=@SQL2+'A.IdStatus='+Convert(varchar(max),@IdStatus)+' And '                  
 Set @SQLCount2=@SQLCount2+'A.IdStatus='+Convert(varchar(max),@IdStatus)+' And '                                      
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
 Set @SQL=@SQL+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '
Set @SQLCount=@SQLCount+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                
                             
 Set @SQL2=@SQL2+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK) where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                
 Set @SQLCount2=@SQLCount2+'A.IdCustomer in (Select IdCustomer from CardVIP WITH(NOLOCK)  where IdGenericStatus=1  and CardNumber='+char(39)+@CardNumber+char(39)+')'+' And '                           
End                            
   
                             
                            
Set @SQL=@SQL+' 1=1  Union '+@SQL2+ ' 1=1 order by A.DateOfTransfer desc'                   
Set @SQLCount=@SQLCount+' 1=1   '+@SQLCount2+ ' 1=1 '                      
Print @SQL                  
--Print @SQLCount                            
                   
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
   --print @sql                
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
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_FilterForExcel',Getdate(),@ErrorMessage)                                                      
End Catch  


