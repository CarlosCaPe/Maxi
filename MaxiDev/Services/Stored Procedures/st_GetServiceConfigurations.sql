-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-07
-- Description:	Load service configurations
-- =============================================
CREATE PROCEDURE [Services].[st_GetServiceConfigurations]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


	-- Service Configuration
	SELECT
		SC.[Code]
		, SC.[Description]
		, SC.[LastTick]
		, SC.[NextTick]
		, SC.[IsEnabled]
	FROM
		[Services].[ServiceConfigurationSchedule] SCS WITH (NOLOCK)
		JOIN [Services].[ServiceConfiguration] SC WITH (NOLOCK) ON SCS.[Code] = SC.[Code]


	-- Service Attributes
	SELECT
		SA.[Code]
		, SA.[Key]
		, SA.[Value]
	FROM
		[Services].[ServiceConfigurationSchedule] SCS WITH (NOLOCK)
		JOIN [Services].[ServiceAttributes] SA WITH (NOLOCK) ON SCS.[Code] = SA.[Code]


	-- Service Configuration Tick
	SELECT
		SCT.[Code]
		, SCT.[Interval]
		, SCT.[StartTime]
		, SCT.[EndTime]
	FROM
		[Services].[ServiceConfigurationSchedule] SCS WITH (NOLOCK)
		JOIN [Services].[ServiceConfigurationTick] SCT WITH (NOLOCK) ON SCS.[Code] = SCT.[Code]


	-- Service Schedules
	SELECT
		SS.[Code]
		, SS.[DayOfWeek]
		, SS.[Time]
	FROM
		[Services].[ServiceConfigurationSchedule] SCS WITH (NOLOCK)
		JOIN [Services].[ServiceSchedules] SS WITH (NOLOCK) ON SCS.[Code] = SS.[Code]
		
		

END
