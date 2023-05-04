
create procedure [dbo].[st_GetGatewayConfig]
(
	@IdStatus int
)
as
declare @SubjectKey nvarchar(max)
declare @subject nvarchar(max)
declare @NoteKey nvarchar(max)
declare @Note nvarchar(max)
declare @Type bit

set @SubjectKey = CASE @IdStatus
         WHEN 23 THEN 'SubjectPaymentReady'
         WHEN 29 THEN 'SubjectGatewayInfo'
         WHEN 30 THEN 'SubjectPaid'
         ELSE 'NoExist'
      END

set @NoteKey = CASE @IdStatus
         WHEN 23 THEN 'NotePaymentReady'
         WHEN 29 THEN 'NoteGatewayInfo'
         WHEN 30 THEN 'NotePaid'
         ELSE 'NoExist'
      END

set @Type = CASE @IdStatus
         WHEN 23 THEN 0
         WHEN 29 THEN 1
         WHEN 30 THEN 0
         ELSE null
      END
	  
select @subject = Value from GlobalAttributes where Name like @SubjectKey
select @Note = Value from GlobalAttributes where Name like @NoteKey

select @IdStatus as 'IdStatus', isnull(@subject, '') as 'Subject', isnull(@Note, '') as 'Note'

select gc.IdGatewayConfigMail as 'IdGatewayConfig', gc.Mail, gc.IdGateway, g.GatewayName from GatewayConfigMail gc
join Gateway g on gc.IdGateway = g.IdGateway
where gc.IdGenericStatus = 1 and gc.IsInfoRequired = @Type



