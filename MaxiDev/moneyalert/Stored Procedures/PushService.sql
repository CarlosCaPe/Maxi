CREATE procedure [moneyalert].[PushService]
as
Declare @claimcode nvarchar(max)
declare @IdStatusChangePushMessage bigint
DECLARE	
		@HasError bit,
		@Message nvarchar(max)

select IdStatusChangePushMessage,Claimcode into #SendPush from  MoneyAlert.StatusChangePushMessage WITH(NOLOCK) where issend=0 order by creationdate

--@claimcode=Claimcode,@IdStatusChangePushMessage=IdStatusChangePushMessage

while exists(select 1 from #SendPush)
begin

Begin Try 

select @claimcode=Claimcode,@IdStatusChangePushMessage=IdStatusChangePushMessage from #SendPush

delete from #SendPush where IdStatusChangePushMessage=@IdStatusChangePushMessage

EXEC	[dbo].[st_SendMobileNotificationByClaimCode]
		@ClaimCode = @claimcode,
		@HasError = @HasError OUTPUT,
		@Message = @Message OUTPUT

SELECT	@HasError as N'@HasError',
		@Message as N'@Message'


update MoneyAlert.StatusChangePushMessage  set issend=1,senddate=getdate() where IdStatusChangePushMessage=@IdStatusChangePushMessage

insert into MoneyAlert.StatusChangePushMessageDetail
values
(@IdStatusChangePushMessage,getdate(),@HasError,@Message)


End Try                                                                                            
Begin Catch
update MoneyAlert.StatusChangePushMessage  set issend=1,senddate=getdate() where IdStatusChangePushMessage=@IdStatusChangePushMessage
insert into MoneyAlert.StatusChangePushMessageDetail
values
(@IdStatusChangePushMessage,getdate(),1,'Error in MoneyAlert.PushService')                                                                                       
End Catch  


end

drop table #SendPush