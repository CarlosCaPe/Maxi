CREATE procedure [Corp].[st_SavePayerConfig]      
@IdPayerConfig int,      
@IdPayer int,      
@IdGateway int,      
@IdPaymentType int,      
@IdCountryCurrency int,      
@IdGenericStatus int,      
@SpreadValue money,      
@EnterByIdUser int,      
@RequireBranch bit,      
@DepositHold bit,      
@IsSpanishLanguage bit,      
@HasError bit out,      
@ResultMessage nvarchar(max) out,
@IdBasePayerConfig INT,
@IsEnabledSchedule BIT = 0,
@StartTime NVARCHAR(8) = NULL,
@EndTime NVARCHAR(8) = NULL,
@BenCellPhoneIsRequired BIT = 0 ,
@BranchCodeIsRequired BIT = 0
as      
/********************************************************************
<Author>Not Known</Author>
<app>MaxiRefactoryCorp</app>
<Description></Description>

<ChangeLog>
<log Date="12/09/2017" Author="mhinojo">S38_2017: save log info</log>
<log Date="12/12/2018" Author="jmmolina">Add with(nolock)</log>
<log Date="07/05/2019" Author="jmmolina">Se agrega el campo [EnterByIdUser] en update a PayerConfig</log>
<log Date="28/07/2020" Author="jgomez"> Se agrega columna BenCellPhoneIsRequired </log>
<log Date="31/08/2020" Author="adominguez"> Se agrega columna BranchCodeIsRequired </log>
</ChangeLog>
********************************************************************/
declare @IdGenericStatusEnable int      
set @IdGenericStatusEnable =1 --Enable      
declare @IdGenericStatusDisable int      
set @IdGenericStatusDisable =2 --Disable      

DECLARE @Start AS TIME = NULL
DECLARE @End AS TIME = NULL

Begin try      
  if(@IdGenericStatus=@IdGenericStatusEnable and    
  exists(select 1 from dbo.PayerConfig with(nolock) where IdPayer=@IdPayer and IdPaymentType=@IdPaymentType and IdCountryCurrency=@IdCountryCurrency and IdGenericStatus=@IdGenericStatusEnable and (@IdPayerConfig=0 or IdPayerConfig<>@IdPayerConfig)))      
  Begin      
   set @HasError =1      
   set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,23)      
   return      
  End      
      
  if @IdPayerConfig<>0 and exists(select 1 from dbo.PayerConfig with(nolock) where IdPayerConfig =@IdPayerConfig )      
   Begin       
		/* S38: Log Payer Config */
		DECLARE @LastStart AS TIME
		DECLARE @LastEnd AS TIME
		SELECT @LastStart = StartTime, @LastEnd = EndTime FROM PayerConfig with(nolock) WHERE IdPayerConfig = @IdPayerConfig
		IF @IsEnabledSchedule = 0
		BEGIN
			SELECT @Start = NULL, @End = NULL
			IF @LastStart IS NOT NULL OR @LastEnd IS NOT NULL
				INSERT INTO [MAXI_LOG].[dbo].PayerConfigScheduleLog (DateOfChange, IdUserWhoEdited, IdPayerConfig, StartTime, EndTime) VALUES (GETDATE(), @EnterByIdUser, @IdPayerConfig, @Start, @End)
		END
		ELSE
		BEGIN
			SET @Start = CONVERT(TIME, @StartTime)
			SET @End = CONVERT(TIME, @EndTime)
			IF (@LastStart IS NULL OR @LastEnd IS NULL OR @LastStart <> @StartTime OR @LastEnd <> @EndTime)
				INSERT INTO [MAXI_LOG].[dbo].PayerConfigScheduleLog (DateOfChange, IdUserWhoEdited, IdPayerConfig, StartTime, EndTime) VALUES (GETDATE(), @EnterByIdUser, @IdPayerConfig, @Start, @End)
		END
		/* S38: Log Payer Config */

		UPDATE [dbo].[PayerConfig]      
		   SET       
		   [IdGenericStatus] = @IdGenericStatus      
		   ,[SpreadValue] = @SpreadValue      
		   ,[DateOfLastChange] = getDate()
		   ,[RequireBranch] = @RequireBranch
		   ,[EnterByIdUser] = @EnterByIdUser
		   ,[DepositHold] = @DepositHold      
		   ,[EnabledSchedule] = @IsEnabledSchedule
		   ,[StartTime] = case when @IsEnabledSchedule=1 then  @StartTime else null end
		   ,[EndTime] = case when @IsEnabledSchedule=1 then  @EndTime else null end
		   ,[BenCellPhoneIsRequired] = @BenCellPhoneIsRequired
		   ,[BranchCodeIsRequired] = @BranchCodeIsRequired
		 WHERE IdPayerConfig=@IdPayerConfig      
   End      
  else      
   BEGIN
		IF @IsEnabledSchedule = 1
		BEGIN
			SET @Start = CONVERT(TIME, @StartTime)
			SET @End = CONVERT(TIME, @EndTime)
		END
        INSERT INTO [dbo].[PayerConfig]      
        ([IdPayer]      
        ,[IdGateway]      
        ,[IdPaymentType]      
        ,[IdCountryCurrency]      
        ,[IdGenericStatus]      
        ,[SpreadValue]      
        ,[DateOfLastChange]      
        ,[EnterByIdUser]      
        ,[RequireBranch]      
        ,[DepositHold]
		,[EnabledSchedule]
		,[StartTime]
		,[EndTime]
		,[BenCellPhoneIsRequired])      
        VALUES      
        (@IdPayer      
        ,@IdGateway      
        ,@IdPaymentType      
        ,@IdCountryCurrency      
        ,@IdGenericStatus      
        ,@SpreadValue      
        ,GETDATE()      
        ,@EnterByIdUser      
        ,@RequireBranch      
        ,@DepositHold
		,@IsEnabledSchedule
		,@Start
		,@End
		,@BenCellPhoneIsRequired)      
        
		
		
             ----------------------------  Inserta en las tablas de AgentSchemaDetail, con el spread que más ocurra en cada Schema ----------------  
          
             Declare @SystemUserID INT
                    ,@NewIdPayerConfig INT
                    ,@Date DATETIME
                      
             SELECT @SystemUserID=dbo.GetGlobalAttributeByName ('SystemUserID')  
             SET @NewIdPayerConfig =SCOPE_IDENTITY()
             SET @Date= GETDATE()  

			 /* S38: Log Payer Config */
			 IF (@IsEnabledSchedule = 1)
				INSERT INTO [MAXI_LOG].[dbo].PayerConfigScheduleLog (DateOfChange, IdUserWhoEdited, IdPayerConfig, StartTime, EndTime) 
				VALUES (GETDATE(), @EnterByIdUser, @NewIdPayerConfig, @StartTime, @EndTime)
			 /* S38: Log Payer Config */


             INSERT AgentSchemaDetail
             (
             IdAgentSchema
             , IdPayerConfig
             , SpreadValue
             , DateOfLastChange
             , EnterByIdUser
             , IdFee
             , IdCommission
             , TempSpread
             , EndDateTempSpread
             , IdSpread
             )
             SELECT ASD.IdAgentSchema, @NewIdPayerConfig, 0, GETDATE(), @SystemUserID, NULL, NULL, NULL, NULL, NULL
             FROM AgentSchema A (NOLOCK)
                    JOIN AgentSchemaDetail ASD (NOLOCK) ON A.IdAgentSchema = ASD.IdAgentSchema
             WHERE A.IdCountryCurrency =  @IdCountryCurrency
             GROUP BY ASD.IdAgentSchema

             UPDATE ASD
             SET ASD.SpreadValue = ASDB.SpreadValue
             , ASD.IdFee = ASDB.IdFee
             , ASD.IdCommission = ASDB.IdCommission 
             , ASD.TempSpread = ASDB.TempSpread
             , ASD.EndDateTempSpread = ASDB.EndDateTempSpread
             , ASD.[IdSpread] = ASDB. [IdSpread]  
             FROM AgentSchemaDetail ASD with(nolock)
                    JOIN AgentSchemaDetail ASDB with(nolock) ON ASD.IdAgentSchema=ASDB.IdAgentSchema
             WHERE ASD.IdPayerConfig=@NewIdPayerConfig
                    AND ASDB.IdPayerConfig=@IdBasePayerConfig
         
   END       
        
  set @HasError =0      
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,22)      
End try      
Begin Catch      
   Declare @ErrorMessage nvarchar(max)               
   Select @ErrorMessage=ERROR_MESSAGE()              
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SavePayerConfig]',Getdate(),@ErrorMessage)       
  set @HasError =1      
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,21)      
        
End catch      
      
return;


