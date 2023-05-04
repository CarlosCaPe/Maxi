CREATE procedure [dbo].[st_GetFileNameById]
@Type varchar(10),
@Id int,
@HasError bit out,
@ErrorMessage varchar(500) out,
@TelephoneNumber varchar(500) out
as


set @HasError = 0
set @ErrorMessage =''
set @TelephoneNumber =@Type+'_'+Convert(varchar,@Id)
