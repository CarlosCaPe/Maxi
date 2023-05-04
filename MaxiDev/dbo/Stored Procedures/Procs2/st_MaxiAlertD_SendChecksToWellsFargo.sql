 CREATE PROCEDURE [dbo].[st_MaxiAlertD_SendChecksToWellsFargo]
@BeginDate dateTime=null
AS            
BEGIN 


declare @LastTick datetime= dateadd(day,-1,getdate())

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)

declare @EndDate date = convert(date,GETDATE()),
	@TempDate date =@BeginDate

declare @Days table 
(
	CreateDate date
)

While (@TempDate<@EndDate)
BEGIN
	INSERT INTO @Days(CreateDate) values(@TempDate)
	set @TempDate = DATEADD(day,1,@TempDate)
END

--select @BeginDate '@BeginDate',  @EndDate '@EndDate'
--select * from @Days

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
		   'No se enviaron 2 archivos a Wells Fargo' NameValidation,
			'CreateDate: '+ convert(varchar,CreateDate)+'; FileNumber;'+ convert(varchar,FileNumber)
			+'; ChecksNumberFirstTick;'+ convert(varchar,ChecksNumberFirstTick) +'; ChecksNumberSecondTick;'+ convert(varchar,ChecksNumberSecondTick)  MsgValidation,
			'Verificacion manual' FixDescription,
			'' Fix	
	FROM ( 

			Select
				L2.CreateDate,
				L2.FileNumber,
				(select count(1) ChecksNumber from Checks where DateOfMovement>=dateadd(MINUTE,-1,dateadd(HOUR,-8,convert(datetime, L2.CreateDate))) and DateOfMovement<dateadd(MINUTE,59,dateadd(HOUR,10,convert(datetime, L2.CreateDate)))) ChecksNumberFirstTick,
				(select count(1) ChecksNumber from Checks where DateOfMovement>=dateadd(MINUTE,59,dateadd(HOUR,10,convert(datetime, L2.CreateDate))) and DateOfMovement<dateadd(MINUTE,59,dateadd(HOUR,15,convert(datetime, L2.CreateDate)))) ChecksNumberSecondTick
			FROM
				(
					select L.CreateDate, sum(Movement) FileNumber
					from 
						(
								select CAST(CreateDate AS DATE) CreateDate, 1 Movement
								from CheckBundle CB
								where CB.CreateDate>=@BeginDate and CB.CreateDate<@EndDate
								group by CAST(CreateDate AS DATE), FileIdentifier
							union all
								select CreateDate, 0 Movement
								from @Days
						)L
					group by CreateDate
					having sum(Movement)!=2 
				)L2
	) cet

	UNION ALL

	SELECT 
		   'No se confirmaron los archivos de Wells Fargo' NameValidation,
			'CreateDate: '+ convert(varchar,CreateDate) MsgValidation,
			'Verificacion manual' FixDescription,
			'' Fix	
	FROM ( 

			select CAST(CreateDate AS DATE) CreateDate
			from CheckBundle CB
			where CB.CreateDate>=@BeginDate and CB.ApplyDate is null
	
		)cet
	
	UNION ALL

	select 
			'Cheque en Standby, Pending, Accepted por mucho tiempo' NameValidation,
			'IdCheck: '+ convert(varchar,IdCheck)+'; CreateDate: '+ convert(varchar,DateOfMovement) MsgValidation,
			'Verificacion manual' FixDescription,
			'' Fix	 
	from checks 
	where IdStatus in (20, 21,40) and  LTRIM(RTRIM(ISNULL(MicrManual,''))) !='' and DateOfMovement<=@LastTick
		



END


