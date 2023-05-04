CREATE PROCEDURE [dbo].[st_UpdateTransferBranch]
(
	@IdTransfer				BIGINT,
	@IdBranch				INT,
	@GatewayBranchCode		VARCHAR(MAX),
	@IdUser					INT
)
AS
BEGIN 
	
	DECLARE @IdStatus INT, @Note VARCHAR(MAX), @IdPaymentType INT, @IdPayer INT, @IdCity INT

	SELECT @IdCity=TransferIdCity, @IdPaymentType=IdPaymentType, @IdPayer=IdPayer 
	FROM Transfer
	WHERE IdTransfer=@IdTransfer

		----- Special case when Idbranch is null but transfer is cash ----------------                                                            
	IF (@IdBranch IS NULL AND (@IdPaymentType=1 OR @IdPaymentType=4 OR @IdPaymentType=2))                                                            
	BEGIN
		IF @IdCity IS NULL
		BEGIN                                
			SELECT TOP 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL)  ORDER BY IdBranch                                                       
			SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch                                                           
		END                                
	 ELSE                              
	 BEGIN
		SELECT TOP 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL) AND IdCity=@IdCity ORDER BY IdBranch                                                       
		SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch                                                           
	 END                                
	END  
  
	-- Check Again IdBranch in case @IdCity was not null but not exists  
	IF (@IdBranch IS NULL AND (@IdPaymentType=1 OR @IdPaymentType=4 OR @IdPaymentType=2))                                                            
	BEGIN
		SELECT TOP 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL )  ORDER BY IdBranch                                                       
		SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch   
	  --Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_CreateTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer))
	  --INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure,infoDate,InfoMessage) values ('st_CreateTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer));
    
	END  

	SELECT 
		@IdStatus = t.IdStatus,
		@Note = CONCAT('The payment branch has been modified to "', bNew.BranchName,'(', @GatewayBranchCode,')" Original Branch: "', bOriginal.BranchName,'(', t.GatewayBranchCode ,')"')
	FROM Transfer t 
		JOIN Branch bOriginal ON bOriginal.IdBranch = t.IdBranch
		JOIN Branch bNew ON bNew.IdBranch = @IdBranch
	WHERE t.IdTransfer = @IdTransfer

	UPDATE Transfer SET
		IdBranch = @IdBranch,
		GatewayBranchCode = @GatewayBranchCode
	WHERE IdTransfer = @IdTransfer

	EXEC st_SaveChangesToTransferLog @IdTransfer, @IdStatus, @Note, @IdUser
END
