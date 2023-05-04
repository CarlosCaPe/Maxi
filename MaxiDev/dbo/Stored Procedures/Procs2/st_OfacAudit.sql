
CREATE procedure [dbo].[st_OfacAudit]
@ExecutionIdUser int = null,
@IP varchar(15) = '127.0.0.1'
as
Begin

	DECLARE @UseMaxiOFAC		BIT = 0,
			@UseMaxiOFACEntity	BIT = 0

	IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatch' AND ga.Value = '1')
		SET @UseMaxiOFAC = 1

	IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatchWithEntity' AND ga.Value = '1')
		SET @UseMaxiOFACEntity = 1

	declare @IdAgentStatusDisable int
	set @IdAgentStatusDisable = 2

    declare @IdAgentStatusWOff int
	set @IdAgentStatusWOff = 6

	declare @IdGenericStatusDisable int
	set @IdGenericStatusDisable=2

	declare @NameList table
	(
		Id int identity(1,1),
		Name nvarchar(max),
		FirstLastName nvarchar(max),
		SecondLastName nvarchar(max),
		IdOfacAuditType int,
        AgentCode nvarchar(max),
        IdGeneric int
	)
	
	declare @UserListTemp table
	(
		Name nvarchar(max),
		FirstLastName nvarchar(max),
		SecondLastName nvarchar(max),
		IdOfacAuditType int,
        IdGeneric int
	)

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
	)
	
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
	declare @IdOfacAuditDetail int, @IdOfacAuditStatus int, @IdOfacAuditStatusNoMatch int, @IdOfacAuditStatusPossibleMatch int
	set @ExecutionDate = getDate()
	set @IdOfacAuditStatusNoMatch=1
	set @IdOfacAuditStatusPossibleMatch =2
	
    /*
	select 
		U.IdUser,
		LTRIM(RTRIM(U.UserName)) UserName,
		U.IdUserType
	into #UsersTemp
	from dbo.Users U with (nolock)
		where U.IdGenericStatus!=@IdGenericStatusDisable
			and U.IdUser not in (select IdUser from dbo.AgentUser with (nolock))
			
	select Top 1
		@IdUser =T.IdUser,
		@UserName=T.UserName,
		@IdUserType=T.IdUserType
	from #UsersTemp T
	
	while (@IdUser is not null)
	Begin
		insert into @UserListTemp (Name,FirstLastName,SecondLastName,IdOfacAuditType,IdGeneric)
		select Name
			,FirstLastName
			,SecondLastName
			,case
				when @IdUserType=1 then 1--Corporative
				when @IdUserType=2 then 3--Multiagent
				when @IdUserType=3 then 2--Seller
			end Type,
            @IdUser
			from dbo.fnMixTable(@UserName,' ')
		
		delete #UsersTemp where IdUser=@IdUser
		set @IdUser = null
		select Top 1
			@IdUser =T.IdUser,
			@UserName=T.UserName,
			@IdUserType=T.IdUserType
		from #UsersTemp T
	End
    */

    insert into @UserListTemp (Name,FirstLastName,SecondLastName,IdOfacAuditType,IdGeneric)
    select  FirstName,
            LastName,
            SecondLastName,
            case
				when IdUserType=1 then 1--Corporative
				when IdUserType=2 then 3--Multiagent
				when IdUserType=3 then 2--Seller
			end,
            iduser
    from users u
    where U.IdGenericStatus!=@IdGenericStatusDisable
			and U.IdUser not in (select IdUser from dbo.AgentUser with (nolock))
	
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
			select 
				Name,
				FirstLastName,
				SecondLastName,
				IdOfacAuditType Type,
                '' AgentCode,
                IdGeneric
			from @UserListTemp
		union
			select o.Name Name,
				o.LastName FirstLastName,
				o.SecondLastName SecondLastName,
				4 Type,	--Agent Owner
                A.AgentCode,
                o.idowner IdGeneric
			from dbo.Agent A with (nolock)
			join owner o on a.idowner=o.idowner
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff
		union
			select 
				A.GuarantorName Name,
				A.GuarantorLastName FirstLastName, 
				A.GuarantorSecondLastName SecondLastName,
				5 Type,	--Agent Guarantor
                A.AgentCode,
                a.idagent IdGeneric
			from dbo.Agent A with (nolock)
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff
		union
			select A.AgentName Name,
				'' FirstLastName,
				'' SecondLastName,
				6 Type,	--Agent
                A.AgentCode,
                a.idagent IdGeneric
			from dbo.Agent A with (nolock)
				where A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff
        union
            select DoingBusinessAs Name,
				'' FirstLastName,
				'' SecondLastName,
				7 Type,	--DBA
                A.AgentCode,
               a.idagent IdGeneric
            from agent A where isnull(DoingBusinessAs,'')!=''and
                A.IdAgentStatus!=@IdAgentStatusDisable and A.IdAgentStatus!=@IdAgentStatusWOff
	)L
	order by Name, FirstLastName,  SecondLastName
	
	--TEMP
	--select * from @NameList

	delete @NameList where (RTRIM(LTRIM(Name)) ='' or LEN((RTRIM(LTRIM(Name))))<2 or Name is null) and (RTRIM(LTRIM(FirstLastName)) ='' or LEN((RTRIM(LTRIM(FirstLastName))))<2 or FirstLastName is null)
							 
	--TEMP
	--select * from @NameList 

	INSERT INTO [dbo].[OfacAudit]
           ([ExecutionDate]
           ,[IdUser])
     VALUES
           (@ExecutionDate
           ,@ExecutionIdUser)		 
	set @IdOfacAudit = Scope_identity()

	--TEMP 
	--select * from [OfacAudit] where IdOfacAudit= @IdOfacAudit

	select top 1
		@Id= Id,
		@Name=Name,
		@FirstLastName=FirstLastName,
		@SecondLastName=SecondLastName,
		@IdOfacAuditType = IdOfacAuditType,
        @AgentCode = AgentCode,
        @IdGeneric = IdGeneric
	from @NameList 
	order by Id

	select * from @NameList
    declare @EntNum table
    (
        ent_num bigint
    )

	DECLARE @XMLResult	XML,
			@FullMatch	BIT,
			@Percent	FLOAT
	
	While (@Id is not null)
	Begin
		print(@Id)
		set @IdOfacAuditDetail= null
		set @IdOfacAuditStatus = null
		delete @MatchDetail
        delete @EntNum

		SELECT	@XMLResult = NULL,
				@FullMatch = NULL,
				@Percent = NULL
		
		--TEMP
		--select @Id Id,
		--@Name Name,
		--@FirstLastName FirstLastName,
		--@SecondLastName SecondLastName,
		--@IdOfacAuditType   IdOfacAuditType

		IF (@IdOfacAuditType in (6,7))
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
				exec dbo.ST_OFAC_SEARCH_DETAILS @Name,@FirstLastName,@SecondLastName
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
                SELECT SDN_NAME, ISNULL(REMARKS,'') SDN_REMARKS,ISNULL(ALT_TYPE,'') ALT_TYPE,ISNULL(ALT_NAME,'') ALT_NAME, ISNULL(ALT_REMARKS,'') ALT_REMARKS,isnull(ADDRESS,'') ADD_ADDRESS,isnull(CITY_NAME,'') ADD_CITY_NAME,isnull(COUNTRY,'') ADD_COUNTRY,isnull(ADD_REMARKS,'') ADD_REMARKS FROM OFAC_SDN
                LEFT join OFAC_ALT ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM
                LEFT JOIN OFAC_ADD ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
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
					exec dbo.ST_OFAC_SEARCH_DETAILS @Name,@FirstLastName,@SecondLastName
				END
            end
        end

		if (exists(select 1 from @MatchDetail))
			Begin
				set @IdOfacAuditStatus =@IdOfacAuditStatusPossibleMatch
			End
		Else
			Begin
				set @IdOfacAuditStatus =@IdOfacAuditStatusNoMatch
			End
				
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
           ,null
           ,null
           ,@ExecutionDate
           ,'Insert'
           ,@IP
           ,@ExecutionIdUser
           ,@AgentCode
           ,@IdGeneric
           )

		set @IdOfacAuditDetail = Scope_identity()	
		
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
		from @MatchDetail
		
		delete @NameList where Id=@Id
		set @Id = null
		select top 1
			@Id= Id,
			@Name=Name,
			@FirstLastName=FirstLastName,
			@SecondLastName=SecondLastName,
			@IdOfacAuditType = IdOfacAuditType,
            @AgentCode = AgentCode,
            @IdGeneric = IdGeneric
		from @NameList 
		order by Id
		
		--TEMP 
		--select * from [OfacAuditDetail] where IdOfacAuditDetail= @IdOfacAuditDetail		
		--select * from [OfacAuditMatch] where IdOfacAuditDetail= @IdOfacAuditDetail		
						
		--TEMP
		--if( @id>59)
		--Begin
		--	return
		--End
	End
	 
End