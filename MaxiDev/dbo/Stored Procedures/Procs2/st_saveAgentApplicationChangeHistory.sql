

CREATE PROCEDURE [dbo].[st_saveAgentApplicationChangeHistory]
	@idAgentApplication INT,
	@fieldData NVARCHAR(MAX),
	@fieldType NVARCHAR(MAX),
	@EnterByIdUser INT	
AS
BEGIN
	/********************************************************************
	<Author>Mario Delgado</Author>
	<app>MaxiCorp</app>
	<Description>Save at History of AgentApplication changes to specific fields.</Description>

	<ChangeLog>
	<log Date="14/03/2017" Author="Mdelgado">Creacion del Store</log>	
	<log Date="24/07/2017" Author="Mhinojo">AgentApplicationStatuses con cuatro casos</log>	
	</ChangeLog>
	*********************************************************************/

	--DECLARE @idAgent INT = 1241
	--DECLARE @fieldData NVARCHAR(max) = '(449) 109-5377'
	--DECLARE @fieldType NVARCHAR(max) = 'AgentAdditionalPhone'
	--DECLARE @EnterByIdUser INT = 8068
	
	SET NOCOUNT ON;	

	DECLARE @fieldDataLast nvarchar(MAX)
	DECLARE @fieldDataTypeLast nvarchar(MAX)
	DECLARE @LastIdChangeHistory INT;

	DECLARE @NeedsWFSubaccountText		  nvarchar(MAX) = 'Needs Wells Fargo Sub Account'
	DECLARE @RequestWFSubaccountText	  nvarchar(MAX) = 'Requested Wells Fargo Sub Account'

	DECLARE @DoesnNeedsWFSubaccountText   nvarchar(MAX) = 'Doesn''t Need Wells Fargo Sub Account'
	DECLARE @DoesnRequestWFSubaccountText nvarchar(MAX) = 'Request for Wells Fargo Sub Account Was Cancelled'
	DECLARE @idStatusHistory int
	
	BEGIN TRY 

		IF @fieldType = 'NeedsWFSubaccount' 
		BEGIN
			
			IF LTRIM(RTRIM(@fieldData)) = '1' 
			BEGIN
				SET @idStatusHistory = (SELECT TOP 1  IdAgentApplicationStatus FROM AgentApplicationStatuses WITH(NOLOCK) WHERE StatusCodeName = 'NeedsWellsFargo')
				SET @fieldData = @NeedsWFSubaccountText
			END
			ELSE 			
			BEGIN
				SET @idStatusHistory = (SELECT TOP 1  IdAgentApplicationStatus FROM AgentApplicationStatuses WITH(NOLOCK) WHERE StatusCodeName = 'DoesntNeedWellsFargo')
				SET @fieldData = @DoesnNeedsWFSubaccountText
			END
			
		END

		IF @fieldType = 'RequestWFSubaccount' 
		BEGIN
			IF LTRIM(RTRIM(@fieldData)) = '1' 
			BEGIN
				SET @idStatusHistory = (SELECT TOP 1  IdAgentApplicationStatus FROM AgentApplicationStatuses WITH(NOLOCK) WHERE StatusCodeName = 'RequestWellsFargo')
				SET @fieldData = @RequestWFSubaccountText
			END
			ELSE
			BEGIN
				SET @idStatusHistory = (SELECT TOP 1  IdAgentApplicationStatus FROM AgentApplicationStatuses WITH(NOLOCK) WHERE StatusCodeName = 'RequestWellsFargoCancelled')
				SET @fieldData = @DoesnRequestWFSubaccountText
			END
		END

		SELECT @LastIdChangeHistory = MAX(a.idAgentApplicationsChangeHistory)
		FROM AgentApplicationsChangeHistory a WITH(NOLOCK)
		WHERE 
			a.idAgentApplication = @idAgentApplication
			AND a.fieldType = @fieldType 

		IF NOT EXISTS (SELECT * FROM AgentApplicationsChangeHistory WITH(NOLOCK) WHERE LTRIM(RTRIM(FieldData)) = LTRIM(RTRIM(@fieldData)) AND FieldType = @fieldType AND idAgentApplication = @idAgentApplication AND idAgentApplicationsChangeHistory =  @LastIdChangeHistory )
		BEGIN
			INSERT INTO AgentApplicationsChangeHistory (idAgentApplication, FieldData, FieldType, DateOfChange, EnterByIdUser) 
				VALUES (@idAgentApplication, @fieldData, @fieldType, GETDATE(), @EnterByIdUser);

				IF (@fieldType = 'RequestWFSubaccount' OR @fieldType = 'NeedsWFSubaccount')
				BEGIN	
					Insert into AgentApplicationStatusHistory(IdAgentApplication,IdAgentApplicationStatus, DateOfMovement,Note, DateOfLastChange,IdUserLastChange, IdType)
					VALUES (@idAgentApplication, @idStatusHistory, GETDATE(),@fieldData,GETDATE(),@EnterByIdUser,NULL)
				END
		END

	END TRY
	BEGIN CATCH
		DECLARE @MessageOut varchar(max);
		DECLARE @IsSpanishLanguage bit = 1;		
		Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
		Declare @ErrorMessage nvarchar(max)  
		Select @ErrorMessage = ERROR_MESSAGE()
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_saveAgentApplicationChangeHistory',Getdate(),@ErrorMessage)                                                		
	END CATCH
END