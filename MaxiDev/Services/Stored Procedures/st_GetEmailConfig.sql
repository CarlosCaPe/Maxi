create procedure Services.st_GetEmailConfig
(
    @IdService int
)
as

select IdEmailConfig,Host,Port,EnableSSL,UseDefaultCredentials,UserName,[Password],Alias from Services.EmailConfig where idService=@IdService and Idgenericstatus=1