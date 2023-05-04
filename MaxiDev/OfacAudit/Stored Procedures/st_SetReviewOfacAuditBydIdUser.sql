CREATE procedure OfacAudit.st_SetReviewOfacAuditBydIdUser
(
    @IdUser int,
    @IdOfacAuditDetail int,
    @SDN_NAME nvarchar(max),
    @HasError bit out
)
as

begin try

if not exists(select top 1 1 from [OfacAudit].[OfacAuditReview] where [IdOfacAuditDetail]=@IdOfacAuditDetail and IdUserReview=@IdUser)
begin
INSERT INTO [OfacAudit].[OfacAuditReview]
           ([IdOfacAuditDetail]
           ,[IdUserReview]
           ,[DateOfReview]
           ,[IdOFACAction])
     VALUES
           (@IdOfacAuditDetail
           ,@IdUser
           ,getdate()
           ,1)
End

if not exists(select top 1 1 from [OfacAudit].[OfacAuditMatchReview] where [IdOfacAuditDetail]=@IdOfacAuditDetail and [SDN_NAME]=@SDN_NAME)
begin
    INSERT INTO [OfacAudit].[OfacAuditMatchReview]
           ([IdOfacAuditDetail]
           ,[SDN_NAME]
           ,[DateOfReview])
     VALUES
           (@IdOfacAuditDetail
           ,@SDN_NAME
           ,getdate())
end

set @HasError = 0
end try

begin catch
 Set @HasError=1                                                                                                             
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select  @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('OfacAudit.st_SetReviewOfacAuditBydIdUser',Getdate(),@ErrorMessage)
end catch