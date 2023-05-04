CREATE procedure [dbo].[st_CheckNewAgentApplication]
    @SnnOwner nvarchar(max) = null,
    @SnnGuarantor nvarchar(max) = null,
    @BussinesAddress nvarchar(max) = null,
    @IdLenguage int = 1,
    @HasError bit out,
    @ResultMessage nvarchar(max) out,
	@subjectMail nvarchar(max) out
	as

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
	
	set @HasError = 0
	set @ResultMessage = ''

	
BEGIN TRY
	declare @AgentcodeOwner nvarchar(max)
	declare @AgentcodeAddress nvarchar(max)
	declare @AgentcodeGuarantor nvarchar(max)

	set @subjectMail = ''

	if @SnnGuarantor is null -- si la busqueda no es por guarantor
	begin
		if @SnnOwner is not null  --- si la gusqueda incluye validación del ssn owner
		 begin 
		 SELECT a.AgentCode into #tempOwner
			FROM Agent a with(nolock)
			JOIN AgentStatus agentS with(nolock)
			ON a.IdAgentStatus = agentS.IdAgentStatus inner join Owner o with(nolock) on o.IdOwner = a.IdOwner where replace(replace(o.SSN, '-', ''), ' ', '')  like @SnnOwner and a.IdAgentStatus in (6,2,5) group by a.AgentCode
		 end 
		if @BussinesAddress is not null --- si la busqueda incluye validación del address de owner
		 begin
		 SELECT a.AgentCode into #tempAddress
			FROM Agent a with(nolock)
			JOIN AgentStatus agentS with(nolock)
			ON a.IdAgentStatus = agentS.IdAgentStatus where a.AgentAddress like @BussinesAddress  and a.IdAgentStatus in (6,2,5) group by a.AgentCode
		 end

		 if @SnnOwner is not null
		 begin 
			DECLARE @AgentCodeList VARCHAR(MAX) = ''

			SELECT @AgentCodeList = @AgentCodeList +',' + o.AgentCode FROM #tempOwner o
			
			SET @AgentcodeOwner = SUBSTRING(@AgentCodeList,2,LEN(@AgentCodeList))

		 end

		 if @BussinesAddress is not null
		 begin  
				set @AgentCodeList = ''

				SELECT @AgentCodeList = @AgentCodeList +',' + a.AgentCode FROM #tempAddress a
			
				SET @AgentcodeAddress = SUBSTRING(@AgentCodeList,2,LEN(@AgentCodeList))
		 end
	end
	else --- si la busqueda es por guarantor
	begin 
		select AgentCode into #tempGuarantor from Agent with(nolock) where replace(replace(GuarantorSSN, '-', ''), ' ', '') like replace(replace(@SnnGuarantor, '-', ''), ' ', '') and IdAgentStatus in (2,5,6) 
		
		set @AgentCodeList = ''
		
		SELECT @AgentCodeList = @AgentCodeList +',' + g.AgentCode FROM #tempGuarantor g
		
		SET @AgentcodeGuarantor = SUBSTRING(@AgentCodeList,2,LEN(@AgentCodeList))

	end
	IF (@AgentcodeOwner IS NOT NULL) AND (LEN(@AgentcodeOwner) > 0)
	begin
		SET @subjectMail += 'SSN'
		set @HasError = 1
		set @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SSNOwnerDisable') + ' ('+@AgentcodeOwner+')'
	end

	IF (@AgentcodeAddress IS NOT NULL) AND (LEN(@AgentcodeAddress) > 0)
	begin
		IF @ResultMessage IS NOT NULL AND LEN(@ResultMessage) > 0 
		begin
			set @ResultMessage = RTRIM(@ResultMessage) + '\n'
		end   
		IF @subjectMail IS NOT NULL AND LEN(@subjectMail) > 0 
		begin
			set @subjectMail += ', Address'
		end
		ELSE
		BEGIN
			set @subjectMail = 'Address'
		END

		set @HasError = 1
		set @ResultMessage = RTRIM(@ResultMessage) + [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'AddressAgentDisable') + ' ('+@AgentcodeAddress+')'
	end

	IF (@AgentcodeGuarantor IS NOT NULL) AND (LEN(@AgentcodeGuarantor) > 0)
	begin
		IF @ResultMessage IS NOT NULL AND LEN(@ResultMessage) > 0 
		begin
			set @ResultMessage = RTRIM(@ResultMessage) + '\n'
		end   
		IF @subjectMail IS NOT NULL AND LEN(@subjectMail) > 0 
		begin
			set @subjectMail += ', Guarantor''s SSN'
		end
		ELSE
		BEGIN
			set @subjectMail = 'Guarantor''s SSN'
		END
		set @HasError = 1
		set @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SSNGuarantorDisable') + ' ('+@AgentcodeGuarantor+')'
	end
	
END TRY
BEGIN CATCH

 Set @HasError=1                                                                                   
 Select @ResultMessage = dbo.GetMessageFromLenguajeResorces (case @IdLenguage when 1 then 0 else 1 end, 80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CheckNewAgentApplication',Getdate(),@ErrorMessage);    
END CATCH