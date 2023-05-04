create procedure [dbo].[st_SaveGatewayConfig]
(
	@IdStatus int, 
	@IdUser int,
	@Note nvarchar(max),
	@Subject nvarchar(max),
	@Accounts xml,
	@ToDelete xml,
    @IsSpanishLanguage INT,
	@HasError bit out,
	@ResultMessage nvarchar(max) out
)
as
declare @type bit
if @IdStatus = 23
begin
	update GlobalAttributes set Value = @Note where Name like 'NotePaymentReady'
	update GlobalAttributes set value = @Subject where Name like 'SubjectPaymentReady'
	set @type = 0
end

if @IdStatus = 29
begin
	update GlobalAttributes set Value = @Note where Name like 'NoteGatewayInfo'
	update GlobalAttributes set value = @Subject where Name like 'SubjectGatewayInfo'
	set @type = 1
end

if @IdStatus = 30
begin
	update GlobalAttributes set Value = @Note where Name like 'NotePaid'
	update GlobalAttributes set value = @Subject where Name like 'SubjectPaid'
	set @type = 0
end

BEGIN TRY

	--Inicializar Variables
	Set @HasError=0
	Select @ResultMessage = dbo.GetMessageFromLenguajeResorces (case when @IsSpanishLanguage = 1 THEN 0 else 1 end, 106)   

	-- Delete Mail Accounts
	Declare @idAccounts table    
		  (    
		   id int    
		  )    
    
	Declare @DocHandle int      

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @ToDelete      
    
	insert into @idAccounts(id)     
	select id    
	FROM OPENXML (@DocHandle, '/IdsToDelete/IdToDelete', 1)     
	WITH (id int)   

	EXEC sp_xml_removedocument @DocHandle 

	select * from GatewayConfigMail
	update GatewayConfigMail set IdGenericStatus = 2, IdUser = @IdUser, DateOfLastChange = GETDATE() where IdGatewayConfigMail in (select id from @idAccounts)

	-- Update new Mail Accounts
  
	DECLARE @DocHandle2 INT 
	create table #MailAccount
	(
		IdMailAccount int identity (1,1),
		IdMail int,
		IdGateway int,
		Mail NVARCHAR(MAX)
	)

	EXEC sp_xml_preparedocument @DocHandle2 OUTPUT,@Accounts 

	insert into #MailAccount
	SELECT IdMail, IdGateway ,Mail From OPENXML (@DocHandle2, '/MailAccount/Detail',2) 
		WITH (      
			IdMail int,
			IdGateway int,
			Mail NVARCHAR(MAX)
		)
	EXEC sp_xml_removedocument @DocHandle2

	DECLARE @IdAux int,
			@MailAccount int,
			@IdGateway int,
			@Mail NVARCHAR(MAX)
			
	WHILE exists (select top 1 1 from #MailAccount)
	BEGIN
		select top 1 @IdAux = IdMailAccount, @MailAccount = IdMail, @IdGateway = IdGateway, @Mail = Mail from #MailAccount
    
		if @MailAccount = 0
		begin 
			insert into GatewayConfigMail (Mail, IdGateway, IdGenericStatus, IsInfoRequired, IdUser, DateOfLastChange) values (@Mail, @IdGateway, 1, @type, @IdUser, GETDATE())
		end
		else
		BEGIN
			update GatewayConfigMail set Mail = @Mail, IdGateway = @IdGateway, IsInfoRequired = @type, IdUser = @IdUser, DateOfLastChange = GETDATE() where IdGatewayConfigMail = @MailAccount
		end
		delete  #MailAccount where IdMailAccount = @IdAux
	end
end try

BEGIN CATCH
	 Set @HasError = 1                                                                                   
	 Select @ResultMessage = dbo.GetMessageFromLenguajeResorces (case when @IsSpanishLanguage = 1 THEN 0 else 1 end, 33)                                                                               
	 Declare @ErrorMessage nvarchar(max)                                                                                             
	 Select @ErrorMessage=ERROR_MESSAGE()                                             
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveGatewayConfig', Getdate(), @ErrorMessage)    
END CATCH
