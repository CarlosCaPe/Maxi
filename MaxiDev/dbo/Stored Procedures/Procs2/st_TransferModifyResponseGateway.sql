-- =============================================
-- Author:		Abraham Dominguez
-- Create date: 2019-08-13
-- Description:	Validate the gateway response for a modified transfer
-- =============================================


/*
<ChangeLog>
	<log Date="03/17/2021" Author="jcsierra">Se agrega en status history los cambios de status</log>
	<log Date="08/12/2021" Author="jcsierra">Se inicializa la transaccion sin uso de las queues</log>
</ChangeLog>
*/

CREATE PROCEDURE [dbo].[st_TransferModifyResponseGateway]
@IdTransfer int,
@IsCancel bit
as 
Begin Try
declare @IdNewTransfer int
declare @StateTax money 
declare @OldIdStatus int

BEGIN
	
	If exists (Select top 1 * from TransferModify with(nolock) where OldIdTransfer = @IdTransfer) and @IsCancel = 1
			Begin
				Select @IdNewTransfer = NewIdTransfer  from TransferModify with(nolock) where OldIdTransfer = @IdTransfer

				update TransferModify set IsCancel = 1 where NewIdTransfer = @IdNewTransfer

				Select top 1 @StateTax = Tax from StateFee with(nolock) where IdTransfer = @IdTransfer


				IF EXISTS(SELECT 1 FROM TransferOFACInfo t WHERE t.IdTransfer = @IdNewTransfer)
					EXEC st_InitTransaction @IdNewTransfer
				ELSE
				BEGIN
					DECLARE
						@conversation uniqueidentifier,
						@msg xml

					set @msg =(
					SELECT 
						T.IdTransfer,
						1 IdTransferStatus,
						T.EnterByIdUser EnterByIdUser,
						T.IdAgent IdAgent, 
						T.IdPayer IdPayer,
						T.CustomerName CustomerName,
						T.CustomerFirstLastName CustomerFirstLastName,
						T.CustomerSecondLastName CustomerSecondLastName,
						T.BeneficiaryName BeneficiaryName,
						T.BeneficiaryFirstLastName BeneficiaryFirstLastName,
						T.BeneficiarySecondLastName BeneficiarySecondLastName,    
						T.IdPaymentType IdPaymentType,
						T.TotalAmountToCorporate Amount,
						T.Folio Reference,  
						T.IdCountryCurrency,
						(Select top 1 c.CountryCode from countrycurrency  cc with(nolock)
								join country c with(nolock) on cc.IdCountry=c.IdCountry
								where idcountrycurrency=T.IdCountryCurrency) as Country,
						T.AgentCommissionExtra AgentCommissionExtra,
						T.AgentCommissionOriginal AgentCommissionOriginal,
					
						T.ModifierCommissionSlider,
						T.ModifierExchangeRateSlider,

						0 IdTransferResend,
						T.DateOfTransfer DateOfTransfer,
						@StateTax StateTax
						from [Transfer] T with(nolock) where IdTransfer = @IdNewTransfer

					FOR XML PATH ('Transfer'),ROOT ('OriginDataType'))

					INSERT INTO [dbo].[SBMessageLog] ([IdTransfer],[MessageXML]) values (@IdTransfer, @msg);

					--- Start a conversation:
					BEGIN DIALOG @conversation
						FROM SERVICE [//Maxi/Transfer/OriginSenderService]
						TO SERVICE N'//Maxi/Transfer/OriginRecipService'
						ON CONTRACT [//Maxi/Transfer/OriginContract]
						WITH ENCRYPTION=OFF;

					--- Send the message
					SEND ON CONVERSATION @conversation
						MESSAGE TYPE [//Maxi/Transfer/OriginDataType]
						(@msg);

					insert into dbo.SBSendOriginMessageLog (ConversationID,MessageXML,[IdTransfer]) values (@conversation,@msg,@IdTransfer);
				END
			End
		Else
			BEGIN
				DECLARE @IdUserSystem INT,
						@NewTransferNote VARCHAR(200)

				SELECT @IdUserSystem = [Value] FROM GlobalAttributes WHERE Name = 'SystemUserID'
				SELECT @OldIdStatus = OldIdStatus, @IdNewTransfer= NewIdTransfer FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer

				--Update [Transfer] set IdStatus = @OldIdStatus where IdTransfer = @IdTransfer
				--exec [dbo].[st_TransferToCancelInProgress] @IdUserSystem,2 ,@IdNewTransfer, 'Cancelación por modificación',  18, 0, '' 
				UPDATE [Transfer] SET IdStatus = 22 WHERE IdTransfer = @IdNewTransfer

				SELECT
					@NewTransferNote = CONCAT('This transaction has been cancelled due to the Modification did not proceed (', t.ClaimCode, ' ', st.StatusName, ')')
				FROM Transfer t WITH(NOLOCK)
					JOIN Status st WITH(NOLOCK) ON st.IdStatus = t.IdStatus
				WHERE t.IdTransfer = @IdTransfer

				EXEC st_SaveChangesToTransferLog @IdNewTransfer, 22, @NewTransferNote, 0
			END

END
End try
begin catch    
Declare @ErrorMessages nvarchar(max)                                                                                             
Select @ErrorMessages=ERROR_MESSAGE()                                                     
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_TransferModifyResponseGateway',Getdate(),@ErrorMessages)                                                                                            
end catch
