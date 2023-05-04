CREATE procedure [BIWS].[st_GetEmailConfigBI]

as

select IdEmailConfigBI,
Host,
Port,
EnableSSL,
UseDefaultCredentials,
UserName,
[Password], 
EmailReceiver
FROM BIWS.EmailConfigBI WITH(NOLOCK) where Idgenericstatus = 1


