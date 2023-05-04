
CREATE procedure [dbo].[st_RegisterUserPcAccess]
(
	@IdPcIdentifier int,
    @PcIdentifier nvarchar(MAX),
	@MachineName nvarchar(MAX),
	@SerialNumber nvarchar(MAX),
    @IdUser int
)
as
declare @IdUserPcAccess int

begin try

if(exists(select IdPcIdentifier from PcIdentifier where MachineName = @MachineName and SerialNumber = @SerialNumber and Identifier = @PcIdentifier) and @IdPcIdentifier = 0)
	set @IdPcIdentifier = (select IdPcIdentifier from PcIdentifier where MachineName = @MachineName and SerialNumber = @SerialNumber and Identifier = @PcIdentifier)

select @IdUserPcAccess=IdUserPcAccess from [UserPcAccess] where iduser=@IdUser and PcIdentifier=@PcIdentifier and IdPcIdentifier = @IdPcIdentifier

if @IdUserPcAccess is null 
begin
	if(@IdPcIdentifier > 0)
		insert into UserPcAccess (PcIdentifier, IdUser, DateOfFirstAccess, DateOfLastAccess, IdPcIdentifier) values (@PcIdentifier,@IdUser,getdate(),getdate(),@IdPcIdentifier)
end
else
begin
	if(ISNULL(@IdPcIdentifier, 0) > 0)
		begin
			update [UserPcAccess] set [DateOfLastAccess]=getdate(), IdPcIdentifier = @IdPcIdentifier where IdUserPcAccess=@IdUserPcAccess
		end
	else
	begin
		update [UserPcAccess] set [DateOfLastAccess]=getdate() where IdUserPcAccess=@IdUserPcAccess
	end
    
end

end try
begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RegisterUserPcAccess',Getdate(),@ErrorMessage)

end catch