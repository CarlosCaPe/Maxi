CREATE PROCEDURE [dbo].[st_CheckPendingFiles]
(
	@IdAgent varchar(max),
	@IsAgentApp bit 
)
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
<lgo Date="13/03/2023" Author="cagarcia">BM-574 Fix para que tome permisos de Cronos y en validacion de fecha de expiracion</log>
</ChangeLog>
********************************************************************/
Begin try

	Declare @EmailProfile nvarchar(max)	 
	Declare @recipients nvarchar (max)
	Declare @body nvarchar(max)
	Declare @Subject nvarchar(max) 
	Declare @documentsMessage varchar(max)

	declare @UpdatePendingFileByAgent table
	(
		IdPendingFilesAgent int
	)

	declare @DocumetsPending table
	(
		Name varchar(max)
	)

	-- 1. Se revisa los pending files que ya tengan un archivo 
	if @IsAgentApp = 0
	begin 
		insert into @UpdatePendingFileByAgent select pf.IdPendingFilesAgent from PendingFilesAgent pf with(nolock)
			join Uploadfiles uf  with(nolock)
			on pf.IdAgent = uf.IdReference and pf.IdDocumentType = uf.IdDocumentType and uf.CreationDate >= pf.DateCreate
			where pf.IdGenericStatus = 1 and pf.IsUpload = 0 and pf.IdAgent = @IdAgent
	end
	else
	begin 
		insert into @UpdatePendingFileByAgent select pf.IdPendingfilesAgentApp from PendingFilesAgentApp pf with(nolock)
			join Uploadfiles uf with(nolock)
			on pf.IdAgentApplication = uf.IdReference and pf.IdDocumentType = uf.IdDocumentType and uf.CreationDate >= pf.DateCreate
			where pf.IdGenericStatus = 1 and pf.IsUpload = 0 and pf.IdAgentApplication = @IdAgent
	end
	
	-- 2. Se actulizar los registros para aquellos que ya tengan un doc 
	--if (select count(*) from @UpdatePendingFileByAgent) > 0
	if EXISTS(select 1 from @UpdatePendingFileByAgent)
	begin -- Si hay registros por actualizar

		if @IsAgentApp = 0
		begin 
			update PendingFilesAgent set IsUpload = 2 where IdPendingFilesAgent in (select * from @UpdatePendingFileByAgent)
		end
		else
		begin 
			update PendingFilesAgentApp set IsUpload = 2 where IdPendingfilesAgentApp in (select * from @UpdatePendingFileByAgent)
		end

	end

	-- 3. Se obtine la lista de los pending Files que estan apunto de expirar
	declare @dayToExpire int
	Select @dayToExpire = Value from GLOBALATTRIBUTES with(nolock) where Name='DaysExpirationAgent'
	if @IsAgentApp = 0
	begin 
		insert into @DocumetsPending Select d.Name from PendingFilesAgent pf with(nolock)
		join DocumentTypes d with(nolock)
		on d.IdDocumentType = pf.IdDocumentType
		where IdGenericStatus = 1 and IsUpload = 0 and IdAgent = @IdAgent and ExpirationDate = DATEADD(dd, DATEDIFF(dd, 0, DateAdd(day, @dayToExpire, getDate())), 0)
	end
	else
	begin 
		insert into @DocumetsPending Select d.Name from PendingFilesAgentApp pf with(nolock)
		join DocumentTypes d with(nolock)
		on d.IdDocumentType = pf.IdDocumentType
		where IdGenericStatus = 1 and IsUpload = 0 and IdAgentApplication = @IdAgent and ExpirationDate = DATEADD(dd, DATEDIFF(dd, 0, DateAdd(day, @dayToExpire, getDate())), 0)-- and sendnotification = 0
	end
	
	-- 4. Verificar si hay documentos por expirar
	--if (select count(*) from @DocumetsPending) > 0
	if EXISTS(select 1 from @DocumetsPending)
	begin 

		Declare @agentCode varchar(max)
		Declare @agentPhone varchar(max)
		Declare @ownerName varchar(max)
		
		-- 4.1. Se obtiene la info de la agencia
		if @IsAgentApp = 0
		begin 
			select @agentCode = a.AgentCode, @agentPhone = a.AgentPhone, @ownerName = Concat(o.Name, ' ', o.LastName, ' ', o.SecondLastName) from agent a with(nolock)
			join [Owner] o with(nolock) on a.idowner = o.idOwner
			where a.idagent = @IdAgent
		end
		else
		begin
			select @agentCode = a.AgentCode, @agentPhone = a.AgentPhone, @ownerName = Concat(o.Name, ' ', o.LastName, ' ', o.SecondLastName) from AgentApplications a with(nolock)
			join [Owner] o with(nolock) on a.idowner = o.idOwner
			where a.IdAgentApplication = @IdAgent
		end
	
		declare @List varchar(max)
		declare @name varchar(max)
		
		-- 4.2. se recorren los documentos para formar el mensaje	
		if (select count (1) from @DocumetsPending) > 1
		begin
			set @List = ''
			SELECT @List = @List +', ' + Name FROM @DocumetsPending
			SET @List = SUBSTRING(@List,2,LEN(@List))
			
			set @documentsMessage = @List + ' documents are Missing'
		end
		else
		begin
			select top 1 @name = Name from @DocumetsPending
			set @documentsMessage = concat(@name, ' document is Missing')
		end

		-- 4.3. Se crea el mensaje a enviar
		if(@IsAgentApp = 0)
		begin
			set @body = concat('The Agent ', @agentCode, ' will be put on Suspended Status on ', CONVERT(VARCHAR(10), DateAdd(day, @dayToExpire, getDate()), 10), '. The ', @documentsMessage, '. The Agent phone is ', @agentPhone, '. The Owner name is ', @ownerName,'.')
		end
		else
		begin
			set @body = concat('For Agent ', @agentCode, ' the ', @documentsMessage, '. The Agent phone is ', @agentPhone, '. The Owner name is ', @ownerName,'.')
		end
		
		declare @rep varchar(max)

		-- 4.4. Se obtienen los destinatarios del correo 
		if(@IsAgentApp = 0)
		begin
			select @recipients = Value from GLOBALATTRIBUTES with(nolock) where Name='PendingFilesNotificationAgent'

			/*select @rep = s.Email from Seller s
			join Agent a 
			on a.IdUserSeller = s.IdUserSeller
			where a.IdAgent = @IdAgent*/ -- Solo en produccion

			if @rep IS NOT NULL AND LEN(@rep) > 0
			begin
				set @recipients = CONCAT(@recipients, ';', @rep)
			end
		end
		else
		begin
			select @recipients = Value from GLOBALATTRIBUTES with(nolock) where Name='PendingFilesNotificationAgentApp'
			
			/*select @rep = s.Email from Seller s
			join AgentApplications a 
			on a.IdUserSeller = s.IdUserSeller
			where a.IdAgentApplication = @IdAgent*/ -- Solo en produccion

			if @rep IS NOT NULL AND LEN(@rep) > 0
			begin
				set @recipients = CONCAT(@recipients, ';', @rep)
			end
		end

		-- 4.5. se manda el correo 
		Select @EmailProfile = Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler'  
		select @subject = concat('Agent ', @agentCode, ' Pending Documents' )

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name=@EmailProfile,                                                       
		@recipients = @recipients,                                                            
		@body = @body,                                                             
		@subject = @subject

	end

	-- 5. Se suspende la agencia si no se subio algun documento
	declare @IdAgentStatus int--Se agrega cambio en atención al ticket 395 (20170324).
	set @IdAgentStatus=(select IdAgentStatus from Agent with(nolock) where idagent=@idagent)--Se agrega cambio en atención al ticket 395 (20170324).
	
	if (@IdAgentStatus in (1,4,7))--Se agrega cambio en atención al ticket 395.
	begin
		if @IsAgentApp = 0
		begin 
			if exists(select IdAgent from PendingFilesAgent with(nolock) where IsUpload = 0 and IdGenericStatus = 1 and ExpirationDate = DATEADD(dd, DATEDIFF(dd, 0, DateAdd(day, @dayToExpire, getDate())), 0) and IdAgent = @IdAgent)
			begin

				-- 5.1. Se obtiene los documentos expirados 			
				declare @DocumetsExpired table
				(
					Name 			VARCHAR(max),
					CanSuspendAML	BIT,
					CanSuspendAA 	BIT
				)

				insert into @DocumetsExpired Select d.Name, 
					dbo.fn_IsCurrentlyAuthorized(IdUserLastChange, 'Catalog','Agent_Cronos','SBT') AS CanSuspendAML,
					dbo.fn_IsCurrentlyAuthorized(IdUserLastChange, 'Catalog','Agent_Cronos','SBAA') AS CanSuspendAA 
				from PendingFilesAgent pf with(nolock)
				join DocumentTypes d with(nolock)
				on d.IdDocumentType = pf.IdDocumentType
				where IdGenericStatus = 1 and IsUpload = 0 and IdAgent = @IdAgent and ExpirationDate = DATEADD(dd, DATEDIFF(dd, 0, DateAdd(day, @dayToExpire, getDate())), 0)
				
				
				--SELECT * FROM @DocumetsExpired

				-- 5.3. Se hace el cambio de status de la agencia
				-- 5.3.1 Se obtiene el subestatus de suspencion
				declare @idUser int
				declare @messageToSave varchar(max)
				DECLARE @SuspCompliance BIT, @SuspAMLTraining BIT, @SuspAccRec BIT, @SuspFraudMonitor BIT, @SuspAgentAdmin BIT
				
				set @messageToSave = concat('Suspended by System. The ', LTRIM(RTRIM(@documentsMessage)))
				set @idUser = [dbo].[GetGlobalAttributeByName]('SystemUserID')
				
				IF (NOT EXISTS (SELECT 1 FROM @DocumetsExpired WHERE CanSuspendAML = 1 OR CanSuspendAA = 1))   
				BEGIN
					--SELECT * FROM @DocumetsExpired
					-- 5.2. Se recorren los documentos para formar el mensaje a guardar
					if (select count (1) from @DocumetsExpired) > 1
					BEGIN
						--SELECT '3.1'
						set @List = ''
						
						select @List = @List +', ' + Name 
						FROM @DocumetsExpired 						
						
						
						set @List = SUBSTRING(@List,2,LEN(@List))
						set @documentsMessage = @List + ' documents are Missing'
					end
					else
					BEGIN
						--SELECT '3.2'
						select top 1 @name = Name 
						from @DocumetsExpired
						
						set @documentsMessage = concat(@name, ' document is Missing')
					END
					
					set @messageToSave = concat('The ', LTRIM(RTRIM(@documentsMessage)))					
					
				
					SELECT @SuspCompliance = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
					--SELECT @SuspAMLTraining = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
					SELECT @SuspAccRec = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
					SELECT @SuspFraudMonitor = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
					SELECT @SuspAgentAdmin = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
					
					
					SELECT @SuspCompliance = isnull(@SuspCompliance, 0),
							@SuspAccRec = isnull(@SuspAccRec, 0),
							@SuspFraudMonitor = isnull(@SuspFraudMonitor, 0),
							@SuspAgentAdmin = isnull(@SuspAgentAdmin, 0)
							
					
					EXEC Corp.st_AgentStatusChange @idAgent, 3, @idUser, @messageToSave, NULL, @SuspCompliance, 1, @SuspAccRec, @SuspFraudMonitor, @SuspAgentAdmin
					
				END	
				ELSE
				BEGIN
				
					IF (EXISTS(SELECT 1 FROM @DocumetsExpired WHERE CanSuspendAML = 1))
					BEGIN
					
						-- 5.2. Se recorren los documentos para formar el mensaje a guardar
						if (select count (1) from @DocumetsExpired WHERE CanSuspendAML = 1) > 1
						BEGIN
							--SELECT '1.1'
							set @List = ''
							
							select @List = @List +', ' + Name 
							FROM @DocumetsExpired 
							WHERE CanSuspendAML = 1						
							
							
							
							set @List = SUBSTRING(@List,2,LEN(@List))
							set @documentsMessage = @List + ' documents are Missing'
						end
						else
						BEGIN
							--SELECT '1.2'
							select top 1 @name = Name 
							from @DocumetsExpired
							WHERE CanSuspendAML = 1
							
							set @documentsMessage = concat(@name, ' document is Missing')
						END
						
						set @messageToSave = concat('The ', LTRIM(RTRIM(@documentsMessage)))
						
					
						SELECT @SuspCompliance = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
						--SELECT @SuspAMLTraining = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
						SELECT @SuspAccRec = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
						SELECT @SuspFraudMonitor = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
						SELECT @SuspAgentAdmin = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
						
						SELECT @SuspCompliance = isnull(@SuspCompliance, 0),
								@SuspAccRec = isnull(@SuspAccRec, 0),
								@SuspFraudMonitor = isnull(@SuspFraudMonitor, 0),
								@SuspAgentAdmin = isnull(@SuspAgentAdmin, 0)
								
						
						EXEC Corp.st_AgentStatusChange @idAgent, 3, @idUser, @messageToSave, NULL, @SuspCompliance, 1, @SuspAccRec, @SuspFraudMonitor, @SuspAgentAdmin
							
					END
					
					IF EXISTS (SELECT 1 FROM @DocumetsExpired WHERE CanSuspendAA = 1)
					BEGIN				
						
						-- 5.2. Se recorren los documentos para formar el mensaje a guardar
						if (select count (1) from @DocumetsExpired WHERE CanSuspendAA = 1) > 1
						BEGIN
							--SELECT '2.1'
							set @List = ''
							
							select @List = @List +', ' + Name 
							FROM @DocumetsExpired 
							WHERE CanSuspendAA = 1
							
							
							set @List = SUBSTRING(@List,2,LEN(@List))
							set @documentsMessage = @List + ' documents are Missing'
						end
						else
						BEGIN
							--SELECT '2.2'
							select top 1 @name = Name 
							from @DocumetsExpired
							WHERE CanSuspendAA = 1
							
							set @documentsMessage = concat(@name, ' document is Missing')
						end
					
						SELECT @SuspCompliance = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
						SELECT @SuspAMLTraining = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
						SELECT @SuspAccRec = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
						SELECT @SuspFraudMonitor = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
						--SELECT @SuspAgentAdmin = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
						
						set @messageToSave = concat('The ', LTRIM(RTRIM(@documentsMessage)))
						
						SELECT @SuspCompliance = isnull(@SuspCompliance, 0),
								@SuspAccRec = isnull(@SuspAccRec, 0),
								@SuspFraudMonitor = isnull(@SuspFraudMonitor, 0),
								@SuspAMLTraining = isnull(@SuspAMLTraining, 0)
						
						EXEC Corp.st_AgentStatusChange @idAgent, 3, @idUser, @messageToSave, NULL, @SuspCompliance, @SuspAMLTraining, @SuspAccRec, @SuspFraudMonitor, 1
					
					END	
				
				END		
				

				-- 5.4. Se guarda el agent mirror y se actualiza la hora en que se suspendio
				exec st_SaveAgentMirror @IdAgent 
				update Agent set SuspendedDatePendingFile = GETDATE() where IdAgent = @idAgent
			end
		end
	end--Se agrega cambio en atención al ticket 395 (20170324).

End try
Begin Catch 
	declare @ErrorMessage varchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()      
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CheckPendingFiles',Getdate(),@ErrorMessage)   
end catch


