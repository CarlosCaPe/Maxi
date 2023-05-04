CREATE procedure [dbo].[st_OfacAuditForAgent]
@ExecutionIdUser int,
@IP varchar(15) = '127.0.0.1',
@IdAgent int,
@IDtype int,
@IdOfacAuditStatus int,
@note nvarchar(max) = '',
@IdOfacAuditDetailForUpdate int = null
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock), ; and begin try</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin try

DECLARE @UseMaxiOFAC		BIT = 0,
		@UseMaxiOFACEntity	BIT = 0

IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatch' AND ga.Value = '1')
	SET @UseMaxiOFAC = 1

IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatchWithEntity' AND ga.Value = '1')
	SET @UseMaxiOFACEntity = 1

if @IdOfacAuditDetailForUpdate is not null
begin
	update OfacAuditDetail set ChangeStatusNote=@note,[IdOfacAuditStatus]=@IdOfacAuditStatus where IdOfacAuditDetail = @IdOfacAuditDetailForUpdate;
end

	set @IdType = case 
				when @IdType = 1 then 6
				when @IdType = 2 then 5
				when @IdType = 3 then 4
			  end

	declare @IdAgentStatusDisable int
	set @IdAgentStatusDisable = 2;

    declare @IdAgentStatusWOff int
	set @IdAgentStatusWOff = 6;

	declare @IdGenericStatusDisable int
	set @IdGenericStatusDisable=2;

	declare @NameList table
	(
		Id int identity(1,1),
		Name nvarchar(max),
		FirstLastName nvarchar(max),
		SecondLastName nvarchar(max),
		IdOfacAuditType int,
        AgentCode nvarchar(max),
        IdGeneric int
	);	

	declare @MatchDetail table
	(
		[sdn_name] [nvarchar](4000) NULL,
		[sdn_remarks] [nvarchar](2000) NULL,
		[alt_type] [nvarchar](2000) NULL,
		[alt_name] [nvarchar](2000) NULL,
		[alt_remarks] [nvarchar](4000) NULL,
		[add_address] [nvarchar](2000) NULL,
		[add_city_name] [nvarchar](2000) NULL,
		[add_country] [nvarchar](2000) NULL,
		[add_remarks] [nvarchar](4000) NULL
	);
	
	declare @IdUser int
		,@UserName nvarchar(max)
		,@IdUserType int
	
	declare @Id int, 
		@Name nvarchar(max),
		@FirstLastName nvarchar(max),
		@SecondLastName nvarchar(max),
		@IdOfacAuditType int,
        @AgentCode nvarchar(max),
        @IdGeneric int
		
	declare @ExecutionDate datetime, @IdOfacAudit int
	declare @IdOfacAuditDetail int/*, @IdOfacAuditStatus int, @IdOfacAuditStatusNoMatch int, @IdOfacAuditStatusPossibleMatch int*/
	set @ExecutionDate = getDate();
	--set @IdOfacAuditStatusNoMatch=1
	--set @IdOfacAuditStatusPossibleMatch =2

	insert into @NameList (Name,FirstLastName,SecondLastName,IdOfacAuditType,AgentCode,IdGeneric)
	Select
		LTRIM(RTRIM(ISNULL(Name,''))),
		LTRIM(RTRIM(ISNULL(FirstLastName,''))),
		LTRIM(RTRIM(ISNULL(SecondLastName,''))),
		Type ,
        LTRIM(RTRIM(ISNULL(AgentCode,''))),
        IdGeneric
	from 
	(
			select o.Name Name,
				o.LastName FirstLastName,
				o.SecondLastName SecondLastName,
				4 [Type],	--Agent Owner
                A.AgentCode,
                o.idowner IdGeneric
			from dbo.Agent A with (nolock)
			join [owner] o with(nolock) on a.idowner=o.idowner
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff and A.IdAgent=@IdAgent and @IDtype=4
		union
			select 
				A.GuarantorName Name,
				A.GuarantorLastName FirstLastName, 
				A.GuarantorSecondLastName SecondLastName,
				5 [Type],	--Agent Guarantor
                A.AgentCode,
                a.idagent IdGeneric
			from dbo.Agent A with (nolock)
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff and A.IdAgent=@IdAgent and @IDtype=5
		union
			select A.AgentName Name,
				'' FirstLastName,
				'' SecondLastName,
				6 [Type],	--Agent
                A.AgentCode,
                a.idagent IdGeneric
			from dbo.Agent A with (nolock)
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff and A.IdAgent=@IdAgent and @IDtype=6
		/*
		 union
            select DoingBusinessAs Name,
				'' FirstLastName,
				'' SecondLastName,
				7 Type,	--DBA
                A.AgentCode,
               a.idagent IdGeneric
            from agent A where isnull(DoingBusinessAs,'')!=''and
                A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff and A.IdAgent=@IdAgent
		*/
	)L
	order by Name, FirstLastName,  SecondLastName
	
	delete @NameList where (RTRIM(LTRIM(Name)) ='' or LEN((RTRIM(LTRIM(Name))))<2 or Name is null) and (RTRIM(LTRIM(FirstLastName)) ='' or LEN((RTRIM(LTRIM(FirstLastName))))<2 or FirstLastName is null)

	--select * from @NameList

	if exists(select 1 from ofacaudit with(nolock) where [dbo].[RemoveTimeFromDatetime](ExecutionDate)=[dbo].[RemoveTimeFromDatetime](@ExecutionDate) and IdUser!=37)
	begin
		select @IdOfacAudit=idofacaudit from ofacaudit with(nolock) where [dbo].[RemoveTimeFromDatetime](ExecutionDate)=[dbo].[RemoveTimeFromDatetime](@ExecutionDate) and IdUser!=37
	end
	else
	begin
	INSERT INTO [dbo].[OfacAudit]
           ([ExecutionDate]
           ,[IdUser])
     VALUES
           (@ExecutionDate
           ,@ExecutionIdUser);		 
	set @IdOfacAudit = Scope_identity();
	end	

	select top 1
		@Id= Id,
		@Name=Name,
		@FirstLastName=FirstLastName,
		@SecondLastName=SecondLastName,
		@IdOfacAuditType = IdOfacAuditType,
        @AgentCode = AgentCode,
        @IdGeneric = IdGeneric
	from @NameList 
	order by Id;
	
    declare @EntNum table
    (
        ent_num bigint
    );

	DECLARE @XMLResult	XML,
			@FullMatch	BIT,
			@Percent	FLOAT
	
	While (@Id is not null)
	Begin
		print(@Id)
		set @IdOfacAuditDetail= null;
		--set @IdOfacAuditStatus = null
		delete @MatchDetail;
        delete @EntNum;

		SELECT	@XMLResult = NULL,
				@FullMatch = NULL,
				@Percent = NULL
		

		IF(@IdOfacAuditType in (6,7))
        begin
			IF @UseMaxiOFAC = 1 AND @UseMaxiOFACEntity = 1
			BEGIN
				EXEC st_MaxiOFACValidateEntity
					@Name,
					@FirstLastName,
					@SecondLastName,
					@Percent	OUT,
					@FullMatch	OUT,
					@XMLResult	OUT

				INSERT INTO @MatchDetail
				SELECT 
					SDN_NAME, 
					ISNULL(SDN_REMARKS,''),
					ISNULL(ALT_TYPE,''),
					ISNULL(ALT_NAME,''),
					ISNULL(ALT_REMARKS,''),
					ISNULL(ADD_ADDRESS,''),
					ISNULL(ADD_CITY_NAME,''),
					ISNULL(ADD_COUNTRY,''),
					ISNULL(ADD_REMARKS,'')
				FROM dbo.fnMaxiOFACParseXML(@XMLResult)
			END
			ELSE
			BEGIN
				insert into @MatchDetail
				exec dbo.ST_OFAC_SEARCH_DETAILS @Name,@FirstLastName,@SecondLastName;
			END
        end
        else
        begin
            if ltrim(rtrim(dbo.fn_EspecialChrOFF(@SecondLastName)))='' and len(isnull(ltrim(rtrim(dbo.fn_EspecialChrOFF(@FirstLastName))),''))>0
            begin
                insert into @EntNum
                select ent_num from ofac_sdn where SDN_PrincipalName like '%'+@Name+'%'	and SDN_FirstLastName like '%'+@FirstLastName+'%'
                union 
                select ent_num from ofac_alt where alt_PrincipalName like '%'+@Name+'%'	and alt_FirstLastName like '%'+@FirstLastName+'%'

                insert into @MatchDetail
                SELECT SDN_NAME, ISNULL(REMARKS,'') SDN_REMARKS,ISNULL(ALT_TYPE,'') ALT_TYPE,ISNULL(ALT_NAME,'') ALT_NAME, ISNULL(ALT_REMARKS,'') ALT_REMARKS,isnull(ADDRESS,'') ADD_ADDRESS,isnull(CITY_NAME,'') ADD_CITY_NAME,isnull(COUNTRY,'') ADD_COUNTRY,isnull(ADD_REMARKS,'') ADD_REMARKS 
				FROM OFAC_SDN with(nolock)
                LEFT join OFAC_ALT with(nolock) ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM
                LEFT JOIN OFAC_ADD with(nolock) ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
                WHERE OFAC_SDN.ENT_NUM in (select ent_num from @EntNum)
            end
            else
            begin
				IF @UseMaxiOFAC = 1
				BEGIN
					EXEC st_MaxiOFACValidateEntity
						@Name,
						@FirstLastName,
						@SecondLastName,
						@Percent	OUT,
						@FullMatch	OUT,
						@XMLResult	OUT

					INSERT INTO @MatchDetail
					SELECT 
						SDN_NAME, 
						ISNULL(SDN_REMARKS,''),
						ISNULL(ALT_TYPE,''),
						ISNULL(ALT_NAME,''),
						ISNULL(ALT_REMARKS,''),
						ISNULL(ADD_ADDRESS,''),
						ISNULL(ADD_CITY_NAME,''),
						ISNULL(ADD_COUNTRY,''),
						ISNULL(ADD_REMARKS,'')
					FROM dbo.fnMaxiOFACParseXML(@XMLResult)
				END
				ELSE
				BEGIN
					insert into @MatchDetail
					exec dbo.ST_OFAC_SEARCH_DETAILS @Name,@FirstLastName,@SecondLastName;
				END
            end
        end

		/*if (exists(select 1 from @MatchDetail))
			Begin
				set @IdOfacAuditStatus =@IdOfacAuditStatusPossibleMatch
			End
		Else
			Begin
				set @IdOfacAuditStatus =@IdOfacAuditStatusNoMatch
			End		
		*/

		declare @ExecutionIdUser2 int = null
		if (@IdOfacAuditStatus in (3,4))
			set @ExecutionIdUser2 = @ExecutionIdUser

		if not exists(select 1 from OfacAuditDetail with(nolock) where idofacaudit=@IdOfacAudit and IdOfacAuditType=@IdOfacAuditType and IdGeneric=@IdGeneric)
		begin				
			INSERT INTO [dbo].[OfacAuditDetail]
			   ([IdOfacAudit]
			   ,[Name]
			   ,[FirstLastName]
			   ,[SecondLastName]
			   ,[IdOfacAuditType]
			   ,[IdOfacAuditStatus]
			   ,[ChangeStatusIdUser]
			   ,[ChangeStatusNote]
			   ,[LastChangeDate]
			   ,[LastChangeNote]
			   ,[LastChangeIP]
			   ,LastChangeIdUser
			   ,AgentCode
			   ,IdGeneric			   
			   )
			VALUES
			   (@IdOfacAudit
			   ,@Name
			   ,@FirstLastName
			   ,@SecondLastName
			   ,@IdOfacAuditType
			   ,@IdOfacAuditStatus
			   ,@ExecutionIdUser2
			   ,@note
			   ,@ExecutionDate
			   ,'Insert'
			   ,@IP
			   ,@ExecutionIdUser
			   ,@AgentCode
			   ,@IdGeneric			   
			   );

			set @IdOfacAuditDetail = Scope_identity();	
		
			INSERT INTO [dbo].[OfacAuditMatch]
			   ([IdOfacAuditDetail]
			   ,[sdn_name]
			   ,[sdn_remarks]
			   ,[alt_type]
			   ,[alt_name]
			   ,[alt_remarks]
			   ,[add_address]
			   ,[add_city_name]
			   ,[add_country]
			   ,[add_remarks])
			select 
				@IdOfacAuditDetail,
  				[sdn_name],
				[sdn_remarks],
				[alt_type],
				[alt_name],
				[alt_remarks],
				[add_address],
				[add_city_name] ,
				[add_country] ,
				[add_remarks]
			from @MatchDetail;
		end		
		
		delete @NameList where Id=@Id;
		set @Id = null;
		select top 1
			@Id= Id,
			@Name=Name,
			@FirstLastName=FirstLastName,
			@SecondLastName=SecondLastName,
			@IdOfacAuditType = IdOfacAuditType,
            @AgentCode = AgentCode,
            @IdGeneric = IdGeneric
		from @NameList 
		order by Id;
	End	 
End try
begin catch
	declare @errormessage varchar(max) = error_message();
	insert into dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) Values('st_OfacAuditForAgent', GETDATE(), @errormessage)
end catch

