
CREATE PROCEDURE [collection].[st_DeleteGroup]
@idGroups int 
, @iduserlastchange int
, @nota  nvarchar(50)
AS
Begin Try


/*

	Execute [collection].[st_DeleteGroup]
	@idGroups = 1
	, @iduserlastchange =9012
	, @nota  ='Borrado por ya no ser utilizado'



*/

	DECLARE @HasError INT = 0;
	DECLARE @Message VARCHAR(MAX)='';
	declare @lastchangedate datetime
	set @lastchangedate = getdate()
	declare @borrado int 
	set @borrado = 0
 if exists
 ( 
	select 
   1
	from 
	 collection.Groups
   where 
    IdGroups = @idGroups
	and IdGenericStatus= 1
  )
 begin 
	  UPDATE collection.Groups
		SET IdGenericStatus = 2
		WHERE IdGroups = @idGroups

 set  @borrado = @@ROWCOUNT

 if @borrado = 1  	
 begin
	-- set  @borrado = @@ROWCOUNT
 
	
	INSERT INTO [MAXILOG].dbo.LogUserAssigment
		(
		IdGroup,
		IdUserAssigment,
		IdUserLastChange,
		Nota,
		LastChangeDate,
		TypeChange
		)
	VALUES 
		(
		@idGroups,
		'',
		@iduserlastchange,
		@nota,
		@lastchangedate,
		'Delete'
	)
  end
 
		
 end

	select @borrado as Borrado


End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('collection.st_DeleteGroup',Getdate(),@ErrorMessage);
End Catch

