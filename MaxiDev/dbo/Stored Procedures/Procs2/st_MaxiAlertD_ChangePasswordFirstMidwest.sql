CREATE PROCEDURE [dbo].[st_MaxiAlertD_ChangePasswordFirstMidwest]
AS    
/********************************************************************
<Author>Juan Diego Arellano Vitela</Author>
<app>---</app>
<Description>Procedimiento almacenado que indica cuando quedan diez dias o menos de valides del password del servicio de cheques de First Midwest.</Description>

<ChangeLog>
<log Date="31/08/2018" Author="jdarellano">Creación</log>
</ChangeLog>
*********************************************************************/        
BEGIN 

SET NOCOUNT ON;   
	Begin try

		declare @Date date, 
			@Today date, 
			@Diff int

		set @Date=(CAST((select [Value] from [dbo].[GlobalAttributes] with(nolock) where [Name]='FIRSTMIDWEST_FtpPassword_LastChange') as date))

		set @Today=(CAST(GETDATE() as date))

		set @Diff=(select DATEDIFF(d,@Date,@Today))

		if ((@Diff>=80) and (@Diff<90))
		begin
			select 'Está pronto a caducar el password de First Midwest' NameValidation,
				'Es necesario cambiar la contraseña de First Midwest ya que van '+CAST(@Diff as varchar)+' días de uso, por lo que restan '+CAST((90-@Diff) as varchar)+' días antes de que expire.' MsgValidation,
				'Cambiar password a la brevedad' FixDescription,
				'' Fix
		end
		else
			if (@Diff>=90)
			begin
				select 'Ha caducado el password de First Midwest' NameValidation,
					'Se debe cambiar con urgencia el password de First Midwest ya que expiró. Lleva '+CAST(@Diff as varchar)+' días de uso.' MsgValidation,
					'Cambiar password de inmediato' FixDescription,
					'' Fix
			end

	end try
	begin catch
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage=ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_MaxiAlertD_ChangePasswordFirstMidwest',GETDATE(),'Error in line: '+CONVERT(VARCHAR,ERROR_LINE())+' | '+@ErrorMessage)
	END CATCH		

END


