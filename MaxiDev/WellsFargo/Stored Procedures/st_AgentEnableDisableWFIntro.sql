
create procedure [WellsFargo].[st_AgentEnableDisableWFIntro]
(
    @IdAgent int,
    @IsShow bit,
    @EnterByIdUser int
)
as
if exists(select top 1 1 from [WellsFargo].[WFShowIntro] where enterbyiduser=@EnterByIdUser)
begin
    update [WellsFargo].[WFShowIntro] set EnterByIdUser=@EnterByIdUser,IsShow=@IsShow,DateOfLastChange=getdate()
	where enterbyiduser = @EnterByIdUser 
end
else
begin
    INSERT INTO [WellsFargo].[WFShowIntro]
           ([IdAgent]
           ,[IsShow]
           ,[EnterByIdUser]
           ,[CreationDate]
           ,[DateOfLastChange])
     VALUES
           (@IdAgent
           ,@IsShow
           ,@EnterByIdUser
           ,getdate()
           ,getdate())
end