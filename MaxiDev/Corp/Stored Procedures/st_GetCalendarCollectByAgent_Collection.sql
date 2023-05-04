CREATE PROCEDURE  [Corp].[st_GetCalendarCollectByAgent_Collection] 
	@idAgent int
	as
BEGIN

	SET NOCOUNT ON;
	/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
       CC.[Amount]
	   ,CC.IdAgent
	   ,CC.CreationDate
      ,CC.[PayDate]
	  ,CC.EnterByIdUser
      ,U.UserName
	  ,CC.IdAgent
	  ,CC.[IdCalendarCollect]
      ,CC.[IdAgentCollectType]
  FROM [dbo].[CalendarCollect] CC WITH (nolock)
  INNER JOIN dbo.Users U WITH (nolock) ON CC.EnterByIdUser= U.IdUser 
  WHERE CC.IdAgent=@idAgent


END
