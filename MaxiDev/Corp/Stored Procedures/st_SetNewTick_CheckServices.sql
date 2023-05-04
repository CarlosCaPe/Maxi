CREATE PROCEDURE [Corp].[st_SetNewTick_CheckServices]
	@IdBank		INT,
	@DayOfWeek	INT,
	@TimeHour	INT,
	@TimeMinute	INT,
	@IsDelete	BIT = 0,
	@IsConfirm 	BIT = 0
AS
BEGIN

	/*
	2, 'Southside'
	3, 'Bank of Texas'
	4, 'First Midwest Bank'
	*/
	
	
	--Indica el número de servicio a revisar (1.Southside, 2.Bank Of Texas, 3.First Midwest)
	DECLARE @NoService INT = @IdBank
	
	--Indica el día de la semana al que se agregará el calendario(0.Domingo, 1.Lunes, ...6.Sábado)
	--declare @DayOfWeek int=6
	
	--Horario en el que se establecerá el calendario. NOTA.- Validar que no choque con alguno de los horarios de los servicios, indicados arriba.
	
   	DECLARE @Time NVARCHAR(20)
	DECLARE @min NVARCHAR(2)
	
	SELECT @min = CASE WHEN @TimeMinute < 10 THEN '0' + convert(NVARCHAR(2), @TimeMinute) ELSE convert(NVARCHAR(2), @TimeMinute) END 
	
	SET @Time = convert(NVARCHAR(2), @TimeHour) + ':' + @min
	
	SET @Time = CAST(@Time as time)
	SET @Time = SUBSTRING(@Time,1,5)
	
	--Si el valor es "0", se añadirá el horario con la configuración indicada arriba, de lo contrario se eliminarán los registros que no coincidan con los horarios del servicio indicado.
	declare @Delete BIT = @IsDelete
	
	--Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1".
	DECLARE @Confirm BIT = @IsConfirm
	
	
	
	/*NOTA.- Después de agregar y confirmar un calendario, REINICIAR servicios de "Maxi Host Manager" y "Maxi Host Manager 3" del servidor 006.
			Después de eliminar un calendario, nuevamente  REINICIAR servicios de "Maxi Host Manager" y "Maxi Host Manager 3" del servidor 006.
	*/
	
	
	declare @BankService varchar (50)--Declara variable que puede almacenar cualquiera de los 3 servicios de bancos que procesan cheques (Southside, Bank Of Texas, First Midwest).
	
	declare @TimeSum time,@TimeV nvarchar(20), @TimeAdd time(0)=CAST(@Time as time)
	
	set @TimeSum=DATEADD(minute,5,@TimeAdd)
	
	set @TimeV=CAST(@TimeSum as nvarchar)
	
	set @TimeV=SUBSTRING(@TimeV,1,5)
	
	
	select @BankService=
	case
		when @NoService=2 then '%southside%'
		when @NoService=3 then '%bankoftexas%'
		when @NoService=4 then '%firstmidwest%'
	END
	
	--Validar que no existan cheques en estatus de Pending Gateway Response (IdStatus=21). En caso de que existan, se tienen que actualizar los cheques a estatus de Stand By (IdSTatus=20)
	UPDATE dbo.Checks SET IdStatus = 20 
	WHERE IdStatus = 21
		AND IdCheckProcessorBank = @IdBank
	
	
	if (@Delete=0)
	begin
		if (@NoService=2)
		begin
	
			select *
			from [Services].ServiceSchedules with(nolock)
			where Code like @BankService
	
			begin tran 
				insert into [Services].ServiceSchedules
					select 'SOUTHSIDENVSEND',@DayOfWeek,@TimeV
					union
					select 'SOUTHSIDESEND',@DayOfWeek,@Time
	
				select *
				from [Services].ServiceSchedules with(nolock)
				where Code like @BankService
	
				if (@Confirm=0)
					rollback
				else
					commit
		end
		else
			if (@NoService=3)
			begin
	
				select *
				from [Services].ServiceSchedules with(nolock)
				where Code like @BankService
	
				begin tran 
					insert into [Services].ServiceSchedules
						select 'BANKOFTEXASNVSEND',@DayOfWeek,@TimeV
						union
						select 'BANKOFTEXASSEND',@DayOfWeek,@Time
	
					select *
					from [Services].ServiceSchedules with(nolock)
					where Code like @BankService
	
					if (@Confirm=0)
						rollback
					else
						commit
			end
			else
				if (@NoService=4)
				begin
	
					select *
					from [Services].ServiceSchedules with(nolock)
					where Code like @BankService
	
					begin tran 
						insert into [Services].ServiceSchedules
							select 'FIRSTMIDWESTSEND',@DayOfWeek,@Time
	
						select *
						from [Services].ServiceSchedules with(nolock)
						where Code like @BankService
	
						if (@Confirm=0)
							rollback
						else
							commit
				end
	end
	else
	begin
		if (@NoService=2)
		begin
	
			select *
			from [Services].ServiceSchedules with(nolock)
			where Code like @BankService
				and [Time] not in ('11:00','11:05','17:00','17:05','23:00','23:45')
	
			begin tran 
				delete
				from [Services].ServiceSchedules
				where Code like @BankService
					and [Time] not in ('11:00','11:05','17:00','17:05','23:00','23:45')
	
				select *
				from [Services].ServiceSchedules with(nolock)
				where Code like @BankService
					and [Time] not in ('11:00','11:05','17:00','17:05','23:00','23:45')
	
				if (@Confirm=0)
					rollback
				else
					commit
		end
		else
			if (@NoService=3)
			begin
	
				select *
				from [Services].ServiceSchedules with(nolock)
				where Code like @BankService
					and [Time] not in ('09:00', '09:05', '14:00', '14:05', '20:00', '20:05')
	
				begin tran 
					delete
					from [Services].ServiceSchedules
					where Code like @BankService
						and [Time] not in ('09:00', '09:05', '14:00', '14:05', '20:00', '20:05')
	
					select *
					from [Services].ServiceSchedules with(nolock)
					where Code like @BankService
						and [Time] not in ('09:00', '09:05', '14:00', '14:05', '20:00', '20:05')
	
						if (@Confirm=0)
							rollback
						else
							commit
			end
			else
				if (@NoService=4)
				begin
	
					select *
					from [Services].ServiceSchedules with(nolock)
					where Code like @BankService
						and [Time] not in ('07:00','18:20')
	
					begin tran 
						delete
						from [Services].ServiceSchedules
						where Code like @BankService
							and [Time] not in ('07:00','18:20')
	
						select *
						from [Services].ServiceSchedules with(nolock)
						where Code like @BankService
							and [Time] not in ('07:00','18:20')
	
						if (@Confirm=0)
							rollback
						else
							commit
				end
	end

END