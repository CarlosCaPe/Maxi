-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Jun-19
-- Description:	This stored create notificacion
-- =============================================
CREATE PROCEDURE [dbo].[st_CreateComplianceNotificationCustomerRequestId] 
	@IdTransfer INT 
AS
/********************************************************************
<Author>Nevarez, Sergio</Author>
<app>MaxiCorp</app>
<Description>This stored create notificacion</Description>

<ChangeLog>
<log Date="19/06/2017" Author="snevarez">S26 :: This stored create notificacion </log>
<log Date="29/06/2017" Author="jdarellano" ChangeReference="#1" >S29 :: Se realiza cambio para incluir actores "Customer" dentro de KYC. </log>
<log Date="20/11/2019" Author="sgarcia" ChangeReference="#2" >Modificación para generar la notificación de compliance automáticamente al tener una notificación del sistema</log>
</ChangeLog>
********************************************************************/
Begin Try

	Declare @HasError bit;
	Declare @Message nvarchar(max);

	Declare @Transfer Table
	(
		Id INT IDENTITY(1,1)
		,IdTransfer INT
		,ClaimCode VARCHAR(50)
		,Folio VARCHAR(25)
		,IdAgent INT
		,AgentCode VARCHAR(25)
		,AgentName VARCHAR(150)
		,IdCustomer INT
		,CustomerName VARCHAR(150)
		,IdStatus INT
		,DateOfTransfer	DateTime

		,IsKycHold BIT DEFAULT(0)
		,HasRuleBroken BIT DEFAULT(0)
		,HasFileId BIT DEFAULT(0)
	);

	Insert Into @Transfer (IdTransfer,ClaimCode,Folio,IdAgent,AgentCode,AgentName,IdCustomer,CustomerName,IdStatus,DateOfTransfer)
	Select 
		T.IdTransfer
		,T.ClaimCode
		,T.Folio
		,T.IdAgent
		,A.AgentCode
		,A.AgentName
		,T.IdCustomer
		,(T.CustomerName + ' ' + T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName) AS CustomerName
		,T.IdStatus
		,T.DateOfTransfer				
	From Transfer AS T With(NolocK)
		Inner Join Agent AS A  With(NolocK) On T.IdAgent = A.IdAgent		
	Where IdTransfer = @IdTransfer;

	DECLARE @ClaimCode VARCHAR(50)
		,@Folio VARCHAR(25)
		,@IdAgent INT
		,@AgentCode VARCHAR(25)
		,@AgentName VARCHAR(150)
		,@IdCustomer INT
		,@CustomerName VARCHAR(150)
		,@IdStatus INT
		,@DateOfTransfer DATETIME;

	Select 
		Top 1 
		@ClaimCode = ClaimCode
		,@Folio = Folio
		,@IdAgent = IdAgent
		,@AgentCode = AgentCode
		,@AgentName = AgentName
		,@IdCustomer = IdCustomer
		,@CustomerName  = CustomerName
		,@IdStatus = IdStatus
		,@DateOfTransfer = DateOfTransfer
	From @Transfer Where IdTransfer = @IdTransfer;

		/*----------------------------------------------------------*/
		/*Para las agencias de tipo Fax (3:Fax)y telefonicas2:Phone) no se generara notificacion automatica,*/
		/*por el motivo de Id requerido                             */
		/*----------------------------------------------------------*/
		IF EXISTS(Select Top 1 1 From Agent AS A With(Nolock)
						Inner Join AgentCommunication AS AC With(Nolock) ON A.IdAgentCommunication = AC.IdAgentCommunication
					Where AC.IdAgentCommunication in (2,3) AND A.IdAgent = @IdAgent)
		Begin
			Return;
		End

		/*----------------------------------------------------------*/
		/*Se verifica que la operacio(transaccion) este en Hold(41) */
		/*y unos de los holds por KYC(9:KYC Hold)                   */
		/*----------------------------------------------------------*/
		--9	KYC Hold
		--IF Exists(Select 	Top 1 1
		--			From TransferHolds 
		--				Where IdStatus = 9 And ISNULL(IsReleased,0) = 0
		--					And IdTransfer = @IdTransfer)
		--Begin
		
			--Update T	
			--	Set T.IsKycHold = 1
			--From @Transfer AS T
			--	Where T.IdTransfer = @IdTransfer;

			/*----------------------------------------------------------*/
			/*Se valida que la regla rota sea sobre el ator Customer y  */
			/*que la accion requediada sea solicitar ID                 */
			/*----------------------------------------------------------*/
			IF Exists( Select Top 1 1
						From @Transfer AS T
							Inner Join BrokenRulesByTransfer As brt On T.IdTransfer = brt.IdTransfer 
								Inner Join KYCRule As r On brt.IdKYCAction = r.Action And brt.IdRule = r.IdRule
							Inner Join [dbo].[KYCActor] AS a (NOLOCK) ON r.Actor = a.Name
						Where 
							T.IdTransfer = @IdTransfer
							and r.Action = 1 
							And a.IdActor in (1,3,4,5)--#1
							And r.IdGenericStatus = 1)
			Begin
	
				Update T
					Set T.HasRuleBroken = 1
				From @Transfer AS T
					Where T.IdTransfer = @IdTransfer;

				/*----------------------------------------------------------*/
				/*Se verifica que la transaccion contenga un archivo de tipo*/
				/*de identificacion valido                                  */
				/*----------------------------------------------------------*/
				IF Exists( Select Top 1 1
							From  UploadFiles As U
								Inner Join DocumentTypes AS dt WITH(NOLOCK) On U.IdDocumentType = dt.IdDocumentType
										left join CustomerIdentificationType AS ci WITH(NOLOCK) on ci.IdCustomerIdentificationType = dt.IdDocumentType
							Where dt.IdType = 1 And U.IdStatus = 1 And U.IdReference = @IdCustomer)
				Begin
					Return;
				End
				Else
				Begin

					Update T	
						Set T.HasFileId = 1
					From @Transfer AS T
						Where T.IdTransfer = @IdTransfer;

					/*----------------------------------------------------------*/
					/*Se construye he inserta la notificacion para la operacion(transaccion)*/
					/*que no tenga una imagen valida(Identificacion del cliente)*/
					/*----------------------------------------------------------*/
					/*2	KYC Notification*/
					DECLARE @IdMessageProvider INT = 2;
					DECLARE @IdUserSender INT;
					DECLARE @IsSpanishLanguage BIT = 1;
					/*Declare @Note VARCHAR(MAX) = 'Automatic notification by system';*/
					Declare @Note VARCHAR(MAX) = '';
					
					DECLARE @RawMessage nvarchar(max);
						SET @RawMessage = 
							'{"IdTransfer":' + CONVERT(NVARCHAR(50), @IdTransfer) +
							',"AgentCode":"'+ @AgentCode +
							'","AgentName":"'+ @AgentName +
							'","Folio":"'+ @Folio +
							'","ClaimCode":"'+ @ClaimCode +
							'","DateOfTransfer":"'+ CONVERT(varchar(23),@DateOfTransfer,127) +
							'","CustomerName":"'+ @CustomerName +
							'","Note":null'+',"Requirement":[{"IdComplianceProduct":0,"Name":null,"IdStatus":' + CONVERT(NVARCHAR(50),@IdStatus) + ',"NameEs":"Falta ID","NameEn":"Customer ID is required"}]}';

					Select @IdUserSender=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'));

					SELECT @IdAgent AS IdAgent
						, @IdUserSender AS IdUserSender
						, @IdMessageProvider AS IdMessageProvider
						, @RawMessage AS RawMessage;

					/*----------------------------------------------------------*/
					/*Insercion de notas sobre la notificacion en el hitorial de la operacion*/
					/*----------------------------------------------------------*/
					---st_CreateComplianceNotification				
					/**Obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
					Declare @IdTransferDetail INT;
					Declare @IdTransferNoteInserted INT;
					Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer);
	
					--Declare @Note VARCHAR(MAX) = 'Notification has been sent to Agency to request Id';
					Set @Note = 'Automatic notification by system(Required: Falta ID/Customer ID is required)';
					

					Insert Into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate)
						values (@IdTransferDetail,3,@IdUserSender,@Note,GETDATE());
					--#2
					/**/
					EXEC	[MaxiMobile].[st_saveTransferAdditionalInfo]
								@IdTransfer = @IdTransfer,
								@Note = @Note,
								@RequiereID = 1,
								@RequiereProof = 0,
								@CustomerOccupation = 0,
								@CustomerAddress = 0,
								@CustomerSSN = 0,
								@IDNotLegible = 0,
								@CustomerIDNumber = 0,
								@CustomerDateOfBirth = 0,
								@CustomerPlaceOfBirth = 0,
								@CustomerIDExpiration = 0,
								@CustomerFullName = 0,
								@CustomerFullAddress = 0,
								@BeneficiaryFullName = 0,
								@BeneficiaryDateOfBirth = 0,
								@BeneficiaryPlaceOfBirth = 0,
								@BeneficiaryRequiereID = 0,
								@SignReceipt = 0
					/**/
				
					SET @IdTransferNoteInserted = SCOPE_IDENTITY();

					/*------------------------*/
					/*Creacion de Notificacion*/
					/*------------------------*/
					Declare @IdMessage int;
					Exec @IdMessage =  [dbo].[st_CreateMessageForAgent]
												@IdAgent,
												@IdMessageProvider,
												@IdUserSender,
												@RawMessage,
												@IsSpanishLanguage,
												@HasError out,
												@Message out;
				
					if(@HasError = 0)
					begin

						INSERT INTO [dbo].[TransferAutomaticNotification] 
							([IdTransfer],[CreationDate])
						 VALUES
							(@IdTransfer, GETDATE());

						/*--------------------------------*/
						/*Creacion de nota de notificacion*/
						/*--------------------------------*/
						INSERT INTO [dbo].[TransferNoteNotification]
								   ([IdTransferNote], [IdMessage], [IdGenericStatus])
							 VALUES
								   (@IdTransferNoteInserted, @IdMessage, 1);

						/*----------------------------------------------------------*/
						/*Actualizacion de estado de la notificacion sobre la trasnsaccion*/
						/*----------------------------------------------------------*/
						UPDATE [dbo].[Transfer] SET [AgentNotificationSent] = 1 
							WHERE [IdTransfer] = @IdTransfer AND [AgentNotificationSent] = 0; -- No one notification has been sent
					end
					else
					begin
						Delete TransferNote where IdTransferNote = @IdTransferNoteInserted;
						return;
					end

				End

			End
			Else
			Begin
				Return;
			End


		--End

		--Else
		--Begin
		--	Return;
		--End

End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_CreateComplianceNotificationCustomerRequestId',Getdate(),@ErrorMessage);
End Catch