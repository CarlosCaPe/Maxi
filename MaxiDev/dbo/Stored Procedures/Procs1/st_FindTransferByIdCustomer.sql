CREATE PROCEDURE [dbo].[st_FindTransferByIdCustomer]    
(    
	@IdPerson 		INT,    
	@FromDate 		DATETIME,    
	@ToDate 		DATETIME,
	@IsCustomer 	BIT = 1,
	@IdProductType	INT    
)    
As  

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="05/04/2018" Author="jdarellano" Name="#1">Se aplica cambio sobre rango de fechas en tabla de "Transfer".</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
  
SET ARITHABORT ON
SET NOCOUNT ON 
    
Select @FromDate=dbo.RemoveTimeFromDatetime(@FromDate)    
Select @ToDate=dbo.RemoveTimeFromDatetime(@ToDate)    
Set @ToDate=DATEADD(DAY,1,@ToDate)    
/*
declare @CurrentDate datetime 
SET @CurrentDate = dbo.RemoveTimeFromDatetime(GETDATE())    
SET @CurrentDate = DATEADD(DAY,-7,@CurrentDate)    
*/
IF(@IsCustomer = 1)
BEGIN
	
	IF (@IdProductType = 0)
	BEGIN
	
		Select Folio,DateOfTransfer,AmountInDollars,AmountInMN,BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as PersonName     
		--from Transfer where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)   
		--from Transfer where IdCustomer=@IdPerson and DateOfTransfer>=@CurrentDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)
		from dbo.[Transfer] with (nolock) where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)--#1    
		Union    
		Select Folio,DateOfTransfer,AmountInDollars,AmountInMN,BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as PersonName     
		from TransferClosed with(nolock) where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)    		
		UNION
		SELECT BPR.IdProductTransfer AS 'Folio', BPR.DateOfCreation AS 'DateOfTransfer', BPR.Amount AS 'AmountInDollars', BPR.AmountInMN, '' AS 'PersonName'
		FROM Regalii.TransferR BPR
		WHERE BPR.IdCustomer = @IdPerson AND BPR.DateOfCreation >= @FromDate AND BPR.DateOfCreation < @ToDate AND BPR.IdStatus NOT IN (31, 22)
		UNION
		SELECT BP.IdProductTransfer AS 'Folio', BP.DateOfCreation AS 'DateOfTransfer', BP.Amount AS 'AmountInDollars', BP.AmountInMN, '' AS 'PersonName'
		FROM BillPayment.TransferR BP
		WHERE BP.IdCustomer = @IdPerson AND BP.DateOfCreation >= @FromDate AND BP.DateOfCreation < @ToDate AND BP.IdStatus NOT IN (31, 22)
		Order by DateOfTransfer DESC
	
	END 		
	ELSE
	BEGIN
		IF (@IdProductType = 1)
		BEGIN
			Select Folio,DateOfTransfer,AmountInDollars,AmountInMN,BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as PersonName     
			--from Transfer where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)   
			--from Transfer where IdCustomer=@IdPerson and DateOfTransfer>=@CurrentDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)
			from dbo.[Transfer] with (nolock) where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)--#1    
			Union    
			Select Folio,DateOfTransfer,AmountInDollars,AmountInMN,BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as PersonName     
			from TransferClosed with(nolock) where IdCustomer=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)    
			Order by DateOfTransfer desc
		END
		ELSE
		BEGIN
			IF (@IdProductType = 2)
			BEGIN
				
				SELECT BPR.IdProductTransfer AS 'Folio', BPR.DateOfCreation AS 'DateOfTransfer', BPR.Amount AS 'AmountInDollars', BPR.AmountInMN, '' AS 'PersonName'
				FROM Regalii.TransferR BPR
				WHERE BPR.IdCustomer = @IdPerson AND BPR.DateOfCreation >= @FromDate AND BPR.DateOfCreation < @ToDate AND BPR.IdStatus NOT IN (31, 22)
				UNION
				SELECT BP.IdProductTransfer AS 'Folio', BP.DateOfCreation AS 'DateOfTransfer', BP.Amount AS 'AmountInDollars', BP.AmountInMN, '' AS 'PersonName'
				FROM BillPayment.TransferR BP
				WHERE BP.IdCustomer = @IdPerson AND BP.DateOfCreation >= @FromDate AND BP.DateOfCreation < @ToDate AND BP.IdStatus NOT IN (31, 22)
				Order by DateOfTransfer DESC
				
			END
		END
	END
		
		   

END
ELSE
BEGIN

        Select Folio,DateOfTransfer,AmountInDollars,AmountInMN, CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName as PersonName     
		--from Transfer where IdBeneficiary=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)   
		--from Transfer where IdBeneficiary=@IdPerson and DateOfTransfer>=@CurrentDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)
		from dbo.[Transfer] with (nolock) where IdBeneficiary=@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)   --#1   
		Union    
		Select Folio,DateOfTransfer,AmountInDollars,AmountInMN,CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName as PersonName     
		from TransferClosed with(nolock) where IdBeneficiary =@IdPerson and DateOfTransfer>=@FromDate and DateOfTransfer<@ToDate and IdStatus not in (31,22)    
		Order by DateOfTransfer desc 

END


