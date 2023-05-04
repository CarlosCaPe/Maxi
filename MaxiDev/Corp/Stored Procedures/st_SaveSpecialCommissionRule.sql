CREATE PROCEDURE [Corp].[st_SaveSpecialCommissionRule]
@IdSpecialCommissionRule int out,
@IdUserRequestedBy int,
@IdUserAuthorizer int,
@Description varchar(max),
@Note varchar(max),
@BeginDate date,
@EndDate date,
@IdAgent int,
@IdCountry int,
@IdOwner int,
@ApplyForTransaction bit,
@Accumulated bit,
@IdGenericStatus int,
@Detail XML,
@IdUserAuthorizedBy int,
@Countries XML,
@EnterByIdUser int,    
@IdLenguage int,    
@HasError bit out,    
@ResultMessage nvarchar(max) out    

AS

/********************************************************************
<Author> Unknown </Author>
<app> Corporativo </app>
<Description> Inserta o Actualiza Reglas de Comisiones Especiales </Description>

<ChangeLog>
<log Date="15/09/2022" Author="cgarcia">MP-1208 - Se agrega logica para determinar si es Insert o Update, y se agrega iniciales del pais a las notas</log>
<log Date="04/10/2022" Author="cgarcia">MP-1208 - Fix - Se agrega guardado de Paises en tabla de relacion con SpecialCommissionRule</log> 
</ChangeLog>

*********************************************************************/

--Inicializar Variables
Set @HasError=0
Select @ResultMessage = dbo.[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SpecialCommissionOK')   

BEGIN TRY

		set @IdSpecialCommissionRule =isnull(@IdSpecialCommissionRule,0)

		IF (@IdSpecialCommissionRule=0)
			BEGIN
				INSERT INTO [dbo].[SpecialCommissionRule]
						   ([IdUserRequestedBy]
						   ,[IdUserAuthorizer]
						   ,[IdUserAuthorizedBy]
						   ,[Description]
						   ,[Note]
						   ,[BeginDate]
						   ,[EndDate]
						   ,[IdAgent]
						   ,[IdCountry]
						   ,[IdOwner]
						   ,[ApplyForTransaction]
						   ,[IdGenericStatus]						   
						   ,[DateOfLastChange]
						   ,[EnterByIdUser]
						   ,[Accumulated])
					 VALUES
						   (@IdUserRequestedBy
						   ,@IdUserAuthorizer
						   ,@IdUserAuthorizedBy
						   ,@Description
						   ,@Note
						   ,@BeginDate
						   ,@EndDate
						   ,@IdAgent
						   ,@IdCountry
						   ,@IdOwner
						   ,@ApplyForTransaction
						   ,@IdGenericStatus
						   ,getDate()
						   ,@EnterByIdUser
						   ,@Accumulated)
				set @IdSpecialCommissionRule= scope_identity()
			END
		ELSE
			BEGIN
				UPDATE [dbo].[SpecialCommissionRule]
				   SET 
						[IdUserRequestedBy] = @IdUserRequestedBy
						,[IdUserAuthorizer]=@IdUserAuthorizer
					  ,[IdUserAuthorizedBy] = @IdUserAuthorizedBy
					  ,[Description] = @Description
					  ,[Note]=@Note
					  ,[BeginDate] = @BeginDate
					  ,[EndDate] = @EndDate
					  ,[IdAgent] = @IdAgent
					  ,[IdCountry] = @IdCountry
					  ,[IdOwner] = @IdOwner
					  ,[ApplyForTransaction]=@ApplyForTransaction
					  ,[IdGenericStatus] = @IdGenericStatus					  
					  ,[DateOfLastChange] = getDate()
					  ,[Accumulated]= @Accumulated
				 WHERE IdSpecialCommissionRule=@IdSpecialCommissionRule

				 DELETE [dbo].[SpecialCommissionRuleRanges] WHERE IdSpecialCommissionRule=@IdSpecialCommissionRule
				 DELETE [Corp].[SpecialCommissionRuleRelCountry] WHERE IdSpecialCommissionRule = @IdSpecialCommissionRule
			END
					
			DECLARE @DocHandle INT
			EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Detail 
			INSERT INTO [dbo].[SpecialCommissionRuleRanges]
				   ([IdSpecialCommissionRule]
				   ,[Commission]
				   ,[Goal]
				   ,[From]
				   ,[To]
				   ,[DateOfLastChange]
				   ,[EnterByIdUser])
			SELECT @IdSpecialCommissionRule,Commission, Goal,[From], [To], getDate(),@EnterByIdUser From OPENXML (@DocHandle, '/root/Detail',2) 
			WITH (      
				Commission MONEY ,
				Goal	INT,
				[From]	INT,
				[To]		Int
			)
			EXEC sp_xml_removedocument @DocHandle 
			
			
			
			EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Countries 
			INSERT INTO [Corp].[SpecialCommissionRuleRelCountry]
			 	(IdSpecialCommissionRule
			 	,IdCountry
			 	,CreationDate
			 	,EnterByIdUser)
			SELECT @IdSpecialCommissionRule, IdCountry, getdate(), @EnterByIdUser FROM OPENXML (@DocHandle, '/root/Country', 2)
			WITH (				
				IdCountry INT
				)
			EXEC sp_xml_removedocument @DocHandle 



			DECLARE @IdLog int

			INSERT INTO [dbo].[SpecialCommissionRuleLog]
					   ([IdSpecialCommissionRule]
					   ,[IdUserRequestedBy]
					   ,[IdUserAuthorizer]
					   ,[IdUserAuthorizedBy]
					   ,[Description]
					   ,[Note]
					   ,[BeginDate]
					   ,[EndDate]
					   ,[IdAgent]
					   ,[IdCountry]
					   ,[IdOwner]
					   ,[ApplyForTransaction]
					   ,[IdGenericStatus]
					   ,[DateOfLastChange]
					   ,[EnterByIdUser])
			SELECT [IdSpecialCommissionRule]
				  ,[IdUserRequestedBy]
				  ,[IdUserAuthorizer]
				  ,[IdUserAuthorizedBy]
				  ,[Description]
				  ,[Note]
				  ,[BeginDate]
				  ,[EndDate]
				  ,[IdAgent]
				  ,[IdCountry]
				  ,[IdOwner]
				  ,[ApplyForTransaction]
				  ,[IdGenericStatus]
				  ,[DateOfLastChange]
				  ,@EnterByIdUser
			  FROM [dbo].[SpecialCommissionRule]
				WHERE IdSpecialCommissionRule=@IdSpecialCommissionRule
		
			set @IdLog =SCOPE_IDENTITY();

			INSERT INTO [dbo].[SpecialCommissionRuleRangesLog]
					   ([IdLog]
					   ,[IdSpecialCommissionRuleRange]
					   ,[IdSpecialCommissionRule]
					   ,[Commission]
					   ,[Goal]
					   ,[From]
					   ,[To]
					   ,[DateOfLastChange]
					   ,[EnterByIdUser])
			SELECT 
					@IdLog
				  ,[IdSpecialCommissionRuleRange]
				  ,[IdSpecialCommissionRule]
				  ,[Commission]
				  ,[Goal]
				  ,[From]
				  ,[To]
				  ,[DateOfLastChange]
				  ,[EnterByIdUser]
			  FROM [dbo].[SpecialCommissionRuleRanges]
				WHERE IdSpecialCommissionRule=@IdSpecialCommissionRule




END TRY

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @ResultMessage = dbo.[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SpecialCommissionE')                                                                              
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveSpecialCommissionRule]',Getdate(),@ErrorMessage)    
END CATCH

