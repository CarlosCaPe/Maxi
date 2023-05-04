CREATE PROCEDURE [dbo].[st_saveAgentChangeHistory]
	@idAgent INT,
	@fieldData NVARCHAR(MAX),
	@fieldType NVARCHAR(MAX),
	@EnterByIdUser INT,
	@FromAgentApplication BIT  = 0
AS
BEGIN
	/********************************************************************
	<Author>Mario Delgado</Author>
	<app>MaxiCorp</app>
	<Description>Save at History of Agent changes to specific fields.</Description>

	<ChangeLog>
	<log Date="14/03/2017" Author="Mdelgado">Creacion del Store</log>
	<log Date="03/05/2017" Author="Mdelgado">Fix. Log comparando ultimo cambio es permitido.</log>
	<log Date="05/07/2017" Author="Mdelgado">Campo FromAgentApplication & increse varchar</log>
	<log Date="06/07/2017" Author="Mdelgado">Add Agent Status History</log>
	<log Date="15/09/2017" Author="snevarez">S39:Validacion check box sin cambios</log>
	<log Date="28/02/2018" Author="MHINOJO">Mostrar histórico de agent </log>
	<log Date="07/03/2018" Author="snevarez">Agregar historicos para estadus diferentes a 21-Needs Wells Fargo, 22-Request Wells Fargo</log>
	</ChangeLog>
	*********************************************************************/
	
	SET NOCOUNT ON;	

	--DECLARE @Parametes VARCHAR(MAX);
	--SET @Parametes = 'Parametes:idAgent=' + CONVERT(VARCHAR(12),ISNULL(@idAgent,'NULL')) + ',fieldData=' 
	--			+ @fieldData + ',fieldType = ' 
	--			+ @fieldType + ',EnterByIdUser=' 
	--			+ CONVERT(VARCHAR(12),ISNULL(@EnterByIdUser,'NULL')) + ',FromAgentApplication=' 
	--			+ CONVERT(VARCHAR(12),ISNULL(@FromAgentApplication,'NULL'));

	--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_saveAgentChangeHistory',Getdate(),@Parametes);

	DECLARE @NeedsWFSubaccountText	  nvarchar(max) = 'Needs Wells Fargo Sub Account'
	DECLARE @RequestWFSubaccountText	  nvarchar(max) = 'Requested Wells Fargo Sub Account'

	DECLARE @DoesnNeedsWFSubaccountText   nvarchar(max) = 'Doesn''t Need Wells Fargo Sub Account'
	DECLARE @DoesnRequestWFSubaccountText nvarchar(max) = 'Request for Wells Fargo Sub Account Was Cancelled'
	DECLARE @idStatusHistory int
	DECLARE @fieldDataLast nvarchar(max)
	DECLARE @fieldDataTypeLast nvarchar(max)

	DECLARE @UnCheck BIT = 0; /*Fix:S39*/
	
	BEGIN TRY 

		IF @fieldType = 'NeedsWFSubaccount' 
		BEGIN
			SET @idStatusHistory = (Select Top 1  IdAgentStatus FROM AgentStatus WITH(NOLOCK) WHERE AgentStatus = 'Needs Wells Fargo')
			IF LTRIM(RTRIM(@fieldData)) = '1' 
			BEGIN
				SET @fieldData = @NeedsWFSubaccountText
				SET @UnCheck = 1;
			END
			ELSE
			BEGIN		
				SET @fieldData = @DoesnNeedsWFSubaccountText
				SET @UnCheck = 0;
			 END
		END

		IF @fieldType = 'RequestWFSubaccount' 
		BEGIN
			SET @idStatusHistory = (Select Top 1  IdAgentStatus FROM AgentStatus WITH(NOLOCK) WHERE AgentStatus = 'Request Wells Fargo')
			IF LTRIM(RTRIM(@fieldData)) = '1' 
			BEGIN
				SET @fieldData = @RequestWFSubaccountText
				SET @UnCheck = 1;
			END
			ELSE
			BEGIN
				SET @fieldData = @DoesnRequestWFSubaccountText
			 	SET @UnCheck = 0;
			 END
		END

		DECLARE @LastIdChangeHistory INT;

		SELECT @LastIdChangeHistory = MAX(a.idAgentChangeHistory)
		FROM AgentChangeHistory a WITH(NOLOCK)
		WHERE 
			a.idAgent = @idAgent 
			AND a.fieldType = @fieldType

		IF NOT EXISTS (SELECT TOP 1 1 FROM AgentChangeHistory WITH(NOLOCK) WHERE LTRIM(RTRIM(FieldData)) = LTRIM(RTRIM(@fieldData)) 
					   AND FieldType = @fieldType AND idAgent = @idAgent AND idAgentChangeHistory =  @LastIdChangeHistory )
		BEGIN

		  IF(@UnCheck = 0)
		  BEGIN
		  
			 IF EXISTS
				(SELECT TOP 1 1 FROM AgentStatusHistory
				    WHERE IdAgentStatus  = @idStatusHistory
					   AND idAgent = @idAgent ORDER BY DateOfchange DESC)
			 BEGIN
			
				INSERT INTO AgentChangeHistory (idAgent, FieldData, FieldType, DateOfChange, EnterByIdUser, FromAgentApplication) 
				    VALUES (@idAgent, @fieldData, @fieldType, GETDATE(), @EnterByIdUser, @FromAgentApplication);

				IF (@fieldType = 'RequestWFSubaccount' OR @fieldType = 'NeedsWFSubaccount')
				BEGIN
					   Insert into AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
					   VALUES (@EnterByIdUser,@idAgent,@idStatusHistory,GETDATE(),@fieldData);
				END
			 END
			 ELSE /*S39:2017/Seop/22*/
				BEGIN		
					    
				    IF EXISTS(SELECT TOP 1 1 FROM RelationAgentApplicationWithAgent Where IdAgent = @idAgent)
				    BEGIN
					   DECLARE @IdAgentApplication INT;
					   SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WHERE  IdAgent = @idAgent);

					   --Table:AgentApplicationStatuses
					   --IdAgentApplicationStatus	StatusCodeName						  StatusName
					   --21						NeedsWellsFargo					Needs Wells Fargo
					   --22						RequestWellsFargo					Request Wells Fargo
					   IF EXISTS(SELECT TOP 1 1 FROM [AgentApplicationStatusHistory] WITH(NOLOCK) 
								    WHERE IdAgentApplication = @IdAgentApplication
									   AND IdAgentApplicationStatus in (21,22))
					   BEGIN
					 
						  INSERT INTO AgentChangeHistory (idAgent, FieldData, FieldType, DateOfChange, EnterByIdUser, FromAgentApplication) 
							 VALUES (@idAgent, @fieldData, @fieldType, GETDATE(), @EnterByIdUser, @FromAgentApplication);

						  IF (@fieldType = 'RequestWFSubaccount' OR @fieldType = 'NeedsWFSubaccount')
						  BEGIN
								Insert into AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
								VALUES (@EnterByIdUser,@idAgent,@idStatusHistory,GETDATE(),@fieldData);
						  END
					   END
					   ELSE
					   BEGIN
						   /*DEPLOY 07/MAR/2018*/
					         INSERT INTO AgentChangeHistory (idAgent, FieldData, FieldType, DateOfChange, EnterByIdUser, FromAgentApplication) 
							  VALUES (@idAgent, @fieldData, @fieldType, GETDATE(), @EnterByIdUser, @FromAgentApplication);
					   END
					  
				    END
					ELSE
						/*DEPLOY 28/FEB/2018*/
					     INSERT INTO AgentChangeHistory (idAgent, FieldData, FieldType, DateOfChange, EnterByIdUser, FromAgentApplication) 
							 VALUES (@idAgent, @fieldData, @fieldType, GETDATE(), @EnterByIdUser, @FromAgentApplication);
				END
		  END
		  ELSE
		  BEGIN
			
			 INSERT INTO AgentChangeHistory (idAgent, FieldData, FieldType, DateOfChange, EnterByIdUser, FromAgentApplication) 
			 VALUES (@idAgent, @fieldData, @fieldType, GETDATE(), @EnterByIdUser, @FromAgentApplication);

			 IF (@fieldType = 'RequestWFSubaccount' OR @fieldType = 'NeedsWFSubaccount')
			 BEGIN
				    INSERT INTO AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
				    VALUES (@EnterByIdUser,@idAgent,@idStatusHistory,GETDATE(),@fieldData);
			 END

		  END

		END

	END TRY
	BEGIN CATCH
		DECLARE @MessageOut varchar(max);
		DECLARE @IsSpanishLanguage bit = 1;		
		Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
		Declare @ErrorMessage nvarchar(max)  
		Select @ErrorMessage = ERROR_MESSAGE()
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_saveAgentChangeHistory',Getdate(), '@EnterByIdUser = ' + CONVERT(VARCHAR(10), ISNULL(@EnterByIdUser, -1)) + ', @idAgent = ' + CONVERT(VARCHAR(10), ISNULL(@idAgent, -1)) + @ErrorMessage)
	END CATCH
END