CREATE PROCEDURE [Corp].[st_UpdateGroupAgentSeller_Collection]
(
	@GroupName VARCHAR(max),
	@XmlGroups XML = NULL ,
	@IdGroupEdit INT = 0, -- 0: Nuevo, !0 : Modificar
	@EnterByIdUser int,
    @HasError bit out,
	@Message varchar(max) out
)
AS
/********************************************************************
<Author>SNevarez</Author>
<app>MaxiCorp</app>
<Description>Create Groups Agents</Description>

<ChangeLog>
	<log Date="15/03/2017" Author="SNevarez">s20_17 :: Create </log>
	<log Date="23/03/2017" Author="mdelgado">s20_17 :: Fix to insert info into agentGroup </log>
	<log Date="30/05/2017" Author="SNevarez">Se ajusta la consulta para excluir agencias</log>
	<log Date="30/05/2017" Author="Fgonzalez">Creacion2</log>
	<log Date="28/07/2020" Author="jzuñiga">Modificación para guardar por agencias (Requerimiento M00094)</log>
</ChangeLog>
********************************************************************/
BEGIN TRY


	SET NOCOUNT ON;	
	DECLARE @CreationDate DATETIME = GETDATE();
	DECLARE @idAgentClass INT, @IsSpecialCategory BIT  

	DECLARE @cnt INT = 0;
	DECLARE @idSeller INT = 0;

	DECLARE @XMLMessage varchar(max);
	SET @XMLMessage = CONVERT(varchar(max), @XmlGroups);

	DECLARE @DocHandle int;
	DECLARE @XmlTable Table
	(
		Id INT IDENTITY(1,1) NOT NULL,		
		StateCode NVARCHAR(150),    
		IsSpecialCategory  bit,
		IdAgentClass INT,
		IdSeller INT,
		IdAgent INT,
		AgentCode NVARCHAR(25),
		AgentName NVARCHAR(MAX)
	);


	SET @HasError = 0;
	SET @Message ='';


   IF (@XmlGroups IS NOT NULL ) BEGIN 
   
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlGroups;
	
		/*------------*/
		DECLARE @XmlText varchar(max);
	
	
		INSERT INTO @XmlTable (StateCode, IsSpecialCategory, IdAgentClass, IdSeller, IdAgent, AgentCode, AgentName)
		SELECT 
		StateCode,IsSpecialCategory, IdAgentClass,IdSeller, IdAgent, AgentCode, AgentName
		FROM OPENXML (@DocHandle, 'ArrayOfCollectionGroupAllDto/CollectionGroupAllDto',2)    
		WITH (    
		StateCode nvarchar(150) 		
		,IsSpecialCategory bit 
		,IdAgentClass INT
		,IdSeller INT
		,IdAgent INT
		,AgentCode NVARCHAR(25)
		,AgentName NVARCHAR (MAX)
		)
		where isnull(StateCode,'')!='';
	END 

	IF @IdGroupEdit > 0 BEGIN 
		
		IF EXISTS (SELECT * FROM Collection.Groups WITH(NOLOCK) WHERE groupName=@GroupName AND IdGroups != @IdGroupEdit and idgenericstatus=1) BEGIN
		  SET @HasError =1
		  SET @Message ='Group name already belongs to another group'
		RETURN 0;
		END 
	
		IF NOT EXISTS (SELECT 1 FROM @XmlTable) BEGIN 
		 SET @HasError =1
		  SET @Message ='Theres no data to edit'
		RETURN 0;
		END 
		 
	 	SELECT TOP 1 @IsSpecialCategory=IsSpecialCategory, @idAgentClass=IdAgentClass FROM @XmlTable
	 	
	    UPDATE Collection.Groups
	    SET groupName=isnull(@GroupName,groupName),
	    	DateOfLastChange = @CreationDate,
	    	EnterByIdUser = @EnterByIdUser,
	    	IdAgentClass = isnull(@idAgentClass,IdAgentClass),
	    	IsSpecial = isnull(@IsSpecialCategory,IsSpecial)
	    WHERE idGroups= @IdGroupEdit
	
		DELETE FROM Collection.GroupsDetail WHERE idGroups = @IdGroupEdit
		
		--INSERT INTO Collection.GroupsDetail (idGroups,Statecode,idSalesRep)            --M00094
		--SELECT @IdGroupEdit,Statecode,IdSeller FROM @XmlTable where StateCode !=''

		WHILE @cnt < (SELECT COUNT(*) FROM @XmlTable)    --M00094
		BEGIN   
			SET @idSeller = (SELECT IdSeller FROM @XmlTable WHERE Id = @cnt + 1)

			INSERT INTO Collection.GroupsDetail (idGroups, Statecode, idSalesRep, AgentCode)
			SELECT @IdGroupEdit, Statecode, @idSeller, AgentCode FROM @XmlTable WHERE Id = @cnt + 1

			SET @cnt = @cnt + 1;
		END;

		INSERT INTO dbo.LogUserAssigment
				(
				IdUserAssigment,
				IdGroup, 
				IdUserLastChange,
				Nota,
				LastChangeDate,
				TypeChange
				)
			VALUES 
				(
				0,
				@IdGroupEdit, 
				@EnterByIdUser,
				'Edited Group',
				getdate(),
				'Edit'
				)

	
	END ELSE BEGIN 
	
		IF EXISTS (SELECT 1 FROM Collection.Groups WITH(NOLOCK) WHERE groupName=@GroupName and idgenericstatus=1) BEGIN
		  SET @HasError = 1
		  SET @Message = 'Group name already belongs to another group'
		  RETURN 0;
		END 
	
		IF NOT EXISTS (SELECT * FROM @XmlTable) BEGIN 
		  SET @HasError = 1
		  SET @Message = 'Theres no data to create'
		RETURN 0;
		END 
		 
		SELECT TOP 1 @IsSpecialCategory = IsSpecialCategory, @idAgentClass = IdAgentClass FROM @XmlTable
	 	
		INSERT INTO Collection.Groups (groupName, DateOfLastChange, EnterByIdUser, IdGenericStatus, IdUserAssign, IsSpecial, IdAgentClass)
		VALUES (@GroupName, @CreationDate, @EnterByIdUser, 1, NULL, @IsSpecialCategory, @idAgentClass)
		
		SELECT @IdGroupEdit = idGroups FROM Collection.Groups WITH(NOLOCK) WHERE groupName =@GroupName 
		
		DELETE FROM Collection.GroupsDetail WHERE idGroups =@IdGroupEdit
		
		--INSERT INTO Collection.GroupsDetail (idGroups,Statecode,idSalesRep)							 --M00094
		--SELECT @IdGroupEdit,Statecode,IdSeller FROM @XmlTable where StateCode !='' GROUP BY IdSeller

		WHILE @cnt < (SELECT COUNT(*) FROM @XmlTable)		--M00094
		BEGIN   
			SET @idSeller = (SELECT IdSeller FROM @XmlTable WHERE Id = @cnt + 1)

			INSERT INTO Collection.GroupsDetail (idGroups, Statecode, idSalesRep, AgentCode)
			SELECT @IdGroupEdit,Statecode,@idSeller, AgentCode FROM @XmlTable WHERE Id = @cnt + 1

			SET @cnt = @cnt + 1;
		END;

		INSERT INTO dbo.LogUserAssigment
				(
				IdUserAssigment,
				IdGroup, 
				IdUserLastChange,
				Nota,
				LastChangeDate,
				TypeChange
				)
			VALUES 
				(
				0,
				@IdGroupEdit, 
				@EnterByIdUser,
				'Group Created',
				getdate(),
				'Create'
				)

	
	END 


END TRY
BEGIN CATCH
	SET @HasError = 1;
	DECLARE @ErrorMessage nvarchar(max);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Collection.st_UpdateGroupAgentSeller',Getdate(),@ErrorMessage);
END CATCH