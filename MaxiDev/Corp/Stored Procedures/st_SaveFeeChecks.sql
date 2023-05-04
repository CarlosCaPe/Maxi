CREATE PROCEDURE [Corp].[st_SaveFeeChecks]
(
    @IdFee int, 
    @IdAgent int,
	@AllowChecks bit,
	@FeeName nvarchar(max),
	@TransactionFee money,
	@ReturnCheckFee money,
	@EnterByIdUser int,
	@FeeChecksDetails XML, 
    @IsSpanishLanguage INT,
	@FeeCheckScanner money,
    @IdFeeOut int output,        
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
  , @IsReimburse 				  bit
	, @GoalReimburse        int
	,@ApplyKYCRules bit    --M00248
)
as
/********************************************************************
<Author> Unknown </Author>
<app> Corporate </app>
<Description> Saves Fee amount for checks from Agent Detail </Description>

<ChangeLog>
<log Date="26/05/2017" Author="Fgonzalez">Validacion para no hacer nada si el @EnterByIdUser no tiene permisos en cheques</log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="28/09/2020" Author="bortega">Agregar parametro ApplyKYCRules Ref :: M00248</log>
<log Date="15/09/2022" Author="cgarcia">MP-1247 - Fix - 	Cambio de IDOption para que tome permiso de Cronos</log>
<log Date="29/09/2022" Author="cgarcia">INC-5036 - Fix - 	Cambio de IDOption a Nombre de Opcion 'Agent_Cronos' para que tome permiso de Cronos</log>
</ChangeLog>

*********************************************************************/
SET NOCOUNT ON;

--declaracion de variables
declare @IdFeeChecksDetail int,
@FromAmount money,
@ToAmount money,
@Fee money,
@IsFeePercentage BIT

SET @IdFeeOut = 0





IF(@AllowChecks = 0)
BEGIN
		DELETE FROM AgentChecks WHERE IdAgent = @IdAgent;
END
ELSE
BEGIN
	IF(NOT EXISTS (SELECT 1 FROM AgentChecks with(nolock) WHERE IdAgent = @IdAgent))
	BEGIN

	 INSERT INTO AgentChecks ([IdAgent], [IdChecksModulo]) VALUES (@IdAgent, 1);
	 INSERT INTO AgentChecks ([IdAgent], [IdChecksModulo]) VALUES (@IdAgent, 2);
	 INSERT INTO AgentChecks ([IdAgent], [IdChecksModulo]) VALUES (@IdAgent, 3);
	
	END
END

DECLARE @DocHandle INT 
    
create table #FeeChecksDetail
(
    --IdFeeChecksDetail int identity (1,1),
    FromAmount money,
    ToAmount money,
    Fee money,
    IsFeePercentage bit,
	IdFeeChecksDetail int
);

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,77)   

BEGIN TRY

--update ApplyKYCRules //M00248
UPDATE Agent SET ApplyKYCRules = @ApplyKYCRules where IdAgent = @IdAgent

declare 
 @StatusActive int 
 , @SaveIsnert bit


set @SaveIsnert = 0

--#FGONZALEZ
DECLARE @CanSetChecksInfo BIT = 0

SELECT @CanSetChecksInfo =  CASE WHEN Patindex('%CH%',[Action]) > 0 THEN 1 ELSE 0 END 
FROM dbo.OptionUsers AS OU WITH (NOLOCK) 
INNER JOIN dbo.[Option] AS O WITH (NOLOCK) ON OU.IdOption = O.IdOption
WHERE O.[Name] = 'Agent_Cronos' 
AND IdUser = @EnterByIdUser;

 
IF (@CanSetChecksInfo = 1) BEGIN 

 
if not exists(
 select 
  * 
 from 
  AgentReimburseConfig with(nolock)
 where 
  IdAgent  = @IdAgent
  and StatusActive=1
  and Goal =@GoalReimburse

)

begin


 update 
   dbo.AgentReimburseConfig
  set StatusActive = 0
 where 
	IdAgent = @IdAgent;


if   @IsReimburse= 1
	begin 
   set  @StatusActive=1
	end 
if   @IsReimburse=0
	begin 
   set @StatusActive=0
   set @GoalReimburse=0
  end 



if @IsReimburse = 0
 begin 
 if not exists 
   (  select 
			  1
			from 
			 AgentReimburseConfig with(nolock)
			where 
			 IdAgent=@IdAgent
			 and Goal = 0
			 and IdAgentReimburseConfig =
			                            (select 
																	  max(IdAgentReimburseConfig)
																	 from 
																	  AgentReimburseConfig with(nolock)
																	 where 
																	   IdAgent=@IdAgent                            
		                            )
		 )
	 begin 
	   set @SaveIsnert = 1 
	 end 		 
			 
 end
else   
 begin  
  set @SaveIsnert = 1 
 end
   
  
 if @SaveIsnert=1 
  begin   
		 insert into  
		  dbo.AgentReimburseConfig
					(
						IdAgent,
						Goal,
						DateOfLastChange,
						UserChange,
						StatusActive
					)
					values 
					(
						@IdAgent,
						@GoalReimburse,
						getdate(),
						@EnterByIdUser,
						@StatusActive
					);  
  end
  
end 





	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@FeeChecksDetails 
	
	insert into #FeeChecksDetail
	SELECT FromAmount,ToAmount,Fee,IsFeePercentage, IdFeeChecksDetail From OPENXML (@DocHandle, '/Fee/Detail',2) 
	    WITH (      
	        FromAmount money,
	        ToAmount money,
	        Fee money,
	        IsFeePercentage bit,
			IdFeeChecksDetail int
	    )
	
	EXEC sp_xml_removedocument @DocHandle 
	
	if isnull(@IdFee,0)=0
	begin
	    --insertar fee
	    insert into [dbo].[FeeChecks]
	        (IdAgent, FeeName, TransactionFee, ReturnCheckFee, DateOfLastChange, EnterByIdUser, AllowChecks, FeeCheckScanner)
	    values
	        ( @IdAgent, @FeeName, @TransactionFee, @ReturnCheckFee, getdate(), @EnterByIdUser, @AllowChecks, @FeeCheckScanner);
	
	    SET @IdFeeOut=SCOPE_IDENTITY();
		INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
		VALUES (@IdFeeOut, 'Transaction Fee', @TransactionFee, GETDATE(), @EnterByIdUser);
		INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
		VALUES (@IdFeeOut, 'Return Check Fee', @ReturnCheckFee, GETDATE(), @EnterByIdUser);
		INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
		VALUES (@IdFeeOut, 'Check Scanner Fee', @FeeCheckScanner, GETDATE(), @EnterByIdUser);
	end
	else
	begin
		IF (SELECT TOP 1 1 FROM FeeChecks with(nolock) WHERE IdFeeChecks = @IdFee AND TransactionFee <> @TransactionFee) = 1 
			INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
			VALUES (@IdFee, 'Transaction Fee', @TransactionFee, GETDATE(), @EnterByIdUser);
		IF (SELECT TOP 1 1 FROM FeeChecks with(nolock) WHERE IdFeeChecks = @IdFee AND ReturnCheckFee <> @ReturnCheckFee) = 1 
			INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
			VALUES (@IdFee, 'Return Check Fee', @ReturnCheckFee, GETDATE(), @EnterByIdUser);
		IF (SELECT TOP 1 1 FROM FeeChecks with(nolock) WHERE IdFeeChecks = @IdFee AND FeeCheckScanner <> @FeeCheckScanner) = 1 
			INSERT INTO FeeChecksHistory (IdFeeChecks, FeeType, Fee, DateOfLastChange, EnterByIdUser)
			VALUES (@IdFee, 'Check Scanner Fee', @FeeCheckScanner, GETDATE(), @EnterByIdUser);
	    --actualizar fee
	    UPDATE FeeChecks SET IdAgent=@IdAgent, FeeName=@FeeName, TransactionFee=@TransactionFee, ReturnCheckFee=@ReturnCheckFee, DateOfLastChange=getdate(), EnterByIdUser=@EnterByIdUser, AllowChecks = @AllowChecks, FeeCheckScanner = @FeeCheckScanner
	    WHERE IdFeeChecks=@IdFee;
	
	    SET @IdFeeOut=@IdFee
	
	    --depurar detalles
	    --delete from [dbo].[FeeChecksDetail] where IdFeeChecks=@IdFee
		DELETE FROM [dbo].[FeeChecksDetail] WHERE IdFeeChecks=@IdFee AND IdFeeChecksDetail NOT IN
		(SELECT IdFeeChecksDetail FROM #FeeChecksDetail);
	
	end
	
	
	WHILE exists (select 1 from #FeeChecksDetail)
	BEGIN
	    SELECT TOP 1 @IdFeeChecksDetail=IdFeeChecksDetail,@FromAmount=FromAmount,@ToAmount=ToAmount,@Fee=Fee,@IsFeePercentage=IsFeePercentage from  #FeeChecksDetail
		IF @IdFeeChecksDetail IS NULL
			BREAK
		ELSE
		BEGIN
			IF (SELECT TOP 1 1 FROM  [dbo].[FeeChecksDetail] with(nolock) WHERE IdFeeChecksDetail = @IdFeeChecksDetail) > 0
			BEGIN
				IF (SELECT TOP 1 1 FROM FeeChecksDetail with(nolock) WHERE IdFeeChecksDetail = @IdFeeChecksDetail AND (FromAmount <> @FromAmount OR ToAmount <> @ToAmount OR Fee <> @Fee OR IsFeePercentage <> @IsFeePercentage)) = 1
				BEGIN
					INSERT INTO FeeChecksHistoryDetail (IdFeeChecksDetail,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage)
					VALUES (@IdFeeChecksDetail,@FromAmount,@ToAmount,@Fee,getdate(),@EnterByIdUser,@IsFeePercentage);
				END
				UPDATE [dbo].[FeeChecksDetail]
				SET 
				IdFeeChecks = @IdFeeOut, FromAmount = @FromAmount, ToAmount = @ToAmount, Fee = @Fee,
				DateOfLastChange = GETDATE(), EnterByIdUser = @EnterByIdUser, IsFeePercentage = @IsFeePercentage
				WHERE IdFeeChecksDetail = @IdFeeChecksDetail;
			END
			ELSE
			BEGIN
				insert into [dbo].[FeeChecksDetail]
					(IdFeeChecks,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage)
				values
					(@IdFeeOut,@FromAmount,@ToAmount,@Fee,getdate(),@EnterByIdUser,@IsFeePercentage);
				INSERT INTO FeeChecksHistoryDetail (IdFeeChecksDetail,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage)
				VALUES (SCOPE_IDENTITY(),@FromAmount,@ToAmount,@Fee,getdate(),@EnterByIdUser,@IsFeePercentage);
			
			END
			DELETE  #FeeChecksDetail WHERE IdFeeChecksDetail = @IdFeeChecksDetail;
		END
	END

END 

END TRY

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveFeeChecks',Getdate(),@ErrorMessage)    
END CATCH








