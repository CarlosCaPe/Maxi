CREATE PROCEDURE [MaxiMobile].[st_GetTransfersInSignatureHoldByAgent] --1242
(
@IdAgent INT
)
/********************************************************************
<Author> Mhinojo </Author>
<app> WebApi </app>
<Description> Sp para obtener todas las transferencias en signature hold por agencia </Description>

<ChangeLog>
<log Date="05/06/2017" Author="Mhinojo">Creation</log>
<log Date="16/05/2019" Author="rgaona">Se agrega un campo que regresa el semaforo dependiendo del idTransfer</log>
<log Date="20/11/2019" Author="SGarcia">Se agrega funcionalidad para que tome automáticamente la notificación de compliance</log>
<log Date="26/11/2019" Author="jdarellano Name="#2" ">Se agrega funcionalidad para notificaciones sobre transacciones en Hold para Compliance.</log>
<log Date="12/02/2020" Author="jsierra">Se elimina el status 27 de los considerados en las transacciones de siganturehold</log>
<log Date="12/02/2020" Author="jsierra">Se muestran solo algunos status de hold (3,6,9,12,15,18) y 41, 29, 21</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

declare @fasttransfer table
(
idtransfer int
)
declare @numdocs int
declare @PaymentReadyDays int 
set @PaymentReadyDays = (SELECT Value from GlobalAttributes where Name = 'PaymentReadyRecordsInDays');

--siganturehold
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
WHERE T.IdAgent = @IdAgent AND T.IdStatus in (20, 21, 24, 28, 40) and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--paymentready
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 23 AND t.DateOfTransfer >= GETDATE() - @PaymentReadyDays and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--siganturehold
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=3 and Th.IsReleased is null) 
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--kychold
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=9 and Th.IsReleased is null) 
--join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--denylist
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=12 and Th.IsReleased is null) 
join maximobile.TransferAdditionalInfo i with (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--ofac
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=15 and Th.IsReleased is null) 
join maximobile.TransferAdditionalInfo i with (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--gateway info
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
join maximobile.TransferAdditionalInfo i with (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 29 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

--Deposit Hold
insert into @fasttransfer
select t.IdTransfer FROM [TRANSFER] T with (nolock) 
Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=18 and Th.IsReleased is null) 
--join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.IdTransfer not in (select idtransfer from @fasttransfer)--#2

SELECT DISTINCT
--SELECT
T.IdTransfer, 
T.IdStatus, 
T.DateOfTransfer, 
T.Folio, 
T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName, 
T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName, 
T.AmountInDollars,
--convert(bit,case when isnull(th.IsReleased, 0) = 0 and isnull(Th.IdStatus, 0) = 3 then 1 else 0 end) requireSing,
convert(bit,case when exists (select 1 from dbo.TransferHolds as th with (nolock) where th.IdTransfer=t.idtransfer and th.IdStatus=3 and isnull(th.IsReleased, 0) = 0 ) then 1 else 0 end) requireSing,--#2
--#1
case 
when exists(select 1 from maximobile.TransferAdditionalInfo i (nolock) where t.IdTransfer=i.IdTransfer and i.numdocs>0) then isnull(Note,'')
when th.IdStatus=3 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 'Required: Falta ID / Customer ID is required'
when th.IdStatus=9 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 'Required: Falta ID / Customer ID is required'
when th.IdStatus=18 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 'Required: Falta ID / Customer ID is required'
--else isnull(Note,'')
end 
as Note,
--convert(bit,isnull(RequiereID,0)) RequiereID,
--#1
case
when th.IdStatus=3 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 1
--when th.IdStatus=3 and IsReleased is null then 1
when th.IdStatus=9 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 1
when th.IdStatus=18 and IsReleased is null and exists (select 1 from MaxiMobile.TransferAdditionalInfo as m with (nolock) where m.IdTransfer=t.IdTransfer and RequiereID = 1) then 1
else convert(bit,isnull(RequiereID,0))
end 
as RequiereID,
convert(bit,isnull(RequiereProof,0)) RequiereProof,
convert(bit,isnull(i.CustomerOccupation,0)) CustomerOccupation,
convert(bit,isnull(i.CustomerAddress,0)) CustomerAddress,
convert(bit,isnull(CustomerSSN,0)) CustomerSSN,
convert(bit,isnull(IDNotLegible,0)) IDNotLegible,
convert(bit,isnull(CustomerIDNumber,0)) CustomerIDNumber,
convert(bit,isnull(CustomerDateOfBirth,0)) CustomerDateOfBirth,
convert(bit,isnull(CustomerPlaceOfBirth,0)) CustomerPlaceOfBirth,
convert(bit,isnull(CustomerIDExpiration,0)) CustomerIDExpiration,
convert(bit,isnull(CustomerFullName,0)) CustomerFullName,
convert(bit,isnull(CustomerFullAddress,0)) CustomerFullAddress,
convert(bit,isnull(BeneficiaryFullName,0)) BeneficiaryFullName,
convert(bit,isnull(BeneficiaryDateOfBirth,0)) BeneficiaryDateOfBirth,
convert(bit,isnull(BeneficiaryPlaceOfBirth,0)) BeneficiaryPlaceOfBirth,
convert(bit,isnull(BeneficiaryRequiereID,0)) BeneficiaryRequiereID,
convert(bit,isnull(SignReceipt,0))SignReceipt,
isnull(NumDocs,0) NumDocs,
[dbo].[fun_GetTransferHoldSemaphore](T.IdTransfer) as Semaphore
FROM [TRANSFER] T with (nolock) 
left Join TransferHolds Th with (nolock) on (T.IdTransfer=Th.IdTransfer and (Th.IdStatus=9 or Th.IdStatus=9 or Th.IdStatus=18)) 
left join maximobile.TransferAdditionalInfo i with (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
--WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41
where t.IdTransfer in (select IdTransfer from @fasttransfer)
AND EXISTS
(
	SELECT 1 FROM TransferHolds t_hold WHERE t_hold.IdTransfer = T.IdTransfer
	AND t_hold.IdStatus IN (3,6,9,12,15,18)
) AND T.IdStatus IN (41, 29, 21)
order by T.DateOfTransfer desc


--select * from status	
--select * from maximobile.TransferAdditionalInfo where idtransfer=1



END TRY
BEGIN CATCH
DECLARE @ErrorMessage NVARCHAR(MAX)
SELECT @ErrorMessage=ERROR_MESSAGE() 
INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
VALUES('[MaxiMobile].[st_GetTransfersInSignatureHoldByAgent]',GETDATE(),@ErrorMessage)
END CATCH
