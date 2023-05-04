/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="17/04/2023" Author="jfresendiz">BM-1670 Se agrega suspensión por entrenamiento CFPB</log>
<log Date="17/04/2023" Author="jfresendiz">BM-1724 Se agrega suspensión por fraude en ventas telefónicas</log>
</ChangeLog>
********************************************************************/

CREATE PROCEDURE Corp.st_InsertUpdateAgentSuspendedSubStatus
	@IdAgent				INT,
	@IdUser					INT,
	@IsSuspCompliance		BIT,
	@IsSuspAMLTraining		BIT,
	@IsSuspAccReceivable	BIT,
	@IsSuspFraudMonitor		BIT,
	@IsSuspAgentAdmin		BIT,
	@IsSuspCFPBTraining		BIT,
	@IsSuspPhoneSalesFraud	BIT
AS
BEGIN

	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1 AND Suspended <> @IsSuspCompliance)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspCompliance, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 1, @IsSuspCompliance, getdate(), getdate(), @IdUser)
	END
	
	
	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2 AND Suspended <> @IsSuspAMLTraining)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspAMLTraining, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 2, @IsSuspAMLTraining, getdate(), getdate(), @IdUser)
	END
	
	
	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3 AND Suspended <> @IsSuspAccReceivable)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspAccReceivable, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 3, @IsSuspAccReceivable, getdate(), getdate(), @IdUser)
	END
	
	
	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4 AND Suspended <> @IsSuspFraudMonitor)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspFraudMonitor, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 4, @IsSuspFraudMonitor, getdate(), getdate(), @IdUser)
	END
	
	
	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5 AND Suspended <> @IsSuspAgentAdmin)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspAgentAdmin, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 5, @IsSuspAgentAdmin, getdate(), getdate(), @IdUser)
	END
	
	
	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 6)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 6 AND Suspended <> @IsSuspCFPBTraining)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspCFPBTraining, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 6
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 6, @IsSuspCFPBTraining, getdate(), getdate(), @IdUser)
	END


	IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 7)
	BEGIN	
		
		IF EXISTS (SELECT 1 FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 7 AND Suspended <> @IsSuspPhoneSalesFraud)
		BEGIN
			UPDATE Corp.AgentSuspendedSubStatus SET Suspended = @IsSuspPhoneSalesFraud, DateOfLastChange = getdate(), EnterByIdUser = @IdUser
			WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 7
		END	
	END
	ELSE
	BEGIN
		INSERT INTO Corp.AgentSuspendedSubStatus
		VALUES (@IdAgent, 7, @IsSuspPhoneSalesFraud, getdate(), getdate(), @IdUser)
	END

END
	