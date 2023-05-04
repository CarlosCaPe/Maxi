
CREATE PROCEDURE [MaxiMobile].[st_GetTransfersTodayByIdstatus]
(
	@IdAgent INT,
	@idstatus int = null
)
/********************************************************************
<Author> Mhinojo </Author>
<app> WebApi </app>
<Description> Sp para obtener todas las transferencias en signature hold por agencia </Description>

<ChangeLog>
<log Date="05/06/2017" Author="Mhinojo">Creation</log>
<log Date="16/05/2019" Author="rgaona">Se agrega un campo que regresa el semaforo dependiendo del idTransfer</log>
</ChangeLog>
<log Date="28/08/2020" Author="alopez">Se agrego Th.IsReleased is null para quitar registros dobles modificación 
a la hora de liberar </log>

*********************************************************************/
as
Begin Try 

declare @today datetime=[dbo].[RemoveTimeFromDatetime]( getdate())
declare @tomorrow datetime=@today+1
declare @fasttransfer table
(
	idtransfer int
)

		
		--siganturehold
	    insert into @fasttransfer
		select t.IdTransfer FROM [TRANSFER] T  (nolock)                          			
		Join TransferHolds Th (nolock)  on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=3 and Th.IsReleased is null)  			
		WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.DateOfTransfer>=@today and t.DateOfTransfer<=@tomorrow and @idstatus is null

		--kychold
		insert into @fasttransfer
		select t.IdTransfer FROM [TRANSFER] T (nolock)                                			
		Join TransferHolds Th (nolock)  on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=9 and Th.IsReleased is null)  			
		join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
		WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.DateOfTransfer>=@today and t.DateOfTransfer<=@tomorrow and @idstatus is null

		--denylist
		insert into @fasttransfer
		select t.IdTransfer FROM [TRANSFER] T (nolock)                                			
		Join TransferHolds Th (nolock)  on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=12 and Th.IsReleased is null)  			
		join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
		WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.DateOfTransfer>=@today and t.DateOfTransfer<=@tomorrow and @idstatus is null

		--ofac
		insert into @fasttransfer
		select t.IdTransfer FROM [TRANSFER] T (nolock)                                			
		Join TransferHolds Th (nolock)  on (T.IdTransfer=Th.IdTransfer and Th.IdStatus=15 and Th.IsReleased is null)  			
		join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
		WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41 and t.DateOfTransfer>=@today and t.DateOfTransfer<=@tomorrow and @idstatus is null

		--gateway info
		insert into @fasttransfer
		select t.IdTransfer FROM [TRANSFER] T (nolock)                                					
		join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
		WHERE T.IdAgent = @IdAgent AND T.IdStatus = 29 and t.DateStatusChange>=@today and t.DateStatusChange<=@tomorrow and @idstatus is null

		SELECT 			
			T.IdTransfer,                              
			T.IdStatus,      			
			T.DateOfTransfer,                            			
			T.Folio,   			
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     			            
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    			
			T.AmountInDollars,
			convert(bit,case when isnull(th.IsReleased, 0) = 0 and isnull(Th.IdStatus, 0) = 3 then 1 else 0 end) requireSing,
			isnull(Note,'') Note,
			convert(bit,isnull(RequiereID,0)) RequiereID,
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
		FROM [TRANSFER] T (nolock)                           			
			left Join TransferHolds Th (nolock)on (T.IdTransfer=Th.IdTransfer and Th.IdStatus = 3 and Th.IsReleased is null)  			
			left join maximobile.TransferAdditionalInfo i (nolock) on t.IdTransfer=i.IdTransfer and i.numdocs>0
			--WHERE T.IdAgent = @IdAgent AND T.IdStatus = 41
			where t.IdTransfer in (select IdTransfer from @fasttransfer)
		union
		SELECT 			
			T.IdTransfer,                              
			T.IdStatus,      			
			T.DateOfTransfer,                            			
			T.Folio,   			
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     			            
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    			
			T.AmountInDollars,
			convert(bit,0) requireSing,
			'' Note,convert(bit,0) RequiereID,convert(bit,0) RequiereProof,convert(bit,0) CustomerOccupation,convert(bit,0) CustomerAddress,convert(bit,0) CustomerSSN,convert(bit,0) IDNotLegible,convert(bit,0) CustomerIDNumber,convert(bit,0) CustomerDateOfBirth,convert(bit,0) CustomerPlaceOfBirth,convert(bit,0) CustomerIDExpiration,convert(bit,0) CustomerFullName,convert(bit,0) CustomerFullAddress,convert(bit,0) BeneficiaryFullName,convert(bit,0) BeneficiaryDateOfBirth,convert(bit,0) BeneficiaryPlaceOfBirth,convert(bit,0) BeneficiaryRequiereID,convert(bit,0) SignReceipt,0 NumDocs, [dbo].[fun_GetTransferHoldSemaphore](T.IdTransfer) as Semaphore
		FROM [TRANSFER] T (nolock)                           									
			where t.IdTransfer not in (select IdTransfer from @fasttransfer) and IdAgent=@IdAgent and t.IdStatus not in (30,22) and t.DateOfTransfer>=@today and t.DateOfTransfer<=@tomorrow and @idstatus is null
			union
		SELECT 			
			T.IdTransfer,                              
			T.IdStatus,      			
			T.DateOfTransfer,                            			
			T.Folio,   			
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     			            
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    			
			T.AmountInDollars,
			convert(bit,0) requireSing,
			'' Note,convert(bit,0) RequiereID,convert(bit,0) RequiereProof,convert(bit,0) CustomerOccupation,convert(bit,0) CustomerAddress,convert(bit,0) CustomerSSN,convert(bit,0) IDNotLegible,convert(bit,0) CustomerIDNumber,convert(bit,0) CustomerDateOfBirth,convert(bit,0) CustomerPlaceOfBirth,convert(bit,0) CustomerIDExpiration,convert(bit,0) CustomerFullName,convert(bit,0) CustomerFullAddress,convert(bit,0) BeneficiaryFullName,convert(bit,0) BeneficiaryDateOfBirth,convert(bit,0) BeneficiaryPlaceOfBirth,convert(bit,0) BeneficiaryRequiereID,convert(bit,0) SignReceipt,0 NumDocs, [dbo].[fun_GetTransferHoldSemaphore](T.IdTransfer) as Semaphore
		FROM [TRANSFER] T (nolock)                           									
			where t.IdTransfer not in (select IdTransfer from @fasttransfer) and IdAgent=@IdAgent and t.IdStatus = @idstatus and t.DateStatusChange>=@today and t.DateStatusChange<=@tomorrow 
			union
		SELECT 			
			T.IdTransfer,                              
			T.IdStatus,      			
			T.DateOfTransfer,                            			
			T.Folio,   			
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     			            
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    			
			T.AmountInDollars,
			convert(bit,0) requireSing,
			'' Note,convert(bit,0) RequiereID,convert(bit,0) RequiereProof,convert(bit,0) CustomerOccupation,convert(bit,0) CustomerAddress,convert(bit,0) CustomerSSN,convert(bit,0) IDNotLegible,convert(bit,0) CustomerIDNumber,convert(bit,0) CustomerDateOfBirth,convert(bit,0) CustomerPlaceOfBirth,convert(bit,0) CustomerIDExpiration,convert(bit,0) CustomerFullName,convert(bit,0) CustomerFullAddress,convert(bit,0) BeneficiaryFullName,convert(bit,0) BeneficiaryDateOfBirth,convert(bit,0) BeneficiaryPlaceOfBirth,convert(bit,0) BeneficiaryRequiereID,convert(bit,0) SignReceipt,0 NumDocs, [dbo].[fun_GetTransferHoldSemaphore](T.IdTransfer) as Semaphore
		FROM [TRANSFER] T (nolock)                           									
			where t.IdTransfer not in (select IdTransfer from @fasttransfer) and IdAgent=@IdAgent and t.IdStatus in (30,22) and t.DateStatusChange>=@today and t.DateStatusChange<=@tomorrow and @idstatus is null



END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetTransfersTodayByIdstatus]',GETDATE(),@ErrorMessage)
END CATCH


