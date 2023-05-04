CREATE Procedure [dbo].[st_GetBankaya]
AS 
/********************************************************************
<ChangeLog>
<log Date="26/07/2022" Author="adominguez">Creacion del SP</log>
</ChangeLog>
*********************************************************************/
Set nocount on                             
                        
--- Get Minutes to wait to be send to service ---                        
Declare @MinutsToWait Int                        
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                        
                        
---  Update transfer to Attempt -----------------                        
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=51 and  IdStatus=20                      
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                            
--------- Tranfer log ---------------------------                    
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                     
Select 21,IdTransfer,GETDATE() from #temp                        

Select 
ClaimCode,
BeneficiaryName FirstName,
BeneficiaryFirstLastName + ' ' + BeneficiarySecondLastName FamilyName,
DepositAccountNumber MobileNumber,
Convert(varchar(max),ROUND(AmountInMN, 2, 1)) AmountInMN
from [dbo].[Transfer] Trans WITH (NOLOCK)
Where Trans.IdGateway=51 and IdStatus=21 

--Select 
--'BKY48403824' ClaimCode,
--'Victor David' FirstName,
--'Ortega Gallardo' FamilyName,
--'5522552235' MobileNumber,
--ROUND(3154.50, 2, 1) AmountInMN

