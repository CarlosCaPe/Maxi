CREATE procedure [dbo].[st_SendCancelServiCentro]
(
    @ConsecutivoCorresponsal int,
    @ReferenciaAuxiliarCorresponsal nvarchar(max),
    @NombreRemitente nvarchar(max),
    @ValordelGiroenDolares money,
    @Motivo nvarchar(max),
    @HasError bit out
)
as
begin try
        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max)         

        set @HasError=0

        set @Motivo = 'A solicitud del Remitente'

        Select @recipients='servinic@servicentro.net;aclaraciones@maxi-ms.com'
        select @subject = 'Maxi - Servicentro Solicitud de Anulacion de Consecutivo Corresponsal : '+convert(varchar,@ConsecutivoCorresponsal)
        select @body = '       <H1>Consecutivo Corresponsal: '+convert(varchar,@ConsecutivoCorresponsal)+'</H1>
                                  <H1>Referencia Auxiliar Corresponsal: '+@ReferenciaAuxiliarCorresponsal+'</H1>
                                  <H1>Nombre Remitente: '+@NombreRemitente+'</H1>
                                  <H1>Valor del Giro en Dolares: '+convert(varchar,@ValordelGiroenDolares)+'</H1>
                                  <H1>Motivo: '+@Motivo+'</H1>
                            '

        Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    
	    --Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	    EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,    
                @body_format ='HTML',                                                         
		        @subject = @subject 

        --select @haserror,@subject

end try
begin catch

    set @HasError=1
    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SendCancelServiCentro',Getdate(),@ErrorMessage)

end catch